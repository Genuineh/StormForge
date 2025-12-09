import 'package:flutter_test/flutter_test.dart';
import 'package:stormforge_modeler/models/library_model.dart';
import 'package:stormforge_modeler/services/api/api_client.dart';
import 'package:stormforge_modeler/services/api/library_service.dart';

class MockApiClient extends ApiClient {
  MockApiClient() : super(baseUrl: 'http://mock.test');

  Map<String, dynamic>? _mockResponse;

  void setMockResponse(Map<String, dynamic> response) {
    _mockResponse = response;
  }

  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (_mockResponse != null) {
      return _mockResponse!;
    }
    throw Exception('No mock response set');
  }

  @override
  Future<Map<String, dynamic>> post(
      String path, Map<String, dynamic> body) async {
    if (_mockResponse != null) {
      return _mockResponse!;
    }
    throw Exception('No mock response set');
  }
}

void main() {
  late MockApiClient mockApiClient;
  late LibraryService libraryService;

  setUp(() {
    mockApiClient = MockApiClient();
    libraryService = LibraryService(mockApiClient);
  });

  group('LibraryService', () {
    group('searchComponents', () {
      test('handles response with components array', () async {
        // Arrange - API returns Map with 'components' key containing list
        mockApiClient.setMockResponse({
          'components': [
            {
              'id': 'comp-1',
              'name': 'TestComponent',
              'namespace': 'test',
              'scope': 'enterprise',
              'type': 'entity',
              'version': '1.0.0',
              'description': 'Test component',
              'definition': {},
              'status': 'active',
              'usageStats': {
                'projectCount': 0,
                'referenceCount': 0,
              },
              'createdAt': '2025-01-01T00:00:00.000Z',
              'updatedAt': '2025-01-01T00:00:00.000Z',
            }
          ],
          'total': 1,
        });

        // Act
        final result = await libraryService.searchComponents();

        // Assert
        expect(result, isA<List<LibraryComponent>>());
        expect(result.length, 1);
        expect(result.first.name, 'TestComponent');
      });

      test('handles empty components array', () async {
        // Arrange
        mockApiClient.setMockResponse({
          'components': [],
          'total': 0,
        });

        // Act
        final result = await libraryService.searchComponents();

        // Assert
        expect(result, isEmpty);
      });

      test('handles missing components key', () async {
        // Arrange - Response without 'components' key
        mockApiClient.setMockResponse({
          'total': 0,
        });

        // Act
        final result = await libraryService.searchComponents();

        // Assert - Should return empty list due to null coalescing
        expect(result, isEmpty);
      });
    });

    group('getComponentVersions', () {
      test('handles response with versions array', () async {
        // Arrange
        mockApiClient.setMockResponse({
          'versions': [
            {
              'id': 'ver-1',
              'componentId': 'comp-1',
              'version': '1.0.0',
              'definition': {},
              'changeNotes': 'Initial version',
              'author': 'test@example.com',
              'createdAt': '2025-01-01T00:00:00.000Z',
            },
            {
              'id': 'ver-2',
              'componentId': 'comp-1',
              'version': '1.1.0',
              'definition': {},
              'changeNotes': 'Bug fixes',
              'author': 'test@example.com',
              'createdAt': '2025-02-01T00:00:00.000Z',
            }
          ]
        });

        // Act
        final result = await libraryService.getComponentVersions('comp-1');

        // Assert
        expect(result, isA<List<ComponentVersion>>());
        expect(result.length, 2);
        expect(result.first.version, '1.0.0');
        expect(result.last.version, '1.1.0');
      });

      test('handles empty versions array', () async {
        // Arrange
        mockApiClient.setMockResponse({
          'versions': [],
        });

        // Act
        final result = await libraryService.getComponentVersions('comp-1');

        // Assert
        expect(result, isEmpty);
      });

      test('handles missing versions key', () async {
        // Arrange
        mockApiClient.setMockResponse({});

        // Act
        final result = await libraryService.getComponentVersions('comp-1');

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getProjectReferences', () {
      test('handles response with references array', () async {
        // Arrange
        mockApiClient.setMockResponse({
          'references': [
            {
              'id': 'ref-1',
              'projectId': 'proj-1',
              'componentId': 'comp-1',
              'version': '1.0.0',
              'mode': 'copy',
              'addedAt': '2025-01-01T00:00:00.000Z',
            }
          ]
        });

        // Act
        final result = await libraryService.getProjectReferences('proj-1');

        // Assert
        expect(result, isA<List<ComponentReference>>());
        expect(result.length, 1);
        expect(result.first.componentId, 'comp-1');
      });

      test('handles empty references array', () async {
        // Arrange
        mockApiClient.setMockResponse({
          'references': [],
        });

        // Act
        final result = await libraryService.getProjectReferences('proj-1');

        // Assert
        expect(result, isEmpty);
      });

      test('handles missing references key', () async {
        // Arrange
        mockApiClient.setMockResponse({});

        // Act
        final result = await libraryService.getProjectReferences('proj-1');

        // Assert
        expect(result, isEmpty);
      });
    });
  });
}
