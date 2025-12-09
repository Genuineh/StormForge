# StormForge User Guide

> **Version**: 2.0 (Modeler 2.0)  
> **Last Updated**: December 2025  
> **Audience**: Domain modelers, business analysts, developers

---

## Table of Contents

1. [Introduction](#introduction)
2. [Getting Started](#getting-started)
3. [Project Management](#project-management)
4. [Canvas Modeling](#canvas-modeling)
5. [Entity Modeling](#entity-modeling)
6. [Read Model Designer](#read-model-designer)
7. [Command Data Model Designer](#command-data-model-designer)
8. [Component Connections](#component-connections)
9. [Global Library](#global-library)
10. [IR Export and Import](#ir-export-and-import)
11. [Team Collaboration](#team-collaboration)
12. [Tips and Best Practices](#tips-and-best-practices)

---

## Introduction

### What is StormForge?

StormForge is an enterprise-grade visual domain modeling platform that combines:

- **EventStorming Canvas**: Visual domain modeling using EventStorming methodology
- **Entity Modeling System**: Detailed entity definitions with properties, methods, and invariants
- **Read Model Designer**: Visual tool for designing query projections from entities
- **Command Designer**: Command payload design with data source mapping
- **Code Generation**: Automatic generation of Rust microservices and Flutter API packages
- **Team Collaboration**: Multi-user project management with role-based permissions

### Key Features

- **Visual-First Modeling**: Drag-and-drop canvas for creating domain models
- **Separation of Concerns**: Canvas for high-level design, dedicated editors for detailed definitions
- **Type Safety**: Strong typing throughout the modeling process
- **Version Control**: Git integration for model versioning
- **Global Library**: Reusable component library across projects
- **Multi-Platform**: Works on Web, Windows, macOS, and eventually iPad

### Workflow Overview

```
1. Create Project → 2. Model on Canvas → 3. Define Details → 4. Export IR → 5. Generate Code
```

---

## Getting Started

### Prerequisites

- Modern web browser (Chrome, Firefox, Safari, Edge)
- Or desktop application (Windows/macOS)
- StormForge backend server running (for team features)

### First Login

1. **Launch StormForge** - Open the application in your browser or desktop
2. **Register/Login**:
   - Click "Sign Up" to create an account
   - Enter username, email, display name, and password
   - Or login with existing credentials

3. **Create Your First Project**:
   - Click "New Project" button
   - Enter project name (e.g., "E-commerce Platform")
   - Enter namespace (e.g., "com.acme.ecommerce")
   - Add description (optional)
   - Choose visibility (Private/Team/Public)

### Understanding the Interface

```
┌─────────────────────────────────────────────────────────────┐
│ Header: Project Name | Save | Export | Settings             │
├──────────┬───────────────────────────────────┬──────────────┤
│          │                                   │              │
│ Project  │         Canvas                    │  Properties  │
│ Tree     │         (Main workspace)          │  Panel       │
│          │                                   │              │
│ - Models │                                   │  - Element   │
│ - Entities│                                  │    Details   │
│ - Commands│                                  │  - Links     │
│ - Read   │                                   │  - Settings  │
│   Models │                                   │              │
│          │                                   │              │
└──────────┴───────────────────────────────────┴──────────────┘
```

---

## Project Management

### Creating a Project

**Steps**:

1. Click **"New Project"** button on home screen
2. Fill in project details:
   ```
   Name:        My E-commerce Platform
   Namespace:   com.mycompany.ecommerce
   Description: Customer-facing e-commerce platform
   Visibility:  Private
   ```
3. Configure optional settings:
   - Git integration (repository URL, branch)
   - AI assistant settings (API keys)
4. Click **"Create"**

### Project Settings

Access project settings via **Settings** icon in the header.

#### General Settings

- **Project Name**: Display name
- **Namespace**: Code generation namespace (e.g., `com.acme.order`)
- **Description**: Project description
- **Visibility**: Private, Team, or Public

#### Git Integration

- **Repository URL**: Git repository for version control
- **Branch**: Default branch name
- **Auto-commit**: Enable automatic commits on save
- **Commit Message Template**: Template for auto-commit messages

#### AI Assistant Settings

- **AI Provider**: Claude 3.5, Grok, or 通义千问
- **API Key**: Your API key for AI features
- **Model Generation**: Enable/disable AI model generation

### Opening Projects

1. On home screen, view list of your projects
2. Click on a project card to open it
3. Or use **File > Recent Projects** menu

---

## Canvas Modeling

### EventStorming Elements

StormForge supports 8 types of EventStorming elements:

#### 1. Domain Events (Orange) 🟧

**What**: Something that happened in the domain

**When to Use**: After identifying business processes

**Example**: `OrderPlaced`, `PaymentReceived`, `OrderShipped`

**How to Add**:
1. Select **Event** tool from toolbar (or press `E`)
2. Click on canvas to place
3. Enter event name in past tense
4. Add description and properties in property panel

#### 2. Commands (Blue) 🟦

**What**: Actions that users or systems can perform

**When to Use**: User intentions that cause events

**Example**: `PlaceOrder`, `CancelOrder`, `ProcessPayment`

**How to Add**:
1. Select **Command** tool (or press `C`)
2. Click to place on canvas
3. Enter command name as imperative verb
4. Link to command definition for detailed payload

#### 3. Aggregates (Yellow) 🟨

**What**: Domain objects that handle commands and produce events

**When to Use**: Grouping related entities and behaviors

**Example**: `Order`, `Customer`, `Product`

**How to Add**:
1. Select **Aggregate** tool (or press `A`)
2. Click to place
3. Enter aggregate name as noun
4. Link to entity definition for detailed structure

#### 4. Policies (Purple) 🟪

**What**: Automated reactions to events

**When to Use**: Event-driven business rules

**Example**: "When OrderPaid → Notify Warehouse"

**How to Add**:
1. Select **Policy** tool (or press `P`)
2. Click to place
3. Define policy name and condition
4. Connect triggering event to policy

#### 5. Read Models (Green) 🟩

**What**: Views of data for queries

**When to Use**: Designing query results

**Example**: `OrderSummary`, `CustomerProfile`, `InventoryStatus`

**How to Add**:
1. Select **Read Model** tool (or press `R`)
2. Click to place
3. Enter read model name
4. Use Read Model Designer to define fields

#### 6. External Systems (Pink) 🟥

**What**: Third-party services or legacy systems

**When to Use**: External integrations

**Example**: `PaymentGateway`, `EmailService`, `InventorySystem`

**How to Add**:
1. Select **External System** tool (or press `X`)
2. Click to place
3. Enter system name
4. Document API contract in properties

#### 7. UI Components (White) ⬜

**What**: User interface screens or components

**When to Use**: Linking UI to domain actions

**Example**: `CheckoutPage`, `OrderHistoryScreen`

**How to Add**:
1. Select **UI** tool (or press `U`)
2. Click to place
3. Enter UI component name

#### 8. Timers (Clock) ⏰

**What**: Time-based triggers

**When to Use**: Scheduled operations

**Example**: `DailyReport`, `OrderExpiryCheck`

**How to Add**:
1. Select **Timer** tool (or press `T`)
2. Click to place
3. Define timer schedule

### Canvas Operations

#### Moving Elements

- **Single**: Click and drag
- **Multiple**: Select multiple (Shift+Click or drag-select box), then drag

#### Resizing Elements

- Select element
- Drag resize handles at corners

#### Deleting Elements

- Select element(s)
- Press `Delete` or `Backspace`
- Or right-click → Delete

#### Zooming and Panning

- **Zoom In**: `Ctrl` + `+` or mouse wheel up
- **Zoom Out**: `Ctrl` + `-` or mouse wheel down
- **Reset Zoom**: `Ctrl` + `0`
- **Pan**: Hold `Space` and drag, or middle-mouse drag

#### Alignment and Distribution

1. Select multiple elements
2. Right-click → **Align**
   - Align Left/Center/Right
   - Align Top/Middle/Bottom
3. Or **Distribute**
   - Distribute Horizontally
   - Distribute Vertically

---

## Entity Modeling

### What are Entities?

Entities are domain objects with:
- **Properties**: Attributes with types and validation
- **Methods**: Behaviors and operations
- **Invariants**: Business rules that must always be true

### Opening Entity Editor

**Method 1**: Via Project Tree
1. Expand "Entities" in project tree
2. Click on entity name

**Method 2**: Via Aggregate Element
1. Select aggregate on canvas
2. In property panel, click "Edit Entity Definition"

**Method 3**: Create New
1. Right-click "Entities" in project tree
2. Select "New Entity"

### Entity Editor Interface

```
┌─────────────────────────────────────────────────┐
│ Entity: OrderEntity                             │
├──────────────┬──────────────────────────────────┤
│              │                                  │
│ Entity Tree  │  Detail Panel                    │
│              │                                  │
│ ▼ OrderEntity│  Type: AggregateRoot            │
│   ▶ Properties│  Description: ...               │
│     - id     │                                  │
│     - status │  [Properties] [Methods] [Invar] │
│     - items  │                                  │
│   ▶ Methods  │  ┌──────────────────────────┐   │
│     - create │  │ Property Grid            │   │
│     - addItem│  │                          │   │
│   ▶ Invariants│  │ Name | Type | Required │   │
│     - rule1  │  │ id   | OrderId | ✓      │   │
│              │  │ status| String | ✓      │   │
└──────────────┴──────────────────────────────────┘
```

### Adding Properties

1. In Entity Editor, select entity in tree
2. Click **[Properties]** tab
3. Click **"Add Property"** button
4. Fill in property details:

```
Property Configuration:
┌─────────────────────────────────────┐
│ Name: totalAmount                   │
│ Type: Money                         │
│ Required: ☑                         │
│ Default Value: (empty)              │
│                                     │
│ Validation Rules:                   │
│ ☑ Must be positive                  │
│ ☑ Maximum: 1000000                  │
│                                     │
│ Description:                        │
│ Total order amount including tax    │
└─────────────────────────────────────┘
```

**Property Types**:
- Primitives: `String`, `Integer`, `Decimal`, `Boolean`, `DateTime`
- Value Objects: `Money`, `Email`, `Address`, `PhoneNumber`
- Custom Types: From global library or other entities
- Collections: `List<T>`, `Set<T>`, `Map<K,V>`

### Adding Methods

1. Select entity in tree
2. Click **[Methods]** tab
3. Click **"Add Method"** button
4. Configure method:

```
Method Configuration:
┌─────────────────────────────────────┐
│ Name: addItem                       │
│ Type: Command                       │
│                                     │
│ Parameters:                         │
│ + productId: ProductId              │
│ + quantity: Integer                 │
│ + price: Money                      │
│                                     │
│ Returns: void                       │
│                                     │
│ Pre-conditions:                     │
│ - quantity > 0                      │
│ - status == "Draft"                 │
│                                     │
│ Post-conditions:                    │
│ - Item added to items list          │
│ - OrderItemAdded event published    │
└─────────────────────────────────────┘
```

**Method Types**:
- **Constructor**: Creates new entity instances
- **Command**: Changes entity state
- **Query**: Returns data without side effects
- **Event Handler**: Handles domain events

### Defining Invariants

Invariants are business rules that must always hold true.

1. Select entity in tree
2. Click **[Invariants]** tab
3. Click **"Add Invariant"** button

**Example Invariants**:

```yaml
Invariant: OrderMustHaveItems
Expression: items.length > 0
Message: "Order must contain at least one item"

Invariant: TotalAmountMustBePositive
Expression: totalAmount.amount > 0
Message: "Total amount must be positive"

Invariant: ValidStatusTransitions
Expression: |
  (oldStatus == "Draft" && newStatus in ["Placed", "Cancelled"]) ||
  (oldStatus == "Placed" && newStatus in ["Paid", "Cancelled"]) ||
  (oldStatus == "Paid" && newStatus in ["Shipped", "Cancelled"])
Message: "Invalid status transition"
```

### Linking Entity to Aggregate

Once entity is defined:

1. Select aggregate element on canvas
2. In property panel, click **"Link Entity Definition"**
3. Select entity from dialog
4. Entity name appears in property panel
5. Save changes

---

## Read Model Designer

### What are Read Models?

Read models are **query projections** that:
- Select specific fields from entities
- Join multiple entities
- Transform and compute fields
- Optimize for read operations

### Opening Read Model Designer

**Method 1**: Via Project Tree
1. Expand "Read Models" in project tree
2. Click on read model name

**Method 2**: Via Read Model Element
1. Select read model on canvas
2. Click "Edit Definition" in property panel

**Method 3**: Create New
1. Right-click "Read Models" in tree
2. Select "New Read Model"

### Designer Interface

```
┌─────────────────────────────────────────────────┐
│ Read Model: OrderSummary                        │
├──────────────┬──────────────────────────────────┤
│              │                                  │
│ Data Sources │  Field Designer                  │
│              │                                  │
│ ☑ OrderEntity│  Selected Fields:               │
│   as "order" │                                  │
│              │  ┌──────────────────────────┐   │
│ ☐ Customer   │  │ Field | Source | Type   │   │
│   as "cust"  │  │──────────────────────────│   │
│              │  │ orderId                  │   │
│ Join Cond:   │  │  ← order.id              │   │
│ order.custId │  │  OrderId                 │   │
│ = cust.id    │  │                          │   │
│              │  │ customerName             │   │
│ [Add Source] │  │  ← cust.name             │   │
│              │  │  String                  │   │
└──────────────┴──────────────────────────────────┘
```

### Adding Data Sources

1. Click **"Add Data Source"**
2. Select entity from list
3. Enter alias (e.g., "order", "customer")
4. For additional sources, define join condition

**Join Example**:

```
Source 1: OrderEntity as "order"
Source 2: CustomerEntity as "customer"

Join Condition:
  order.customerId = customer.id
```

### Selecting Fields

#### Method 1: Drag from Entity Tree

1. Expand data source in left panel
2. Browse entity properties
3. Drag property to "Selected Fields"

#### Method 2: Add Field Button

1. Click **"Add Field"**
2. Enter field name
3. Select source property
4. Configure transformation (optional)

### Field Transformations

Transform source data before including:

**Rename**:
```
Source: customer.firstName + customer.lastName
Target: customerFullName
Type: String
```

**Compute**:
```
Source: items
Target: itemCount
Type: Integer
Expression: items.length
```

**Format**:
```
Source: order.createdAt
Target: createdDate
Type: String
Format: "YYYY-MM-DD"
```

**Aggregate**:
```
Source: items.price
Target: totalAmount
Type: Money
Expression: sum(items, item => item.price * item.quantity)
```

### Field Sources

Each field tracks its source:

- **Entity Property**: Direct mapping from entity field
- **Computed**: Calculated from multiple fields
- **Transformed**: Modified source data
- **Custom**: Manually entered value

### Example: OrderSummary Read Model

```yaml
ReadModel: OrderSummary
DataSources:
  - OrderEntity as "order"
  - CustomerEntity as "customer"
    join: order.customerId = customer.id

Fields:
  - name: orderId
    source: order.id
    type: OrderId
    
  - name: customerName
    source: customer.name
    type: String
    
  - name: status
    source: order.status
    type: OrderStatus
    
  - name: itemCount
    source: order.items
    type: Integer
    expression: order.items.length
    
  - name: totalAmount
    source: order.totalAmount
    type: Money
    
  - name: orderDate
    source: order.createdAt
    type: DateTime
```

---

## Command Data Model Designer

### What are Command Data Models?

Command data models define:
- **Payload structure**: Input data for commands
- **Field sources**: Where each field comes from (UI, read model, entity, custom DTO)
- **Validation rules**: Field constraints
- **Pre-conditions**: Conditions that must be met

### Opening Command Designer

**Method 1**: Via Project Tree
1. Expand "Commands" in project tree
2. Click on command name

**Method 2**: Via Command Element
1. Select command on canvas
2. Click "Edit Definition" in property panel

**Method 3**: Create New
1. Right-click "Commands" in tree
2. Select "New Command"

### Command Designer Interface

```
┌─────────────────────────────────────────────────┐
│ Command: PlaceOrder                             │
├──────────────┬──────────────────────────────────┤
│              │                                  │
│ Payload      │  Field Configuration             │
│              │                                  │
│ Fields:      │  Field: customerId               │
│ ☑ customerId │  Type: CustomerId                │
│ ☑ items      │  Source: UI Input                │
│ ☑ shippingAddr│ Required: Yes                   │
│              │                                  │
│ [Add Field]  │  Validation:                     │
│              │  ☑ Not null                      │
│              │  ☐ Pattern: ...                  │
│              │                                  │
│              │  Description:                    │
│              │  Customer placing the order      │
└──────────────┴──────────────────────────────────┘
```

### Adding Payload Fields

1. Click **"Add Field"**
2. Enter field name (e.g., `customerId`)
3. Select type (e.g., `CustomerId`)
4. Choose field source:
   - **UI Input**: Entered by user
   - **Read Model**: From read model field
   - **Entity**: From loaded entity
   - **Custom DTO**: From custom data transfer object

### Field Source Mapping

#### UI Input

Fields directly entered by user:

```yaml
Field: email
Type: Email
Source: UI Input
Validation:
  - Required: true
  - Format: email
```

#### From Read Model

Fields populated from query results:

```yaml
Field: customerId
Type: CustomerId
Source: Read Model
ReadModel: CustomerProfile
Field: id
```

#### From Entity

Fields from loaded aggregate:

```yaml
Field: currentStatus
Type: OrderStatus
Source: Entity
Entity: Order
Property: status
```

#### Custom DTO

Complex input objects:

```yaml
Field: shippingAddress
Type: Address
Source: Custom DTO
DTO: ShippingAddressDTO
  Fields:
    - street: String
    - city: String
    - zipCode: String
    - country: String
```

### Validation Rules

Configure per-field validation:

**String Validation**:
- Required
- Min/Max length
- Pattern (regex)
- Allowed values

**Numeric Validation**:
- Required
- Min/Max value
- Positive/Negative

**Custom Validation**:
- Custom expression
- Cross-field validation

### Pre-conditions

Define conditions that must be met before command executes:

```yaml
Command: CancelOrder
PreConditions:
  - name: OrderNotShipped
    expression: order.status != "Shipped"
    message: "Cannot cancel order that has been shipped"
    
  - name: WithinCancellationPeriod
    expression: now() - order.createdAt <= Duration(hours: 24)
    message: "Order can only be cancelled within 24 hours"
```

### Post-conditions and Events

Define expected outcomes:

```yaml
Command: PlaceOrder
PostConditions:
  - Order status set to "Placed"
  - OrderPlaced event published
  - Inventory reserved

ProducedEvents:
  - OrderPlaced
  - InventoryReserved
```

---

## Component Connections

### What are Connections?

Connections visualize relationships between canvas elements:

- **Command → Aggregate**: Command targets aggregate
- **Aggregate → Event**: Aggregate produces event
- **Event → Policy**: Event triggers policy
- **Policy → Command**: Policy executes command
- **Read Model → Entity**: Read model queries entity
- **Command → Read Model**: Command uses read model data
- **External System → Event**: External system publishes event
- **Policy → External System**: Policy calls external system

### Creating Connections

#### Method 1: Connection Mode

1. Click **"Connection Mode"** button in toolbar
2. Click source element
3. Click target element
4. Connection created automatically with correct type

#### Method 2: Drag Mode

1. Hover over element until connection points appear
2. Click and drag from connection point
3. Drag to target element
4. Release to create connection

#### Method 3: Context Menu

1. Right-click source element
2. Select "Connect to..."
3. Click target element

### Connection Types and Styles

Each connection type has distinct visual style:

| Type | Style | Color | Example |
|------|-------|-------|---------|
| Command → Aggregate | Solid arrow | Blue | `PlaceOrder → Order` |
| Aggregate → Event | Dashed arrow | Orange | `Order → OrderPlaced` |
| Event → Policy | Solid line | Purple | `OrderPlaced → NotifyWarehouse` |
| Policy → Command | Dotted arrow | Blue | `NotifyWarehouse → PrepareShipment` |
| Read Model → Entity | Dashed line | Green | `OrderSummary ← Order` |
| Command → Read Model | Dotted line | Cyan | `PlaceOrder ← CartView` |
| External → Event | Solid line | Pink | `PaymentGateway → PaymentReceived` |
| Policy → External | Dotted arrow | Pink | `NotifyPolicy → EmailService` |

### Editing Connections

1. Click on connection line to select
2. Property panel shows connection details
3. Edit properties:
   - Label/Description
   - Style (line type, color, width)
   - Metadata

### Routing Connections

Connections auto-route around elements:

- **Orthogonal Routing**: Right-angle paths
- **Direct Routing**: Straight lines
- **Smart Routing**: Avoids overlaps

Change routing:
1. Select connection
2. In property panel, choose "Routing Style"

### Connection Validation

StormForge validates connections:

✓ **Valid**: `PlaceOrder` (Command) → `Order` (Aggregate)  
✗ **Invalid**: `PlaceOrder` (Command) → `OrderPlaced` (Event)

Invalid connections show warning icon.

---

## Global Library

### What is the Global Library?

The Global Library is a **three-tier hierarchy** of reusable components:

1. **Enterprise Library**: Shared across entire organization
2. **Organization Library**: Shared within organization/department
3. **Project Library**: Shared within current project

### Library Components

Types of reusable components:

- **Value Objects**: `Money`, `Email`, `Address`, `PhoneNumber`
- **Entities**: Common domain objects
- **Commands**: Standard operations
- **Read Models**: Common query patterns
- **Policies**: Reusable business rules

### Browsing the Library

1. Click **"Global Library"** button in toolbar
2. Or expand "Libraries" in project tree
3. Browse components by:
   - **Scope**: Enterprise / Organization / Project
   - **Type**: Entity, Command, Read Model, etc.
   - **Category**: Finance, Customer, Order, etc.

### Library Browser Interface

```
┌─────────────────────────────────────────────────┐
│ Global Library                    [Search...]   │
├──────────────┬──────────────────────────────────┤
│              │                                  │
│ Filters      │  Components                      │
│              │                                  │
│ Scope:       │  ┌────────────────────────────┐ │
│ ☑ Enterprise │  │ 💰 Money                   │ │
│ ☑ Organization│ │ Value Object               │ │
│ ☑ Project    │  │ Used in 47 projects        │ │
│              │  │ [View] [Use]               │ │
│ Type:        │  └────────────────────────────┘ │
│ ☑ Value Obj  │                                  │
│ ☐ Entity     │  ┌────────────────────────────┐ │
│ ☐ Command    │  │ 📧 Email                   │ │
│              │  │ Value Object               │ │
│ Category:    │  │ Used in 89 projects        │ │
│ ☑ Common     │  │ [View] [Use]               │ │
│ ☐ Finance    │  └────────────────────────────┘ │
└──────────────┴──────────────────────────────────┘
```

### Using Library Components

#### Method 1: Drag from Library

1. Open Global Library browser
2. Search or browse for component
3. Drag component to canvas
4. Component added as reference

#### Method 2: Import to Project

1. Browse library
2. Click component
3. Click **"Import to Project"**
4. Choose mode:
   - **Reference**: Link to library (updates when library updates)
   - **Copy**: Create independent copy

### Publishing to Library

Share your components:

1. Select entity/command/read model in project tree
2. Right-click → **"Publish to Library"**
3. Choose scope:
   - Project (current project only)
   - Organization (your organization)
   - Enterprise (requires admin approval)
4. Add metadata:
   - Name
   - Description
   - Category
   - Tags
   - Version
5. Click **"Publish"**

### Standard Library Components

StormForge includes standard components:

#### Value Objects

- **Money**: Amount with currency
  ```dart
  Money {
    amount: Decimal
    currency: Currency
  }
  ```

- **Address**: Physical address
  ```dart
  Address {
    street: String
    city: String
    state: String
    zipCode: String
    country: Country
  }
  ```

- **Email**: Email address with validation
  ```dart
  Email {
    value: String (validated)
  }
  ```

- **PhoneNumber**: Phone with country code
  ```dart
  PhoneNumber {
    countryCode: String
    number: String
  }
  ```

#### Common Entities

- **Customer**: Base customer entity
- **Product**: Product catalog item
- **Order**: Order aggregate template
- **Payment**: Payment transaction

### Version Management

Library components are versioned:

- **Semantic Versioning**: Major.Minor.Patch (e.g., 1.2.3)
- **Breaking Changes**: Increment major version
- **New Features**: Increment minor version
- **Bug Fixes**: Increment patch version

### Impact Analysis

Before updating referenced components:

1. Right-click component in library
2. Select **"Show Usage"**
3. View all projects using this component
4. See impact of changes
5. Notify affected teams

---

## IR Export and Import

### What is IR?

IR (Intermediate Representation) is a **YAML format** that captures your entire domain model:

- All canvas elements and their positions
- Entity definitions with properties and methods
- Read model definitions
- Command definitions
- Connections between components
- Project metadata

### Exporting IR

**Export Current Project**:

1. Click **File** → **Export IR**
2. Choose version:
   - **IR v2.0** (recommended): Full feature support
   - **IR v1.0**: Backward compatibility
3. Choose destination:
   - **Download**: Save to local file
   - **Git**: Commit to repository
4. Click **"Export"**

**File saved**: `<project_namespace>_context.yaml`

### IR File Structure (v2.0)

```yaml
version: "2.0"

# Project metadata
project:
  id: "proj-12345"
  name: "E-commerce Platform"
  namespace: "com.acme.ecommerce"

# Bounded context
bounded_context:
  name: "Order"
  namespace: "acme.order"
  description: "Order management context"

# Entity definitions
entities:
  OrderEntity:
    name: "OrderEntity"
    entity_type: "aggregate_root"
    properties:
      - name: "id"
        type: "OrderId"
        identifier: true
    methods:
      - name: "create"
        method_type: "constructor"

# Read models
read_models:
  OrderSummary:
    sources:
      - entity_id: "OrderEntity"
        alias: "order"
    fields:
      - name: "orderId"
        source:
          type: "entity_property"
          property_path: "order.id"

# Commands
commands:
  PlaceOrder:
    payload:
      - name: "customerId"
        type: "CustomerId"
        source:
          type: "custom"

# Events
events:
  OrderPlaced:
    aggregate: "Order"
    payload:
      - name: "orderId"
        type: "OrderId"

# Visual connections
connections:
  - id: "conn-1"
    type: "command_to_aggregate"
    source_id: "cmd-place-order"
    target_id: "agg-order"

# Canvas metadata
canvas_metadata:
  zoom: 1.0
  pan: { x: 0, y: 0 }
  elements:
    - id: "cmd-place-order"
      type: "command"
      position: { x: 100, y: 200 }
      size: { width: 150, height: 80 }
```

### Importing IR

**Import from File**:

1. Click **File** → **Import IR**
2. Select `.yaml` file
3. Choose import mode:
   - **New Project**: Create new project from IR
   - **Merge**: Add to current project
   - **Replace**: Replace current canvas
4. Click **"Import"**

**Import from Git**:

1. Click **File** → **Import from Git**
2. Enter repository URL
3. Select branch and file path
4. Click **"Import"**

### Version Compatibility

- **IR v2.0 → v2.0**: Full compatibility ✅
- **IR v1.0 → v2.0**: Auto-upgraded ✅
- **IR v2.0 → v1.0**: Downgrade with feature loss ⚠️

### Validation

StormForge validates imported IR:

- ✓ Schema validation against JSON Schema
- ✓ Type checking (all referenced types exist)
- ✓ Relationship validation (connections valid)
- ✓ Invariant checking

Validation errors displayed with line numbers.

---

## Team Collaboration

### User Roles

StormForge supports role-based access control:

#### Global Roles

- **Admin**: Full system access, user management
- **Manager**: Create projects, manage teams
- **Developer**: Create and edit models
- **Viewer**: Read-only access

#### Project Roles

- **Owner**: Full project control
- **Maintainer**: Edit models and settings
- **Developer**: Edit models only
- **Viewer**: Read-only access

### Managing Team Members

**Adding Team Members**:

1. Open project settings
2. Click **"Team"** tab
3. Click **"Add Member"**
4. Enter username or email
5. Select role
6. Click **"Add"**

**Changing Roles**:

1. In Team tab, find member
2. Click role dropdown
3. Select new role
4. Click **"Update"**

**Removing Members**:

1. In Team tab, find member
2. Click **"Remove"** button
3. Confirm removal

### Project Permissions

| Action | Owner | Maintainer | Developer | Viewer |
|--------|-------|------------|-----------|--------|
| View models | ✓ | ✓ | ✓ | ✓ |
| Edit canvas | ✓ | ✓ | ✓ | ✗ |
| Edit entities | ✓ | ✓ | ✓ | ✗ |
| Edit settings | ✓ | ✓ | ✗ | ✗ |
| Manage team | ✓ | ✗ | ✗ | ✗ |
| Delete project | ✓ | ✗ | ✗ | ✗ |
| Export IR | ✓ | ✓ | ✓ | ✓ |
| Publish library | ✓ | ✓ | ✓ | ✗ |

### Real-time Collaboration

**Presence Indicators**:
- See who's viewing the project
- Avatar badges on edited elements
- Cursor positions of other users

**Conflict Resolution**:
- Last-write-wins for most changes
- Manual merge for conflicts
- Change history for rollback

### Activity Timeline

View project activity:

1. Click **"Activity"** tab in project settings
2. See timeline of all changes:
   - User who made change
   - Timestamp
   - Change description
   - Before/after comparison

### Comments and Annotations

Add notes to elements:

1. Right-click element
2. Select **"Add Comment"**
3. Type comment
4. Comments appear as badges
5. Click badge to view/reply

---

## Tips and Best Practices

### Modeling Tips

#### Start with Events

1. **Event Storming**: Begin by identifying domain events
2. **Time-ordered**: Arrange events chronologically
3. **Past Tense**: Name events in past tense (e.g., `OrderPlaced`)

#### Progressive Detail

1. **Canvas First**: High-level design on canvas
2. **Then Details**: Use editors for detailed definitions
3. **Iterate**: Refine as understanding improves

#### Bounded Contexts

- **One Context per Canvas**: Keep contexts separate
- **Clear Boundaries**: Explicit context boundaries
- **Context Map**: Document relationships between contexts

#### Entity Design

- **Rich Models**: Include behavior, not just data
- **Invariants**: Capture business rules explicitly
- **Immutability**: Prefer immutable value objects

#### Read Model Design

- **Purpose-Specific**: One read model per use case
- **Denormalized**: Optimize for queries, not storage
- **Eventual Consistency**: Accept stale data when appropriate

### Performance Tips

#### Large Models (1000+ Elements)

- **Use Layers**: Group related elements
- **Lazy Loading**: Load on demand
- **Partial Views**: Focus on specific areas

#### Canvas Performance

- **Viewport Culling**: Only render visible elements
- **Simplify Connections**: Reduce connection complexity
- **Zoom Out**: Use overview mode for navigation

### Organization Tips

#### Naming Conventions

- **Events**: Past tense, specific (e.g., `OrderPlaced`, not `Order`)
- **Commands**: Imperative verb (e.g., `PlaceOrder`)
- **Aggregates**: Nouns (e.g., `Order`, `Customer`)
- **Read Models**: Descriptive (e.g., `OrderSummary`, `CustomerProfile`)

#### Project Structure

```
project/
├── contexts/
│   ├── order/
│   ├── payment/
│   └── inventory/
├── shared/
│   ├── value-objects/
│   └── policies/
└── library/
    └── components/
```

#### Documentation

- **Element Descriptions**: Add descriptions to all elements
- **Invariants**: Document why, not just what
- **Examples**: Include example data in read models

### Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| New Event | `E` |
| New Command | `C` |
| New Aggregate | `A` |
| New Policy | `P` |
| New Read Model | `R` |
| Connection Mode | `L` |
| Select All | `Ctrl+A` |
| Delete | `Delete` / `Backspace` |
| Copy | `Ctrl+C` |
| Paste | `Ctrl+V` |
| Undo | `Ctrl+Z` |
| Redo | `Ctrl+Y` / `Ctrl+Shift+Z` |
| Save | `Ctrl+S` |
| Zoom In | `Ctrl++` |
| Zoom Out | `Ctrl+-` |
| Reset Zoom | `Ctrl+0` |
| Pan Mode | `Space` (hold) |

---

## Troubleshooting

### Common Issues

#### Canvas Performance

**Symptom**: Slow rendering with many elements

**Solution**:
- Enable viewport culling in settings
- Use layers to hide unused elements
- Zoom out for better overview

#### Connection Not Creating

**Symptom**: Connection line doesn't appear

**Solution**:
- Check if connection type is valid
- Ensure both elements support connection
- Try connection mode instead of drag mode

#### Entity Not Linking

**Symptom**: Can't link entity to aggregate

**Solution**:
- Ensure entity is fully defined
- Check entity type matches aggregate
- Refresh entity list in dialog

#### Export Fails

**Symptom**: Export button doesn't work

**Solution**:
- Check for validation errors
- Ensure all required fields filled
- Try exporting individual contexts

### Getting Help

- **Documentation**: Check relevant guide sections
- **Examples**: Review example projects in `ir_schema/examples/`
- **Community**: (Coming soon)
- **Support**: Contact project maintainers

---

## Appendix

### Glossary

- **Aggregate**: Domain object that handles commands and maintains consistency
- **Bounded Context**: Logical boundary where a particular domain model applies
- **Command**: Action that changes system state
- **Domain Event**: Something that happened in the domain
- **Entity**: Domain object with unique identity
- **EventStorming**: Workshop technique for domain discovery
- **Invariant**: Business rule that must always be true
- **Policy**: Automated reaction to events
- **Read Model**: Query projection optimized for reads
- **Value Object**: Immutable object defined by its attributes

### Resources

- **IR v2.0 Specification**: `/ir_schema/docs/ir_v2_specification.md`
- **Migration Guide**: `/ir_schema/docs/MIGRATION_V1_TO_V2.md`
- **Architecture Guide**: `/docs/ARCHITECTURE.md`
- **API Documentation**: `/docs/guides/api-reference.md`
- **Admin Guide**: `/docs/guides/admin-guide.md`

---

**Version**: 2.0  
**Last Updated**: December 2025  
**Feedback**: Please report issues or suggestions via GitHub Issues

