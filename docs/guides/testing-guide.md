# StormForge Testing Guide

> **Version**: 2.0  
> **Last Updated**: December 2025  
> **Audience**: Developers, QA engineers, testers

---

## Table of Contents

1. [Introduction](#introduction)
2. [Testing Strategy](#testing-strategy)
3. [Unit Testing](#unit-testing)
4. [Integration Testing](#integration-testing)
5. [UI/UX Testing](#uiux-testing)
6. [Performance Testing](#performance-testing)
7. [API Testing](#api-testing)
8. [End-to-End Testing](#end-to-end-testing)
9. [Test Automation](#test-automation)
10. [Best Practices](#best-practices)

---

## Introduction

### Testing Goals

StormForge testing aims to ensure:

- **Functionality**: All features work as designed
- **Reliability**: System behaves consistently
- **Performance**: Meets performance requirements (1000+ elements @60fps)
- **Security**: No vulnerabilities in implementation
- **Usability**: Intuitive user experience
- **Compatibility**: Works across platforms and browsers

### Test Coverage Goals

- **Unit Tests**: >80% code coverage
- **Integration Tests**: All critical user flows
- **UI Tests**: All user-facing components
- **Performance Tests**: Key performance metrics validated
- **API Tests**: All endpoints tested

---

## Testing Strategy

### Test Pyramid

```
          ┌────────────┐
          │    E2E     │  5%  - Full user journeys
          ├────────────┤
          │ Integration│ 15%  - Component integration
          ├────────────┤
          │    Unit    │ 80%  - Individual functions/classes
          └────────────┘
```

### Testing Phases

#### Phase 1: Unit Testing
- Test individual functions and classes
- Mock external dependencies
- Fast feedback loop

#### Phase 2: Integration Testing
- Test component interactions
- Test database operations
- Test API endpoints

#### Phase 3: System Testing
- Test complete features
- Test user workflows
- Cross-browser testing

#### Phase 4: Acceptance Testing
- User acceptance testing
- Beta testing program
- Feedback collection

---

## Unit Testing

### Backend Unit Tests (Rust)

#### Setup

StormForge backend uses the standard Rust testing framework.

**Run all tests**:
```bash
cd stormforge_backend
cargo test
```

**Run specific test**:
```bash
cargo test test_name
```

**Run with output**:
```bash
cargo test -- --nocapture
```

#### Writing Unit Tests

**Example: User Service Tests**

```rust
// src/services/user_service.rs

#[cfg(test)]
mod tests {
    use super::*;
    
    #[tokio::test]
    async fn test_create_user_success() {
        // Arrange
        let user_data = CreateUserRequest {
            username: "testuser".to_string(),
            email: "test@example.com".to_string(),
            password: "SecurePass123!".to_string(),
            display_name: "Test User".to_string(),
            role: "developer".to_string(),
        };
        
        // Act
        let result = create_user(user_data).await;
        
        // Assert
        assert!(result.is_ok());
        let user = result.unwrap();
        assert_eq!(user.username, "testuser");
        assert_eq!(user.email, "test@example.com");
    }
    
    #[tokio::test]
    async fn test_create_user_duplicate_username() {
        // Test duplicate username handling
        // ...
    }
    
    #[tokio::test]
    async fn test_create_user_invalid_email() {
        // Test email validation
        // ...
    }
}
```

**Example: Entity Repository Tests**

```rust
#[cfg(test)]
mod tests {
    use super::*;
    use sqlx::sqlite::SqlitePoolOptions;
    
    async fn setup_test_db() -> SqlitePool {
        let pool = SqlitePoolOptions::new()
            .connect("sqlite::memory:")
            .await
            .unwrap();
        
        // Run migrations
        sqlx::migrate!("./migrations")
            .run(&pool)
            .await
            .unwrap();
        
        pool
    }
    
    #[tokio::test]
    async fn test_create_entity() {
        let pool = setup_test_db().await;
        let repo = EntityRepository::new(pool);
        
        let entity = EntityDefinition {
            id: "entity-123".to_string(),
            project_id: "proj-456".to_string(),
            name: "OrderEntity".to_string(),
            entity_type: "aggregate_root".to_string(),
            properties: vec![],
            methods: vec![],
            invariants: vec![],
        };
        
        let result = repo.create(entity).await;
        assert!(result.is_ok());
    }
    
    #[tokio::test]
    async fn test_get_entity_not_found() {
        let pool = setup_test_db().await;
        let repo = EntityRepository::new(pool);
        
        let result = repo.get_by_id("nonexistent").await;
        assert!(result.is_err());
    }
}
```

#### Test Coverage

**Generate coverage report**:

```bash
# Install tarpaulin
cargo install cargo-tarpaulin

# Generate coverage
cargo tarpaulin --out Html --output-dir coverage

# Open coverage report
open coverage/index.html
```

### Frontend Unit Tests (Flutter/Dart)

#### Setup

StormForge modeler uses Flutter's built-in test framework.

**Run all tests**:
```bash
cd stormforge_modeler
flutter test
```

**Run specific test**:
```bash
flutter test test/models/entity_model_test.dart
```

**Run with coverage**:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

#### Writing Unit Tests

**Example: Entity Model Tests**

```dart
// test/models/entity_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:stormforge_modeler/models/entity_model.dart';

void main() {
  group('EntityDefinition', () {
    test('creates entity with valid data', () {
      // Arrange
      final entity = EntityDefinition(
        id: 'entity-123',
        projectId: 'proj-456',
        name: 'OrderEntity',
        entityType: EntityType.aggregateRoot,
        properties: [],
        methods: [],
        invariants: [],
      );
      
      // Assert
      expect(entity.id, 'entity-123');
      expect(entity.name, 'OrderEntity');
      expect(entity.entityType, EntityType.aggregateRoot);
    });
    
    test('validates required fields', () {
      // Test validation logic
      expect(
        () => EntityDefinition(
          id: '',  // Invalid empty ID
          projectId: 'proj-456',
          name: 'OrderEntity',
        ),
        throwsA(isA<ValidationException>()),
      );
    });
    
    test('serializes to JSON correctly', () {
      final entity = EntityDefinition(
        id: 'entity-123',
        name: 'OrderEntity',
        // ...
      );
      
      final json = entity.toJson();
      
      expect(json['id'], 'entity-123');
      expect(json['name'], 'OrderEntity');
    });
    
    test('deserializes from JSON correctly', () {
      final json = {
        'id': 'entity-123',
        'name': 'OrderEntity',
        // ...
      };
      
      final entity = EntityDefinition.fromJson(json);
      
      expect(entity.id, 'entity-123');
      expect(entity.name, 'OrderEntity');
    });
  });
  
  group('EntityProperty', () {
    test('validates property types', () {
      // Test property validation
    });
    
    test('applies validation rules correctly', () {
      // Test validation rules
    });
  });
}
```

**Example: Canvas Controller Tests**

```dart
// test/canvas/canvas_controller_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stormforge_modeler/canvas/canvas_controller.dart';

void main() {
  group('CanvasController', () {
    late ProviderContainer container;
    
    setUp(() {
      container = ProviderContainer();
    });
    
    tearDown(() {
      container.dispose();
    });
    
    test('adds element to canvas', () {
      final controller = container.read(canvasControllerProvider.notifier);
      
      controller.addElement(
        type: ElementType.command,
        position: Offset(100, 100),
        name: 'PlaceOrder',
      );
      
      final state = container.read(canvasControllerProvider);
      expect(state.elements.length, 1);
      expect(state.elements.first.name, 'PlaceOrder');
    });
    
    test('removes element from canvas', () {
      final controller = container.read(canvasControllerProvider.notifier);
      
      // Add element
      controller.addElement(
        type: ElementType.command,
        position: Offset(100, 100),
        name: 'PlaceOrder',
      );
      
      final elementId = container.read(canvasControllerProvider)
          .elements.first.id;
      
      // Remove element
      controller.removeElement(elementId);
      
      final state = container.read(canvasControllerProvider);
      expect(state.elements.length, 0);
    });
    
    test('creates connection between elements', () {
      // Test connection creation
    });
  });
}
```

---

## Integration Testing

### Backend Integration Tests

Integration tests verify component interactions and database operations.

#### Database Integration Tests

```rust
// tests/integration/entity_integration_test.rs

use stormforge_backend::*;
use sqlx::SqlitePool;

#[tokio::test]
async fn test_entity_crud_workflow() {
    // Setup test database
    let pool = setup_test_db().await;
    let entity_repo = EntityRepository::new(pool.clone());
    
    // 1. Create entity
    let entity = EntityDefinition {
        id: "entity-123".to_string(),
        project_id: "proj-456".to_string(),
        name: "OrderEntity".to_string(),
        entity_type: "aggregate_root".to_string(),
        properties: vec![
            Property {
                name: "id".to_string(),
                property_type: "OrderId".to_string(),
                identifier: true,
                required: true,
            }
        ],
        methods: vec![],
        invariants: vec![],
    };
    
    let created = entity_repo.create(entity.clone()).await.unwrap();
    assert_eq!(created.id, "entity-123");
    
    // 2. Read entity
    let retrieved = entity_repo.get_by_id("entity-123").await.unwrap();
    assert_eq!(retrieved.name, "OrderEntity");
    
    // 3. Update entity
    let mut updated = retrieved.clone();
    updated.description = Some("Updated description".to_string());
    entity_repo.update(updated).await.unwrap();
    
    // 4. List entities
    let entities = entity_repo.list_by_project("proj-456").await.unwrap();
    assert_eq!(entities.len(), 1);
    
    // 5. Delete entity
    entity_repo.delete("entity-123").await.unwrap();
    
    let result = entity_repo.get_by_id("entity-123").await;
    assert!(result.is_err());
}
```

#### API Integration Tests

```rust
// tests/integration/api_integration_test.rs

use axum_test::TestServer;
use stormforge_backend::*;

#[tokio::test]
async fn test_user_registration_and_login_flow() {
    let app = create_test_app().await;
    let server = TestServer::new(app).unwrap();
    
    // 1. Register user
    let register_response = server
        .post("/api/auth/register")
        .json(&json!({
            "username": "testuser",
            "email": "test@example.com",
            "password": "SecurePass123!",
            "displayName": "Test User",
            "role": "developer"
        }))
        .await;
    
    assert_eq!(register_response.status_code(), 201);
    let register_body: serde_json::Value = register_response.json();
    assert_eq!(register_body["username"], "testuser");
    
    // 2. Login with credentials
    let login_response = server
        .post("/api/auth/login")
        .json(&json!({
            "usernameOrEmail": "testuser",
            "password": "SecurePass123!"
        }))
        .await;
    
    assert_eq!(login_response.status_code(), 200);
    let login_body: serde_json::Value = login_response.json();
    let token = login_body["token"].as_str().unwrap();
    
    // 3. Access protected endpoint with token
    let profile_response = server
        .get("/api/users/me")
        .add_header("Authorization", format!("Bearer {}", token))
        .await;
    
    assert_eq!(profile_response.status_code(), 200);
    let profile_body: serde_json::Value = profile_response.json();
    assert_eq!(profile_body["username"], "testuser");
}

#[tokio::test]
async fn test_project_creation_and_management() {
    let app = create_test_app().await;
    let server = TestServer::new(app).unwrap();
    
    // Login and get token
    let token = login_test_user(&server).await;
    
    // 1. Create project
    let create_response = server
        .post("/api/projects")
        .add_header("Authorization", format!("Bearer {}", token))
        .json(&json!({
            "name": "Test Project",
            "namespace": "com.test.project",
            "description": "A test project",
            "visibility": "private"
        }))
        .await;
    
    assert_eq!(create_response.status_code(), 201);
    let project: serde_json::Value = create_response.json();
    let project_id = project["id"].as_str().unwrap();
    
    // 2. Get project
    let get_response = server
        .get(&format!("/api/projects/{}", project_id))
        .add_header("Authorization", format!("Bearer {}", token))
        .await;
    
    assert_eq!(get_response.status_code(), 200);
    
    // 3. Update project
    let update_response = server
        .put(&format!("/api/projects/{}", project_id))
        .add_header("Authorization", format!("Bearer {}", token))
        .json(&json!({
            "name": "Updated Project Name"
        }))
        .await;
    
    assert_eq!(update_response.status_code(), 200);
    
    // 4. Delete project
    let delete_response = server
        .delete(&format!("/api/projects/{}", project_id))
        .add_header("Authorization", format!("Bearer {}", token))
        .await;
    
    assert_eq!(delete_response.status_code(), 204);
}
```

### Frontend Integration Tests

```dart
// test/integration/project_workflow_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:stormforge_modeler/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Project workflow integration test', () {
    testWidgets('User can create and manage project', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();
      
      // 1. Login
      await tester.enterText(
        find.byKey(Key('username_field')),
        'testuser',
      );
      await tester.enterText(
        find.byKey(Key('password_field')),
        'SecurePass123!',
      );
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();
      
      // 2. Create new project
      await tester.tap(find.byKey(Key('new_project_button')));
      await tester.pumpAndSettle();
      
      await tester.enterText(
        find.byKey(Key('project_name_field')),
        'Test Project',
      );
      await tester.enterText(
        find.byKey(Key('project_namespace_field')),
        'com.test.project',
      );
      await tester.tap(find.byKey(Key('create_project_button')));
      await tester.pumpAndSettle();
      
      // Verify project created
      expect(find.text('Test Project'), findsOneWidget);
      
      // 3. Open project
      await tester.tap(find.text('Test Project'));
      await tester.pumpAndSettle();
      
      // Verify canvas is displayed
      expect(find.byKey(Key('canvas_widget')), findsOneWidget);
      
      // 4. Add element to canvas
      await tester.tap(find.byKey(Key('add_command_button')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byType(Canvas));
      await tester.pumpAndSettle();
      
      // Verify element added
      expect(find.text('New Command'), findsOneWidget);
    });
  });
}
```

---

## UI/UX Testing

### Manual UI Testing Checklist

#### Canvas Functionality

- [ ] **Element Creation**
  - [ ] Can create all 8 element types (Event, Command, Aggregate, etc.)
  - [ ] Elements appear at correct position
  - [ ] Elements have correct default styling
  
- [ ] **Element Manipulation**
  - [ ] Can select single element
  - [ ] Can select multiple elements (Shift+Click, drag-select)
  - [ ] Can move elements by dragging
  - [ ] Can resize elements
  - [ ] Can delete elements (Delete key, right-click menu)
  
- [ ] **Canvas Navigation**
  - [ ] Can zoom in/out (Ctrl+Wheel, Ctrl+/-)
  - [ ] Can pan canvas (Space+Drag, Middle-mouse drag)
  - [ ] Can reset zoom (Ctrl+0)
  - [ ] Canvas renders smoothly at all zoom levels
  
- [ ] **Connections**
  - [ ] Can create connections between elements
  - [ ] Connections auto-route around obstacles
  - [ ] Can select and delete connections
  - [ ] Connections have correct styling by type

#### Entity Editor

- [ ] **Entity Management**
  - [ ] Can create new entity
  - [ ] Can open existing entity
  - [ ] Can edit entity properties
  - [ ] Can add/remove properties
  - [ ] Can add/remove methods
  - [ ] Can add/remove invariants
  - [ ] Changes save correctly

#### Project Management

- [ ] **Project Operations**
  - [ ] Can create new project
  - [ ] Can open existing project
  - [ ] Can update project settings
  - [ ] Can delete project
  - [ ] Can export IR
  - [ ] Can import IR

#### Responsive Design

Test on different screen sizes:
- [ ] Desktop (1920x1080, 1440x900, 1280x720)
- [ ] Tablet (1024x768, 768x1024)
- [ ] Mobile (375x667, 414x896) - if applicable

### Automated UI Tests

```dart
// test/widget/canvas_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stormforge_modeler/canvas/canvas_widget.dart';

void main() {
  testWidgets('Canvas widget renders correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CanvasWidget(),
        ),
      ),
    );
    
    expect(find.byType(CanvasWidget), findsOneWidget);
    expect(find.byType(CustomPaint), findsOneWidget);
  });
  
  testWidgets('Can add element to canvas', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CanvasWidget(),
        ),
      ),
    );
    
    // Simulate adding element
    await tester.tap(find.byType(CanvasWidget));
    await tester.pump();
    
    // Verify element added
    // ...
  });
}
```

### Accessibility Testing

- [ ] **Keyboard Navigation**
  - [ ] Can navigate using Tab key
  - [ ] Can activate buttons with Enter/Space
  - [ ] Can use keyboard shortcuts
  
- [ ] **Screen Reader Support**
  - [ ] All interactive elements have labels
  - [ ] Form fields have descriptions
  - [ ] Error messages are announced
  
- [ ] **Color Contrast**
  - [ ] Text meets WCAG AA standards (4.5:1 for normal text)
  - [ ] UI elements meet contrast requirements

---

## Performance Testing

### Canvas Performance

#### Test: Rendering 1000+ Elements @60fps

**Setup**:
```dart
// test/performance/canvas_performance_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/scheduler.dart';

void main() {
  testWidgets('Canvas renders 1000 elements at 60fps', (tester) async {
    // Setup canvas with 1000 elements
    final elements = List.generate(1000, (i) => 
      CanvasElement(
        id: 'elem-$i',
        type: ElementType.command,
        position: Offset(
          (i % 50) * 150.0,
          (i ~/ 50) * 100.0,
        ),
      ),
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: CanvasWidget(elements: elements),
      ),
    );
    
    // Measure frame rate
    final timeline = await tester.binding.traceAction(() async {
      // Simulate scrolling/panning
      await tester.drag(
        find.byType(CanvasWidget),
        Offset(-500, -500),
      );
      await tester.pumpAndSettle();
    });
    
    // Calculate average frame time
    final frameTimings = timeline.frameTimings!;
    final totalTime = frameTimings.fold<Duration>(
      Duration.zero,
      (sum, timing) => sum + timing.totalSpan,
    );
    final avgFrameTime = totalTime.inMicroseconds / frameTimings.length;
    
    // Assert 60fps (16.67ms per frame)
    expect(avgFrameTime, lessThan(16670)); // microseconds
    
    print('Average frame time: ${avgFrameTime / 1000}ms');
    print('Average FPS: ${1000000 / avgFrameTime}');
  });
}
```

#### Load Testing

**Backend load test** with Apache Bench:

```bash
# Test project creation endpoint
ab -n 1000 -c 10 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -p project.json \
  http://localhost:3000/api/projects

# Results:
# Requests per second: 500
# Time per request: 20ms (mean)
# Transfer rate: 150 KB/sec
```

**Backend load test** with k6:

```javascript
// load-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '30s', target: 20 },  // Ramp up to 20 users
    { duration: '1m', target: 20 },   // Stay at 20 users
    { duration: '30s', target: 0 },   // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% requests < 500ms
  },
};

export default function () {
  const url = 'http://localhost:3000/api/projects';
  const payload = JSON.stringify({
    name: 'Load Test Project',
    namespace: `com.test.${__VU}_${__ITER}`,
    visibility: 'private',
  });
  
  const params = {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${__ENV.TOKEN}`,
    },
  };
  
  let response = http.post(url, payload, params);
  
  check(response, {
    'status is 201': (r) => r.status === 201,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
  
  sleep(1);
}
```

Run test:
```bash
k6 run -e TOKEN=$AUTH_TOKEN load-test.js
```

### Memory Profiling

**Backend memory profiling**:

```bash
# Using heaptrack
heaptrack ./target/release/stormforge-backend

# Run application, then stop
# Analyze results
heaptrack_gui heaptrack.stormforge-backend.*.gz
```

**Frontend memory profiling**:

```bash
# Run with performance overlay
flutter run --profile --enable-software-rendering

# Or use DevTools
flutter pub global activate devtools
devtools
```

---

## API Testing

### Manual API Testing with cURL

See [API Reference](./api-reference.md) for complete endpoint documentation.

**Example test workflow**:

```bash
#!/bin/bash
# api-test.sh - Manual API test script

BASE_URL="http://localhost:3000"

echo "=== API Test Workflow ==="

# 1. Register user
echo "1. Registering user..."
REGISTER_RESPONSE=$(curl -s -X POST $BASE_URL/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "apitest",
    "email": "apitest@example.com",
    "password": "TestPass123!",
    "displayName": "API Test User",
    "role": "developer"
  }')

echo $REGISTER_RESPONSE | jq '.'

# 2. Login
echo "2. Logging in..."
LOGIN_RESPONSE=$(curl -s -X POST $BASE_URL/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "usernameOrEmail": "apitest",
    "password": "TestPass123!"
  }')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.token')
echo "Token: $TOKEN"

# 3. Create project
echo "3. Creating project..."
PROJECT_RESPONSE=$(curl -s -X POST $BASE_URL/api/projects \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "API Test Project",
    "namespace": "com.test.apiproject",
    "visibility": "private"
  }')

PROJECT_ID=$(echo $PROJECT_RESPONSE | jq -r '.id')
echo "Project ID: $PROJECT_ID"

# 4. Create entity
echo "4. Creating entity..."
ENTITY_RESPONSE=$(curl -s -X POST $BASE_URL/api/projects/$PROJECT_ID/entities \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "TestEntity",
    "entityType": "entity",
    "properties": [
      {"name": "id", "type": "String", "identifier": true}
    ]
  }')

echo $ENTITY_RESPONSE | jq '.'

echo "=== Test Complete ==="
```

### Automated API Testing with Postman/Newman

**Postman Collection** (`stormforge-api-tests.json`):

```json
{
  "info": {
    "name": "StormForge API Tests",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Authentication",
      "item": [
        {
          "name": "Register User",
          "event": [
            {
              "listen": "test",
              "script": {
                "exec": [
                  "pm.test(\"Status code is 201\", function () {",
                  "    pm.response.to.have.status(201);",
                  "});",
                  "",
                  "pm.test(\"Response has token\", function () {",
                  "    var jsonData = pm.response.json();",
                  "    pm.expect(jsonData.token).to.be.a('string');",
                  "    pm.environment.set(\"auth_token\", jsonData.token);",
                  "});"
                ]
              }
            }
          ],
          "request": {
            "method": "POST",
            "header": [],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"username\": \"{{$randomUserName}}\",\n  \"email\": \"{{$randomEmail}}\",\n  \"password\": \"TestPass123!\",\n  \"displayName\": \"Test User\",\n  \"role\": \"developer\"\n}",
              "options": {
                "raw": {
                  "language": "json"
                }
              }
            },
            "url": {
              "raw": "{{base_url}}/api/auth/register",
              "host": ["{{base_url}}"],
              "path": ["api", "auth", "register"]
            }
          }
        }
      ]
    }
  ]
}
```

**Run with Newman**:

```bash
# Install Newman
npm install -g newman

# Run collection
newman run stormforge-api-tests.json \
  -e environment.json \
  --reporters cli,htmlextra \
  --reporter-htmlextra-export test-results.html
```

---

## End-to-End Testing

### Complete User Journey Tests

#### Test Scenario: New User to Code Generation

```
1. User registers account
2. User creates first project
3. User adds entities to canvas
4. User defines entity details
5. User creates connections
6. User exports IR
7. User generates code
8. User verifies generated code
```

**Automated E2E Test**:

```dart
// test/e2e/complete_workflow_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('Complete user workflow', (tester) async {
    // 1. Register and login
    await registerAndLogin(tester);
    
    // 2. Create project
    await createProject(tester, 'E2E Test Project');
    
    // 3. Add entities
    await addEntityToCanvas(tester, 'Command', 'PlaceOrder');
    await addEntityToCanvas(tester, 'Aggregate', 'Order');
    await addEntityToCanvas(tester, 'Event', 'OrderPlaced');
    
    // 4. Create connections
    await connectElements(tester, 'PlaceOrder', 'Order');
    await connectElements(tester, 'Order', 'OrderPlaced');
    
    // 5. Define entity details
    await openEntityEditor(tester, 'Order');
    await addPropertyToEntity(tester, 'id', 'OrderId');
    await addPropertyToEntity(tester, 'status', 'OrderStatus');
    await saveEntity(tester);
    
    // 6. Export IR
    await exportIR(tester);
    
    // Verify exported file exists
    expect(await fileExists('output/e2e_test_project.yaml'), isTrue);
    
    // 7. Validate IR content
    final irContent = await readFile('output/e2e_test_project.yaml');
    expect(irContent, contains('PlaceOrder'));
    expect(irContent, contains('Order'));
    expect(irContent, contains('OrderPlaced'));
  });
}
```

---

## Test Automation

### Continuous Integration

**GitHub Actions** (`.github/workflows/test.yml`):

```yaml
name: Test Suite

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  backend-tests:
    runs-on: ubuntu-latest
    
    services:
      mongodb:
        image: mongo:5.0
        ports:
          - 27017:27017
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Rust
        uses: actions-rs/toolchain@v1
        with:
          toolchain: stable
          
      - name: Run tests
        working-directory: ./stormforge_backend
        run: |
          cargo test --all-features
          cargo tarpaulin --out Xml
          
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./cobertura.xml
  
  frontend-tests:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          
      - name: Run tests
        working-directory: ./stormforge_modeler
        run: |
          flutter pub get
          flutter test --coverage
          
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

### Test Reports

Generate comprehensive test reports:

```bash
# Backend
cargo test -- --nocapture | tee test-output.log
cargo tarpaulin --out Html

# Frontend
flutter test --machine > test-results.json
flutter test --coverage
lcov --summary coverage/lcov.info
```

---

## Best Practices

### General Testing Principles

1. **Test Pyramid**: Most unit tests, fewer integration tests, minimal E2E
2. **Isolation**: Tests should not depend on each other
3. **Repeatability**: Tests should produce same results every time
4. **Fast Feedback**: Tests should run quickly
5. **Clear Assertions**: Test one thing per test
6. **Descriptive Names**: Test names should describe what is being tested

### Writing Good Tests

#### DO ✅

- Write tests before fixing bugs (regression tests)
- Use descriptive test names
- Follow Arrange-Act-Assert pattern
- Test edge cases and error conditions
- Mock external dependencies
- Clean up test data after tests

#### DON'T ❌

- Write tests that depend on external services
- Share state between tests
- Test implementation details
- Ignore flaky tests
- Skip writing tests for "simple" code
- Leave commented-out test code

### Test Naming Conventions

**Pattern**: `test_<action>_<condition>_<expected_result>`

**Examples**:
- `test_create_user_with_valid_data_returns_user`
- `test_create_user_with_duplicate_username_returns_error`
- `test_get_project_when_not_exists_returns_not_found`

### Test Organization

```
tests/
├── unit/
│   ├── models/
│   ├── services/
│   └── utils/
├── integration/
│   ├── api/
│   ├── database/
│   └── workflows/
├── e2e/
│   └── scenarios/
└── fixtures/
    ├── test_data.json
    └── mock_responses.json
```

---

## Appendix

### Test Checklist

Use this checklist before releasing:

#### Functionality
- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] All E2E tests pass
- [ ] Manual smoke testing complete

#### Performance
- [ ] Canvas renders 1000+ elements @60fps
- [ ] API response times < 500ms (p95)
- [ ] Memory usage within acceptable limits
- [ ] No memory leaks detected

#### Security
- [ ] Authentication working correctly
- [ ] Authorization rules enforced
- [ ] Input validation working
- [ ] No SQL injection vulnerabilities
- [ ] No XSS vulnerabilities

#### Compatibility
- [ ] Works on Chrome, Firefox, Safari, Edge
- [ ] Works on Windows, macOS, Linux
- [ ] Mobile responsive (if applicable)
- [ ] Accessibility requirements met

#### User Experience
- [ ] All UI elements functioning
- [ ] Error messages are clear
- [ ] Loading states displayed
- [ ] Keyboard navigation works
- [ ] No console errors

### Resources

- **Testing Documentation**: [Flutter Testing Guide](https://flutter.dev/docs/testing)
- **Rust Testing**: [The Rust Book - Testing](https://doc.rust-lang.org/book/ch11-00-testing.html)
- **API Testing**: [Postman Learning Center](https://learning.postman.com/)
- **Performance**: [Flutter Performance](https://flutter.dev/docs/perf)

---

**Testing Guide Version**: 2.0  
**Last Updated**: December 2025  
**Questions?** Refer to documentation or contact development team.

