# StormForge API Reference

> **Version**: 2.0  
> **Base URL**: `http://localhost:3000` (development) or `https://api.yourdomain.com` (production)  
> **Last Updated**: December 2025

---

## Table of Contents

1. [Introduction](#introduction)
2. [Authentication](#authentication)
3. [Users API](#users-api)
4. [Projects API](#projects-api)
5. [Team Members API](#team-members-api)
6. [Entities API](#entities-api)
7. [Read Models API](#read-models-api)
8. [Commands API](#commands-api)
9. [Library API](#library-api)
10. [Error Handling](#error-handling)
11. [Rate Limiting](#rate-limiting)

---

## Introduction

### API Overview

The StormForge API is a RESTful API that provides programmatic access to all platform features:

- **Authentication**: User registration, login, JWT token management
- **Project Management**: CRUD operations for projects
- **Team Collaboration**: Team member management
- **Domain Modeling**: Entities, commands, read models
- **Global Library**: Component library management

### API Characteristics

- **Protocol**: HTTP/HTTPS
- **Format**: JSON
- **Authentication**: JWT Bearer tokens
- **Content-Type**: `application/json`
- **Character Encoding**: UTF-8

### Base URL

```
Development: http://localhost:3000
Production:  https://api.yourdomain.com
```

### API Versioning

Current version: **v1** (included in all endpoints)

```
/api/v1/users
/api/v1/projects
```

---

## Authentication

### Overview

StormForge uses **JWT (JSON Web Tokens)** for authentication:

1. User registers or logs in
2. Server returns JWT token
3. Client includes token in `Authorization` header for subsequent requests
4. Token expires after 24 hours (default)

### Register New User

**Endpoint**: `POST /api/auth/register`

**Description**: Create a new user account

**Request Body**:
```json
{
  "username": "john_doe",
  "email": "john@example.com",
  "displayName": "John Doe",
  "password": "SecurePassword123!",
  "role": "developer"
}
```

**Parameters**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| username | string | Yes | Unique username (3-30 chars, alphanumeric + underscore) |
| email | string | Yes | Valid email address |
| displayName | string | Yes | User's display name |
| password | string | Yes | Password (min 8 chars) |
| role | string | No | User role: `admin`, `manager`, `developer`, `viewer` (default: `developer`) |

**Response**: `201 Created`

```json
{
  "id": "user-1702291234567",
  "username": "john_doe",
  "email": "john@example.com",
  "displayName": "John Doe",
  "role": "developer",
  "createdAt": "2025-12-09T10:30:45.123Z",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Example**:
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_doe",
    "email": "john@example.com",
    "displayName": "John Doe",
    "password": "SecurePassword123!",
    "role": "developer"
  }'
```

---

### Login

**Endpoint**: `POST /api/auth/login`

**Description**: Authenticate and receive JWT token

**Request Body**:
```json
{
  "usernameOrEmail": "john_doe",
  "password": "SecurePassword123!"
}
```

**Parameters**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| usernameOrEmail | string | Yes | Username or email address |
| password | string | Yes | User's password |

**Response**: `200 OK`

```json
{
  "id": "user-1702291234567",
  "username": "john_doe",
  "email": "john@example.com",
  "displayName": "John Doe",
  "role": "developer",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresAt": "2025-12-10T10:30:45.123Z"
}
```

**Example**:
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "usernameOrEmail": "john_doe",
    "password": "SecurePassword123!"
  }'
```

**Save the token**:
```bash
TOKEN=$(curl -s -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"usernameOrEmail":"john_doe","password":"SecurePassword123!"}' \
  | jq -r '.token')
```

---

### Using Authentication Token

Include token in `Authorization` header for all authenticated requests:

```bash
curl -X GET http://localhost:3000/api/users/me \
  -H "Authorization: Bearer $TOKEN"
```

**Header Format**:
```
Authorization: Bearer <token>
```

---

## Users API

### Get Current User

**Endpoint**: `GET /api/users/me`

**Description**: Get authenticated user's profile

**Authentication**: Required

**Response**: `200 OK`

```json
{
  "id": "user-1702291234567",
  "username": "john_doe",
  "email": "john@example.com",
  "displayName": "John Doe",
  "role": "developer",
  "createdAt": "2025-12-09T10:30:45.123Z",
  "updatedAt": "2025-12-09T10:30:45.123Z"
}
```

**Example**:
```bash
curl -X GET http://localhost:3000/api/users/me \
  -H "Authorization: Bearer $TOKEN"
```

---

### List All Users

**Endpoint**: `GET /api/users`

**Description**: Get list of all users (admin only)

**Authentication**: Required (admin role)

**Query Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| page | integer | No | Page number (default: 1) |
| limit | integer | No | Results per page (default: 20, max: 100) |
| role | string | No | Filter by role |
| search | string | No | Search by username or email |

**Response**: `200 OK`

```json
{
  "users": [
    {
      "id": "user-1702291234567",
      "username": "john_doe",
      "email": "john@example.com",
      "displayName": "John Doe",
      "role": "developer",
      "createdAt": "2025-12-09T10:30:45.123Z"
    },
    {
      "id": "user-1702291234568",
      "username": "jane_smith",
      "email": "jane@example.com",
      "displayName": "Jane Smith",
      "role": "manager",
      "createdAt": "2025-12-09T11:20:30.456Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "totalPages": 3
  }
}
```

**Example**:
```bash
curl -X GET "http://localhost:3000/api/users?page=1&limit=20&role=developer" \
  -H "Authorization: Bearer $TOKEN"
```

---

### Get User by ID

**Endpoint**: `GET /api/users/{id}`

**Description**: Get user details by ID

**Authentication**: Required

**Path Parameters**:

| Parameter | Type | Description |
|-----------|------|-------------|
| id | string | User ID |

**Response**: `200 OK`

```json
{
  "id": "user-1702291234567",
  "username": "john_doe",
  "email": "john@example.com",
  "displayName": "John Doe",
  "role": "developer",
  "createdAt": "2025-12-09T10:30:45.123Z",
  "updatedAt": "2025-12-09T10:30:45.123Z"
}
```

**Example**:
```bash
curl -X GET http://localhost:3000/api/users/user-1702291234567 \
  -H "Authorization: Bearer $TOKEN"
```

---

### Update User

**Endpoint**: `PUT /api/users/{id}`

**Description**: Update user details (own profile or admin)

**Authentication**: Required

**Path Parameters**:

| Parameter | Type | Description |
|-----------|------|-------------|
| id | string | User ID |

**Request Body**:
```json
{
  "displayName": "John Doe Jr.",
  "email": "john.doe@example.com",
  "role": "manager"
}
```

**Fields** (all optional):

| Field | Type | Description |
|-------|------|-------------|
| displayName | string | New display name |
| email | string | New email address |
| role | string | New role (admin only) |

**Response**: `200 OK`

```json
{
  "id": "user-1702291234567",
  "username": "john_doe",
  "email": "john.doe@example.com",
  "displayName": "John Doe Jr.",
  "role": "manager",
  "updatedAt": "2025-12-09T12:00:00.000Z"
}
```

**Example**:
```bash
curl -X PUT http://localhost:3000/api/users/user-1702291234567 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "displayName": "John Doe Jr.",
    "email": "john.doe@example.com"
  }'
```

---

## Projects API

### Create Project

**Endpoint**: `POST /api/projects`

**Description**: Create a new project

**Authentication**: Required

**Request Body**:
```json
{
  "name": "E-commerce Platform",
  "namespace": "com.acme.ecommerce",
  "description": "Customer-facing e-commerce platform",
  "visibility": "private"
}
```

**Parameters**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| name | string | Yes | Project name |
| namespace | string | Yes | Unique namespace (dot-separated, lowercase) |
| description | string | No | Project description |
| visibility | string | No | `private`, `team`, `public` (default: `private`) |

**Response**: `201 Created`

```json
{
  "id": "proj-1702291234567",
  "name": "E-commerce Platform",
  "namespace": "com.acme.ecommerce",
  "description": "Customer-facing e-commerce platform",
  "visibility": "private",
  "ownerId": "user-1702291234567",
  "createdAt": "2025-12-09T10:30:45.123Z",
  "updatedAt": "2025-12-09T10:30:45.123Z"
}
```

**Example**:
```bash
curl -X POST http://localhost:3000/api/projects \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "E-commerce Platform",
    "namespace": "com.acme.ecommerce",
    "description": "Customer-facing e-commerce platform",
    "visibility": "private"
  }'
```

---

### Get Project

**Endpoint**: `GET /api/projects/{id}`

**Description**: Get project details by ID

**Authentication**: Required

**Path Parameters**:

| Parameter | Type | Description |
|-----------|------|-------------|
| id | string | Project ID |

**Response**: `200 OK`

```json
{
  "id": "proj-1702291234567",
  "name": "E-commerce Platform",
  "namespace": "com.acme.ecommerce",
  "description": "Customer-facing e-commerce platform",
  "visibility": "private",
  "ownerId": "user-1702291234567",
  "settings": {
    "gitRepository": "https://github.com/acme/ecommerce",
    "gitBranch": "main",
    "aiProvider": "claude",
    "autoCommit": true
  },
  "createdAt": "2025-12-09T10:30:45.123Z",
  "updatedAt": "2025-12-09T10:30:45.123Z"
}
```

**Example**:
```bash
curl -X GET http://localhost:3000/api/projects/proj-1702291234567 \
  -H "Authorization: Bearer $TOKEN"
```

---

### List Projects by Owner

**Endpoint**: `GET /api/projects/owner/{owner_id}`

**Description**: List all projects owned by a user

**Authentication**: Required

**Path Parameters**:

| Parameter | Type | Description |
|-----------|------|-------------|
| owner_id | string | Owner user ID |

**Query Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| page | integer | No | Page number (default: 1) |
| limit | integer | No | Results per page (default: 20, max: 100) |

**Response**: `200 OK`

```json
{
  "projects": [
    {
      "id": "proj-1702291234567",
      "name": "E-commerce Platform",
      "namespace": "com.acme.ecommerce",
      "description": "Customer-facing e-commerce platform",
      "visibility": "private",
      "ownerId": "user-1702291234567",
      "createdAt": "2025-12-09T10:30:45.123Z"
    },
    {
      "id": "proj-1702291234568",
      "name": "HR System",
      "namespace": "com.acme.hr",
      "description": "Internal HR management system",
      "visibility": "team",
      "ownerId": "user-1702291234567",
      "createdAt": "2025-12-08T14:20:30.456Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 2,
    "totalPages": 1
  }
}
```

**Example**:
```bash
curl -X GET http://localhost:3000/api/projects/owner/user-1702291234567 \
  -H "Authorization: Bearer $TOKEN"
```

---

### Update Project

**Endpoint**: `PUT /api/projects/{id}`

**Description**: Update project details

**Authentication**: Required (project owner or admin)

**Path Parameters**:

| Parameter | Type | Description |
|-----------|------|-------------|
| id | string | Project ID |

**Request Body**:
```json
{
  "name": "E-commerce Platform v2",
  "description": "Revamped e-commerce platform",
  "visibility": "team",
  "settings": {
    "gitRepository": "https://github.com/acme/ecommerce-v2",
    "gitBranch": "develop",
    "aiProvider": "grok",
    "autoCommit": true
  }
}
```

**Fields** (all optional):

| Field | Type | Description |
|-------|------|-------------|
| name | string | New project name |
| description | string | New description |
| visibility | string | New visibility setting |
| settings | object | Project settings |

**Response**: `200 OK`

```json
{
  "id": "proj-1702291234567",
  "name": "E-commerce Platform v2",
  "namespace": "com.acme.ecommerce",
  "description": "Revamped e-commerce platform",
  "visibility": "team",
  "settings": {
    "gitRepository": "https://github.com/acme/ecommerce-v2",
    "gitBranch": "develop",
    "aiProvider": "grok",
    "autoCommit": true
  },
  "updatedAt": "2025-12-09T12:00:00.000Z"
}
```

**Example**:
```bash
curl -X PUT http://localhost:3000/api/projects/proj-1702291234567 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "E-commerce Platform v2",
    "description": "Revamped e-commerce platform"
  }'
```

---

### Delete Project

**Endpoint**: `DELETE /api/projects/{id}`

**Description**: Delete a project (owner only)

**Authentication**: Required (project owner)

**Path Parameters**:

| Parameter | Type | Description |
|-----------|------|-------------|
| id | string | Project ID |

**Response**: `204 No Content`

**Example**:
```bash
curl -X DELETE http://localhost:3000/api/projects/proj-1702291234567 \
  -H "Authorization: Bearer $TOKEN"
```

---

## Team Members API

### Add Team Member

**Endpoint**: `POST /api/projects/{project_id}/members`

**Description**: Add a user to project team

**Authentication**: Required (project owner or maintainer)

**Path Parameters**:

| Parameter | Type | Description |
|-----------|------|-------------|
| project_id | string | Project ID |

**Request Body**:
```json
{
  "userId": "user-1702291234568",
  "role": "developer"
}
```

**Parameters**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| userId | string | Yes | User ID to add |
| role | string | Yes | Project role: `owner`, `maintainer`, `developer`, `viewer` |

**Response**: `201 Created`

```json
{
  "id": "member-1702291234567",
  "projectId": "proj-1702291234567",
  "userId": "user-1702291234568",
  "role": "developer",
  "addedBy": "user-1702291234567",
  "addedAt": "2025-12-09T10:30:45.123Z"
}
```

**Example**:
```bash
curl -X POST http://localhost:3000/api/projects/proj-1702291234567/members \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user-1702291234568",
    "role": "developer"
  }'
```

---

### List Team Members

**Endpoint**: `GET /api/projects/{project_id}/members`

**Description**: List all team members of a project

**Authentication**: Required

**Path Parameters**:

| Parameter | Type | Description |
|-----------|------|-------------|
| project_id | string | Project ID |

**Response**: `200 OK`

```json
{
  "members": [
    {
      "id": "member-1702291234567",
      "projectId": "proj-1702291234567",
      "userId": "user-1702291234567",
      "role": "owner",
      "user": {
        "username": "john_doe",
        "displayName": "John Doe",
        "email": "john@example.com"
      },
      "addedAt": "2025-12-09T10:30:45.123Z"
    },
    {
      "id": "member-1702291234568",
      "projectId": "proj-1702291234567",
      "userId": "user-1702291234568",
      "role": "developer",
      "user": {
        "username": "jane_smith",
        "displayName": "Jane Smith",
        "email": "jane@example.com"
      },
      "addedBy": "user-1702291234567",
      "addedAt": "2025-12-09T11:00:00.000Z"
    }
  ],
  "total": 2
}
```

**Example**:
```bash
curl -X GET http://localhost:3000/api/projects/proj-1702291234567/members \
  -H "Authorization: Bearer $TOKEN"
```

---

### Update Team Member Role

**Endpoint**: `PUT /api/projects/{project_id}/members/{user_id}`

**Description**: Update team member's role

**Authentication**: Required (project owner)

**Path Parameters**:

| Parameter | Type | Description |
|-----------|------|-------------|
| project_id | string | Project ID |
| user_id | string | User ID |

**Request Body**:
```json
{
  "role": "maintainer"
}
```

**Response**: `200 OK`

```json
{
  "id": "member-1702291234568",
  "projectId": "proj-1702291234567",
  "userId": "user-1702291234568",
  "role": "maintainer",
  "updatedAt": "2025-12-09T12:00:00.000Z"
}
```

**Example**:
```bash
curl -X PUT http://localhost:3000/api/projects/proj-1702291234567/members/user-1702291234568 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"role": "maintainer"}'
```

---

### Remove Team Member

**Endpoint**: `DELETE /api/projects/{project_id}/members/{user_id}`

**Description**: Remove user from project team

**Authentication**: Required (project owner)

**Path Parameters**:

| Parameter | Type | Description |
|-----------|------|-------------|
| project_id | string | Project ID |
| user_id | string | User ID to remove |

**Response**: `204 No Content`

**Example**:
```bash
curl -X DELETE http://localhost:3000/api/projects/proj-1702291234567/members/user-1702291234568 \
  -H "Authorization: Bearer $TOKEN"
```

---

## Entities API

### Create Entity

**Endpoint**: `POST /api/projects/{project_id}/entities`

**Description**: Create a new entity definition

**Authentication**: Required

**Path Parameters**:

| Parameter | Type | Description |
|-----------|------|-------------|
| project_id | string | Project ID |

**Request Body**:
```json
{
  "name": "OrderEntity",
  "entityType": "aggregate_root",
  "description": "Order aggregate root entity",
  "properties": [
    {
      "name": "id",
      "type": "OrderId",
      "identifier": true,
      "required": true
    },
    {
      "name": "status",
      "type": "OrderStatus",
      "required": true,
      "default": "Draft"
    },
    {
      "name": "totalAmount",
      "type": "Money",
      "required": true,
      "validation": {
        "min": 0,
        "max": 1000000
      }
    }
  ],
  "methods": [
    {
      "name": "create",
      "methodType": "constructor",
      "parameters": [
        {"name": "customerId", "type": "CustomerId"},
        {"name": "items", "type": "List<OrderItem>"}
      ],
      "returnType": "OrderEntity"
    }
  ],
  "invariants": [
    {
      "name": "OrderMustHaveItems",
      "expression": "items.length > 0",
      "message": "Order must contain at least one item"
    }
  ]
}
```

**Response**: `201 Created`

```json
{
  "id": "entity-1702291234567",
  "projectId": "proj-1702291234567",
  "name": "OrderEntity",
  "entityType": "aggregate_root",
  "description": "Order aggregate root entity",
  "properties": [...],
  "methods": [...],
  "invariants": [...],
  "createdAt": "2025-12-09T10:30:45.123Z",
  "updatedAt": "2025-12-09T10:30:45.123Z"
}
```

**Example**:
```bash
curl -X POST http://localhost:3000/api/projects/proj-1702291234567/entities \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d @entity.json
```

---

### Get Entity

**Endpoint**: `GET /api/projects/{project_id}/entities/{entity_id}`

**Description**: Get entity definition by ID

**Authentication**: Required

**Response**: `200 OK`

```json
{
  "id": "entity-1702291234567",
  "projectId": "proj-1702291234567",
  "name": "OrderEntity",
  "entityType": "aggregate_root",
  "description": "Order aggregate root entity",
  "properties": [
    {
      "name": "id",
      "type": "OrderId",
      "identifier": true,
      "required": true
    }
  ],
  "methods": [
    {
      "name": "create",
      "methodType": "constructor",
      "parameters": []
    }
  ],
  "invariants": [
    {
      "name": "OrderMustHaveItems",
      "expression": "items.length > 0"
    }
  ],
  "createdAt": "2025-12-09T10:30:45.123Z",
  "updatedAt": "2025-12-09T10:30:45.123Z"
}
```

---

### List Entities

**Endpoint**: `GET /api/projects/{project_id}/entities`

**Description**: List all entities in a project

**Authentication**: Required

**Query Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| entityType | string | No | Filter by type: `entity`, `aggregate_root`, `value_object` |
| search | string | No | Search by name |

**Response**: `200 OK`

```json
{
  "entities": [
    {
      "id": "entity-1702291234567",
      "name": "OrderEntity",
      "entityType": "aggregate_root",
      "propertyCount": 5,
      "methodCount": 3,
      "createdAt": "2025-12-09T10:30:45.123Z"
    },
    {
      "id": "entity-1702291234568",
      "name": "CustomerEntity",
      "entityType": "entity",
      "propertyCount": 8,
      "methodCount": 2,
      "createdAt": "2025-12-09T11:00:00.000Z"
    }
  ],
  "total": 2
}
```

---

### Update Entity

**Endpoint**: `PUT /api/projects/{project_id}/entities/{entity_id}`

**Description**: Update entity definition

**Authentication**: Required

**Request Body**: Same as Create Entity (all fields optional)

**Response**: `200 OK`

---

### Delete Entity

**Endpoint**: `DELETE /api/projects/{project_id}/entities/{entity_id}`

**Description**: Delete entity definition

**Authentication**: Required

**Response**: `204 No Content`

---

## Read Models API

### Create Read Model

**Endpoint**: `POST /api/projects/{project_id}/read-models`

**Description**: Create a new read model definition

**Authentication**: Required

**Request Body**:
```json
{
  "name": "OrderSummary",
  "description": "Summary view of orders",
  "sources": [
    {
      "entityId": "entity-1702291234567",
      "alias": "order"
    },
    {
      "entityId": "entity-1702291234568",
      "alias": "customer",
      "joinCondition": {
        "type": "inner",
        "leftField": "order.customerId",
        "rightField": "customer.id"
      }
    }
  ],
  "fields": [
    {
      "name": "orderId",
      "type": "OrderId",
      "source": {
        "type": "entity_property",
        "propertyPath": "order.id"
      }
    },
    {
      "name": "customerName",
      "type": "String",
      "source": {
        "type": "entity_property",
        "propertyPath": "customer.name"
      }
    },
    {
      "name": "itemCount",
      "type": "Integer",
      "source": {
        "type": "computed",
        "expression": "order.items.length"
      }
    }
  ]
}
```

**Response**: `201 Created`

```json
{
  "id": "readmodel-1702291234567",
  "projectId": "proj-1702291234567",
  "name": "OrderSummary",
  "description": "Summary view of orders",
  "sources": [...],
  "fields": [...],
  "createdAt": "2025-12-09T10:30:45.123Z"
}
```

---

### Get Read Model

**Endpoint**: `GET /api/projects/{project_id}/read-models/{readmodel_id}`

**Description**: Get read model definition by ID

**Authentication**: Required

**Response**: `200 OK`

---

### List Read Models

**Endpoint**: `GET /api/projects/{project_id}/read-models`

**Description**: List all read models in a project

**Authentication**: Required

**Response**: `200 OK`

```json
{
  "readModels": [
    {
      "id": "readmodel-1702291234567",
      "name": "OrderSummary",
      "description": "Summary view of orders",
      "fieldCount": 5,
      "sourceCount": 2,
      "createdAt": "2025-12-09T10:30:45.123Z"
    }
  ],
  "total": 1
}
```

---

### Update Read Model

**Endpoint**: `PUT /api/projects/{project_id}/read-models/{readmodel_id}`

**Description**: Update read model definition

**Authentication**: Required

**Response**: `200 OK`

---

### Delete Read Model

**Endpoint**: `DELETE /api/projects/{project_id}/read-models/{readmodel_id}`

**Description**: Delete read model definition

**Authentication**: Required

**Response**: `204 No Content`

---

## Commands API

### Create Command

**Endpoint**: `POST /api/projects/{project_id}/commands`

**Description**: Create a new command definition

**Authentication**: Required

**Request Body**:
```json
{
  "name": "PlaceOrder",
  "description": "Place a new order",
  "aggregateId": "entity-1702291234567",
  "payload": [
    {
      "name": "customerId",
      "type": "CustomerId",
      "required": true,
      "source": {
        "type": "custom",
        "description": "From UI input"
      }
    },
    {
      "name": "items",
      "type": "List<OrderItem>",
      "required": true,
      "source": {
        "type": "custom",
        "description": "From cart"
      }
    }
  ],
  "preConditions": [
    {
      "name": "CustomerExists",
      "expression": "customer != null",
      "message": "Customer must exist"
    }
  ],
  "producedEvents": ["OrderPlaced", "InventoryReserved"]
}
```

**Response**: `201 Created`

```json
{
  "id": "command-1702291234567",
  "projectId": "proj-1702291234567",
  "name": "PlaceOrder",
  "aggregateId": "entity-1702291234567",
  "payload": [...],
  "preConditions": [...],
  "producedEvents": [...],
  "createdAt": "2025-12-09T10:30:45.123Z"
}
```

---

### Get Command

**Endpoint**: `GET /api/projects/{project_id}/commands/{command_id}`

**Description**: Get command definition by ID

**Authentication**: Required

**Response**: `200 OK`

---

### List Commands

**Endpoint**: `GET /api/projects/{project_id}/commands`

**Description**: List all commands in a project

**Authentication**: Required

**Response**: `200 OK`

```json
{
  "commands": [
    {
      "id": "command-1702291234567",
      "name": "PlaceOrder",
      "aggregateId": "entity-1702291234567",
      "payloadFieldCount": 2,
      "createdAt": "2025-12-09T10:30:45.123Z"
    }
  ],
  "total": 1
}
```

---

### Update Command

**Endpoint**: `PUT /api/projects/{project_id}/commands/{command_id}`

**Description**: Update command definition

**Authentication**: Required

**Response**: `200 OK`

---

### Delete Command

**Endpoint**: `DELETE /api/projects/{project_id}/commands/{command_id}`

**Description**: Delete command definition

**Authentication**: Required

**Response**: `204 No Content`

---

## Library API

### List Library Components

**Endpoint**: `GET /api/library/components`

**Description**: List global library components

**Authentication**: Required

**Query Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| scope | string | No | Filter by scope: `enterprise`, `organization`, `project` |
| type | string | No | Filter by type: `entity`, `command`, `read_model`, `value_object` |
| category | string | No | Filter by category |
| search | string | No | Search by name |

**Response**: `200 OK`

```json
{
  "components": [
    {
      "id": "lib-1702291234567",
      "name": "Money",
      "type": "value_object",
      "scope": "enterprise",
      "category": "common",
      "description": "Money value object with amount and currency",
      "version": "1.0.0",
      "usageCount": 47,
      "createdAt": "2025-11-01T00:00:00.000Z"
    },
    {
      "id": "lib-1702291234568",
      "name": "Email",
      "type": "value_object",
      "scope": "enterprise",
      "category": "common",
      "description": "Email address with validation",
      "version": "1.0.0",
      "usageCount": 89,
      "createdAt": "2025-11-01T00:00:00.000Z"
    }
  ],
  "total": 2
}
```

**Example**:
```bash
curl -X GET "http://localhost:3000/api/library/components?scope=enterprise&type=value_object" \
  -H "Authorization: Bearer $TOKEN"
```

---

### Get Library Component

**Endpoint**: `GET /api/library/components/{component_id}`

**Description**: Get library component details

**Authentication**: Required

**Response**: `200 OK`

```json
{
  "id": "lib-1702291234567",
  "name": "Money",
  "type": "value_object",
  "scope": "enterprise",
  "category": "common",
  "description": "Money value object with amount and currency",
  "version": "1.0.0",
  "definition": {
    "properties": [
      {"name": "amount", "type": "Decimal"},
      {"name": "currency", "type": "Currency"}
    ]
  },
  "usageCount": 47,
  "publishedBy": "user-1702291234567",
  "createdAt": "2025-11-01T00:00:00.000Z"
}
```

---

### Publish to Library

**Endpoint**: `POST /api/library/components`

**Description**: Publish a component to global library

**Authentication**: Required

**Request Body**:
```json
{
  "name": "CustomerEntity",
  "type": "entity",
  "scope": "organization",
  "category": "customer",
  "description": "Standard customer entity",
  "version": "1.0.0",
  "sourceType": "entity",
  "sourceId": "entity-1702291234567"
}
```

**Response**: `201 Created`

```json
{
  "id": "lib-1702291234569",
  "name": "CustomerEntity",
  "type": "entity",
  "scope": "organization",
  "publishedAt": "2025-12-09T10:30:45.123Z"
}
```

---

## Error Handling

### Error Response Format

All errors follow a consistent format:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": {
      "field": "Additional error details"
    }
  }
}
```

### HTTP Status Codes

| Code | Meaning | Description |
|------|---------|-------------|
| 200 | OK | Request successful |
| 201 | Created | Resource created successfully |
| 204 | No Content | Request successful, no content returned |
| 400 | Bad Request | Invalid request parameters |
| 401 | Unauthorized | Authentication required or invalid |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource not found |
| 409 | Conflict | Resource already exists (duplicate) |
| 422 | Unprocessable Entity | Validation error |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Server error |
| 503 | Service Unavailable | Service temporarily unavailable |

### Common Error Codes

| Code | Description |
|------|-------------|
| `AUTH_REQUIRED` | Authentication token required |
| `INVALID_TOKEN` | Invalid or expired JWT token |
| `INSUFFICIENT_PERMISSIONS` | User lacks required permissions |
| `USER_NOT_FOUND` | User does not exist |
| `PROJECT_NOT_FOUND` | Project does not exist |
| `ENTITY_NOT_FOUND` | Entity does not exist |
| `DUPLICATE_USERNAME` | Username already taken |
| `DUPLICATE_EMAIL` | Email already registered |
| `DUPLICATE_NAMESPACE` | Project namespace already exists |
| `VALIDATION_ERROR` | Request validation failed |
| `RATE_LIMIT_EXCEEDED` | Too many requests |

### Error Examples

**Authentication Error**:
```json
{
  "error": {
    "code": "INVALID_TOKEN",
    "message": "JWT token is invalid or expired"
  }
}
```

**Validation Error**:
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": {
      "username": "Username must be 3-30 characters",
      "email": "Invalid email format"
    }
  }
}
```

**Not Found Error**:
```json
{
  "error": {
    "code": "PROJECT_NOT_FOUND",
    "message": "Project with ID 'proj-invalid' not found"
  }
}
```

---

## Rate Limiting

### Rate Limit Rules

Default rate limits per user:

| Endpoint Category | Limit |
|-------------------|-------|
| Authentication | 10 requests per minute |
| Read operations (GET) | 100 requests per minute |
| Write operations (POST/PUT/DELETE) | 30 requests per minute |

### Rate Limit Headers

Responses include rate limit information:

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1702291345
```

### Rate Limit Exceeded

**Response**: `429 Too Many Requests`

```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Rate limit exceeded. Please try again later.",
    "retryAfter": 45
  }
}
```

---

## Appendix

### Pagination

Endpoints that return lists support pagination:

**Query Parameters**:
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 20, max: 100)

**Response includes**:
```json
{
  "items": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "totalPages": 8
  }
}
```

### Filtering and Sorting

Many list endpoints support filtering and sorting:

**Query Parameters**:
- `sort`: Field to sort by
- `order`: Sort order (`asc` or `desc`)
- `filter[field]`: Filter by field value

**Example**:
```bash
curl "http://localhost:3000/api/projects?sort=createdAt&order=desc&filter[visibility]=private"
```

### Timestamps

All timestamps are in ISO 8601 format with UTC timezone:

```
2025-12-09T10:30:45.123Z
```

### Content Negotiation

All requests and responses use JSON:

**Request**:
```
Content-Type: application/json
Accept: application/json
```

---

**API Reference Version**: 2.0  
**Last Updated**: December 2025  
**OpenAPI Spec**: Available at `/api-docs/openapi.json`

