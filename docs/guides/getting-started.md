# Getting Started Guide

> Your first steps with StormForge

## Introduction

Welcome to StormForge! This guide will help you understand the basics of domain modeling with StormForge and get you started on your first project.

## Prerequisites

Before you begin, make sure you have:

- Flutter SDK 3.24+ installed
- Rust 1.75+ installed
- Git installed
- A code editor (VS Code recommended)

## Understanding the Workflow

StormForge follows a simple workflow:

```
1. Model → 2. Generate → 3. Deploy → 4. Iterate
```

### 1. Model

Use the Flutter Modeler to create your domain model using EventStorming methodology:

- **Domain Events** (Orange): Things that happen in your domain
- **Commands** (Blue): Actions that cause events
- **Aggregates** (Yellow): Domain objects that handle commands
- **Policies** (Purple): Automated reactions to events
- **Read Models** (Green): Views of your data
- **External Systems** (Pink): Third-party integrations

### 2. Generate

From your model, StormForge generates:

- **Rust Microservices**: Complete backend services with Axum
- **Flutter API Packages**: Strongly-typed Dart packages for your frontend

### 3. Deploy

Deploy your generated services using:

- Docker images
- Kubernetes manifests
- Helm charts

### 4. Iterate

As your requirements evolve:

- Update your model in the modeler
- Regenerate code
- Only changes are updated (incremental generation)

## Your First Model

Let's create a simple "Todo List" domain:

### Step 1: Identify Domain Events

Think about what happens in your domain:

- `TodoCreated` - A new todo item was created
- `TodoCompleted` - A todo item was marked complete
- `TodoDeleted` - A todo item was deleted

### Step 2: Identify Commands

What actions cause these events?

- `CreateTodo` → `TodoCreated`
- `CompleteTodo` → `TodoCompleted`
- `DeleteTodo` → `TodoDeleted`

### Step 3: Identify Aggregates

What domain object handles these commands?

- `Todo` aggregate handles all todo-related commands

### Step 4: Define the Model

Your IR (Intermediate Representation) would look like:

```yaml
version: "1.0"

bounded_context:
  name: "Todo"
  namespace: "app.todo"

aggregates:
  Todo:
    name: "Todo"
    root_entity:
      name: "Todo"
      properties:
        - name: "id"
          type: "TodoId"
          identifier: true
        - name: "title"
          type: "String"
          required: true
        - name: "completed"
          type: "Boolean"
          default: false
        - name: "createdAt"
          type: "DateTime"

events:
  TodoCreated:
    name: "TodoCreated"
    payload:
      - name: "todoId"
        type: "TodoId"
      - name: "title"
        type: "String"
        
  TodoCompleted:
    name: "TodoCompleted"
    payload:
      - name: "todoId"
        type: "TodoId"

commands:
  CreateTodo:
    name: "CreateTodo"
    payload:
      - name: "title"
        type: "String"
        required: true
    produces:
      - "TodoCreated"
      
  CompleteTodo:
    name: "CompleteTodo"
    payload:
      - name: "todoId"
        type: "TodoId"
        required: true
    produces:
      - "TodoCompleted"
```

## Generated Code

### Rust Microservice

```rust
// Generated command handler
pub async fn create_todo(
    State(repo): State<TodoRepository>,
    Json(cmd): Json<CreateTodoCommand>,
) -> Result<Json<TodoCreated>, AppError> {
    let todo = Todo::create(cmd.title)?;
    repo.save(&todo).await?;
    Ok(Json(TodoCreated {
        todo_id: todo.id,
        title: todo.title,
    }))
}
```

### Flutter API Package

```dart
// Generated API client
class TodoService {
  Future<TodoCreated> createTodo(CreateTodoPayload payload) async {
    final response = await _client.post('/todos', body: payload.toJson());
    return TodoCreated.fromJson(response.data);
  }
  
  Future<void> completeTodo(String todoId) async {
    await _client.post('/todos/$todoId/complete');
  }
}

// Usage in your Flutter app
final todoService = TodoService(baseUrl: 'https://api.example.com');
final created = await todoService.createTodo(
  CreateTodoPayload(title: 'Learn StormForge'),
);
```

## Next Steps

1. **Explore Examples**: Check out the `ir_schema/examples/` directory
2. **Read the IR Specification**: See `ir_schema/docs/ir_specification.md`
3. **Try the Modeler**: Once available, use the visual modeler

## Getting Help

- Check the [FAQ](./faq.md)
- Read the [Architecture Guide](../ARCHITECTURE.md)
- Join our community (coming soon)

---

*Happy modeling with StormForge!*
