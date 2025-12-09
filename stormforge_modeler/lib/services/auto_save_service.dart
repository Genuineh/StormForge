import 'dart:async';
import 'package:flutter/foundation.dart';

/// Service that handles automatic saving of project data
/// 
/// This service provides:
/// - Periodic auto-save at configurable intervals (default 30 seconds)
/// - Manual save triggering
/// - Debouncing to prevent excessive saves
/// - Status tracking (saving, saved, error)
class AutoSaveService extends ChangeNotifier {
  Timer? _autoSaveTimer;
  Timer? _debounceTimer;
  bool _isDirty = false;
  bool _isSaving = false;
  String? _lastError;
  DateTime? _lastSaveTime;
  
  /// Callback function to execute when auto-save triggers
  final Future<void> Function() onSave;
  
  /// Auto-save interval in seconds (default: 30 seconds)
  final int autoSaveIntervalSeconds;
  
  /// Debounce delay in milliseconds to prevent rapid saves (default: 2 seconds)
  final int debounceDelayMs;

  AutoSaveService({
    required this.onSave,
    this.autoSaveIntervalSeconds = 30,
    this.debounceDelayMs = 2000,
  });

  /// Whether there are unsaved changes
  bool get isDirty => _isDirty;

  /// Whether a save operation is currently in progress
  bool get isSaving => _isSaving;

  /// The last error message, if any
  String? get lastError => _lastError;

  /// The timestamp of the last successful save
  DateTime? get lastSaveTime => _lastSaveTime;

  /// Start the auto-save timer
  void startAutoSave() {
    stopAutoSave();
    _autoSaveTimer = Timer.periodic(
      Duration(seconds: autoSaveIntervalSeconds),
      (_) => _executeSave(),
    );
  }

  /// Stop the auto-save timer
  void stopAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  /// Mark that changes have been made (triggers debounced save)
  void markDirty() {
    if (_isSaving) return;
    
    _isDirty = true;
    _lastError = null;
    notifyListeners();

    // Debounce the save to avoid saving on every keystroke
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      Duration(milliseconds: debounceDelayMs),
      () => _executeSave(),
    );
  }

  /// Manually trigger a save operation
  Future<void> saveNow() async {
    _debounceTimer?.cancel();
    await _executeSave();
  }

  /// Execute the save operation
  Future<void> _executeSave() async {
    if (!_isDirty || _isSaving) return;

    _isSaving = true;
    _lastError = null;
    notifyListeners();

    try {
      await onSave();
      _isDirty = false;
      _lastSaveTime = DateTime.now();
      _lastError = null;
    } catch (e) {
      _lastError = e.toString();
      debugPrint('Auto-save error: $e');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Get a human-readable status message
  String getStatusMessage() {
    if (_isSaving) {
      return 'Saving...';
    } else if (_lastError != null) {
      return 'Error: $_lastError';
    } else if (_lastSaveTime != null) {
      final now = DateTime.now();
      final diff = now.difference(_lastSaveTime!);
      if (diff.inSeconds < 60) {
        return 'Saved ${diff.inSeconds} seconds ago';
      } else if (diff.inMinutes < 60) {
        return 'Saved ${diff.inMinutes} minutes ago';
      } else {
        return 'Saved ${diff.inHours} hours ago';
      }
    } else if (_isDirty) {
      return 'Unsaved changes';
    } else {
      return 'All changes saved';
    }
  }

  @override
  void dispose() {
    stopAutoSave();
    super.dispose();
  }
}
