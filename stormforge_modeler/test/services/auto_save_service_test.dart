import 'package:flutter_test/flutter_test.dart';
import 'package:stormforge_modeler/services/auto_save_service.dart';

void main() {
  group('AutoSaveService', () {
    late AutoSaveService autoSaveService;
    late List<DateTime> saveCalls;

    setUp(() {
      saveCalls = [];
      autoSaveService = AutoSaveService(
        onSave: () async {
          saveCalls.add(DateTime.now());
          await Future.delayed(const Duration(milliseconds: 10));
        },
        autoSaveIntervalSeconds: 1, // 1 second for faster testing
        debounceDelayMs: 100, // 100ms for faster testing
      );
    });

    tearDown(() {
      autoSaveService.dispose();
    });

    test('initial state should be clean', () {
      expect(autoSaveService.isDirty, false);
      expect(autoSaveService.isSaving, false);
      expect(autoSaveService.lastError, isNull);
      expect(autoSaveService.lastSaveTime, isNull);
    });

    test('markDirty should set isDirty flag', () {
      autoSaveService.markDirty();
      expect(autoSaveService.isDirty, true);
    });

    test('markDirty should trigger debounced save', () async {
      autoSaveService.markDirty();
      expect(autoSaveService.isDirty, true);

      // Wait for debounce
      await Future.delayed(const Duration(milliseconds: 150));

      expect(saveCalls, hasLength(1));
      expect(autoSaveService.isDirty, false);
    });

    test('multiple markDirty calls should debounce', () async {
      autoSaveService.markDirty();
      await Future.delayed(const Duration(milliseconds: 50));
      autoSaveService.markDirty();
      await Future.delayed(const Duration(milliseconds: 50));
      autoSaveService.markDirty();

      // Wait for debounce
      await Future.delayed(const Duration(milliseconds: 150));

      // Should only save once due to debouncing
      expect(saveCalls, hasLength(1));
      expect(autoSaveService.isDirty, false);
    });

    test('saveNow should trigger immediate save', () async {
      autoSaveService.markDirty();
      await autoSaveService.saveNow();

      expect(saveCalls, hasLength(1));
      expect(autoSaveService.isDirty, false);
      expect(autoSaveService.lastSaveTime, isNotNull);
    });

    test('startAutoSave should trigger periodic saves', () async {
      autoSaveService.markDirty();
      autoSaveService.startAutoSave();

      // Wait for auto-save to trigger (1 second interval + some buffer)
      await Future.delayed(const Duration(milliseconds: 1200));

      expect(saveCalls.length, greaterThanOrEqualTo(1));
      autoSaveService.stopAutoSave();
    });

    test('stopAutoSave should stop periodic saves', () async {
      autoSaveService.markDirty();
      autoSaveService.startAutoSave();

      await Future.delayed(const Duration(milliseconds: 1200));
      final saveCount = saveCalls.length;

      autoSaveService.stopAutoSave();
      await Future.delayed(const Duration(milliseconds: 1200));

      // Should not have saved again after stopping
      expect(saveCalls.length, equals(saveCount));
    });

    test('should not save when not dirty', () async {
      await autoSaveService.saveNow();
      expect(saveCalls, isEmpty);
    });

    test('should not trigger save while already saving', () async {
      // Create a slow save operation
      final slowSaveService = AutoSaveService(
        onSave: () async {
          saveCalls.add(DateTime.now());
          await Future.delayed(const Duration(milliseconds: 500));
        },
      );

      slowSaveService.markDirty();
      final saveFuture = slowSaveService.saveNow();

      // Try to trigger another save while first is in progress
      slowSaveService.markDirty();

      await saveFuture;

      // Should only have one save call
      expect(saveCalls, hasLength(1));

      slowSaveService.dispose();
    });

    test('should handle save errors gracefully', () async {
      final errorService = AutoSaveService(
        onSave: () async {
          throw Exception('Save failed');
        },
      );

      errorService.markDirty();
      await errorService.saveNow();

      expect(errorService.lastError, contains('Save failed'));
      expect(errorService.isDirty, true); // Should remain dirty on error
      expect(errorService.isSaving, false);

      errorService.dispose();
    });

    test('getStatusMessage should return correct messages', () async {
      expect(autoSaveService.getStatusMessage(), equals('All changes saved'));

      autoSaveService.markDirty();
      expect(autoSaveService.getStatusMessage(), equals('Unsaved changes'));

      await autoSaveService.saveNow();
      expect(
        autoSaveService.getStatusMessage(),
        contains('Saved'),
      );
    });

    test('getStatusMessage should show time since last save', () async {
      autoSaveService.markDirty();
      await autoSaveService.saveNow();

      await Future.delayed(const Duration(seconds: 2));
      final message = autoSaveService.getStatusMessage();

      expect(message, contains('Saved'));
      expect(message, contains('seconds ago'));
    });

    test('lastSaveTime should be updated after successful save', () async {
      expect(autoSaveService.lastSaveTime, isNull);

      autoSaveService.markDirty();
      await autoSaveService.saveNow();

      expect(autoSaveService.lastSaveTime, isNotNull);
      expect(
        autoSaveService.lastSaveTime!.isBefore(DateTime.now()),
        true,
      );
    });

    test('should notify listeners when state changes', () async {
      var notifyCount = 0;
      autoSaveService.addListener(() {
        notifyCount++;
      });

      autoSaveService.markDirty();
      expect(notifyCount, greaterThan(0));

      final countBeforeSave = notifyCount;
      await autoSaveService.saveNow();
      expect(notifyCount, greaterThan(countBeforeSave));
    });
  });
}
