# StormForge IR Specification v1.0

> Intermediate Representation Format for Domain-Driven Design Models

## Introduction

The StormForge IR (Intermediate Representation) is a YAML-based format for describing domain models created using EventStorming methodology. This document specifies the IR format version 1.0.

## Design Principles

1. **Human-readable**: IR files should be easily understood and edited by developers
2. **Version-controllable**: Works well with Git and other VCS systems
3. **Generator-agnostic**: Same IR can generate code for any backend language
4. **Complete**: Captures all information needed for code generation
5. **Extensible**: Allows for custom extensions without breaking compatibility

## File Organization

### Project Structure

```
project/
├── stormforge.yaml           # Project configuration
├── contexts/
│   ├── order_context.yaml    # Order Bounded Context
│   ├── payment_context.yaml  # Payment Bounded Context
│   └── ...
└── shared/
    └── types.yaml            # Shared value objects
```

### Naming Conventions

- Context files: `{context_name}_context.yaml`
- File names: lowercase with underscores
- Type names: PascalCase
- Property names: camelCase

## Schema Reference

### Project Configuration (stormforge.yaml)

```yaml
version: "1.0"                    # IR version
project:
  name: "Acme E-commerce"         # Project display name
  namespace: "com.acme"           # Base namespace
  description: "..."              # Project description
  
contexts:
  - file: "contexts/order_context.yaml"
  - file: "contexts/payment_context.yaml"
  
shared_types:
  - file: "shared/types.yaml"
  
generators:
  rust:
    enabled: true
    output: "./generated/rust"
  dart:
    enabled: true
    output: "./generated/dart"
```

### Bounded Context Definition

```yaml
bounded_context:
  name: "Order"                   # Context name (PascalCase)
  namespace: "acme.order"         # Fully qualified namespace
  description: "Order management" # Description
  
  # Aggregates in this context
  aggregates:
    - $ref: "#/aggregates/Order"
    
  # Events produced by this context
  events:
    - $ref: "#/events/OrderCreated"
    - $ref: "#/events/OrderPaid"
    
  # Commands handled by this context
  commands:
    - $ref: "#/commands/CreateOrder"
    - $ref: "#/commands/PayOrder"
    
  # Queries supported by this context
  queries:
    - $ref: "#/queries/GetOrder"
    - $ref: "#/queries/ListOrders"
    
  # External events this context subscribes to
  external_events:
    - context: "Payment"
      event: "PaymentCompleted"
      handler: "handlePaymentCompleted"

# Aggregate definitions
aggregates:
  Order:
    name: "Order"
    description: "Order aggregate root"
    
    root_entity:
      name: "Order"
      properties:
        - name: "id"
          type: "OrderId"
          identifier: true
          description: "Unique order identifier"
        - name: "customerId"
          type: "CustomerId"
          required: true
        - name: "items"
          type: "List<OrderItem>"
          required: true
        - name: "status"
          type: "OrderStatus"
          required: true
          default: "CREATED"
        - name: "totalAmount"
          type: "Money"
          required: true
        - name: "createdAt"
          type: "DateTime"
          required: true
        - name: "updatedAt"
          type: "DateTime"
          required: false
          
    value_objects:
      - $ref: "#/value_objects/OrderItem"
      - $ref: "#/value_objects/Money"
      
    invariants:
      - name: "OrderMustHaveItems"
        description: "Order must have at least one item"
        expression: "items.length > 0"
      - name: "TotalMustBePositive"
        description: "Total amount must be positive"
        expression: "totalAmount.amount > 0"

# Value Object definitions
value_objects:
  OrderId:
    name: "OrderId"
    type: "identifier"
    underlying_type: "String"
    format: "uuid"
    
  CustomerId:
    name: "CustomerId"
    type: "identifier"
    underlying_type: "String"
    format: "uuid"
    
  OrderItem:
    name: "OrderItem"
    properties:
      - name: "productId"
        type: "ProductId"
        required: true
      - name: "productName"
        type: "String"
        required: true
      - name: "quantity"
        type: "Integer"
        required: true
        validation:
          min: 1
          max: 100
      - name: "unitPrice"
        type: "Money"
        required: true
        
  Money:
    name: "Money"
    properties:
      - name: "amount"
        type: "Decimal"
        required: true
        validation:
          min: 0
      - name: "currency"
        type: "String"
        required: true
        default: "CNY"
        validation:
          pattern: "^[A-Z]{3}$"
          
  OrderStatus:
    name: "OrderStatus"
    type: "enum"
    values:
      - name: "CREATED"
        description: "Order has been created"
      - name: "PAID"
        description: "Payment has been received"
      - name: "SHIPPED"
        description: "Order has been shipped"
      - name: "DELIVERED"
        description: "Order has been delivered"
      - name: "CANCELLED"
        description: "Order has been cancelled"

# Event definitions
events:
  OrderCreated:
    name: "OrderCreated"
    description: "Emitted when a new order is created"
    aggregate: "Order"
    payload:
      - name: "orderId"
        type: "OrderId"
      - name: "customerId"
        type: "CustomerId"
      - name: "items"
        type: "List<OrderItem>"
      - name: "totalAmount"
        type: "Money"
      - name: "createdAt"
        type: "DateTime"
        
  OrderPaid:
    name: "OrderPaid"
    description: "Emitted when an order is paid"
    aggregate: "Order"
    payload:
      - name: "orderId"
        type: "OrderId"
      - name: "paymentId"
        type: "PaymentId"
      - name: "paidAmount"
        type: "Money"
      - name: "paidAt"
        type: "DateTime"

# Command definitions
commands:
  CreateOrder:
    name: "CreateOrder"
    description: "Create a new order"
    aggregate: "Order"
    payload:
      - name: "customerId"
        type: "CustomerId"
        required: true
      - name: "items"
        type: "List<CreateOrderItem>"
        required: true
    produces:
      - "OrderCreated"
    validation:
      - expression: "items.length > 0"
        message: "Order must have at least one item"
        
  PayOrder:
    name: "PayOrder"
    description: "Mark order as paid"
    aggregate: "Order"
    payload:
      - name: "orderId"
        type: "OrderId"
        required: true
      - name: "paymentId"
        type: "PaymentId"
        required: true
    produces:
      - "OrderPaid"
    preconditions:
      - expression: "order.status == CREATED"
        message: "Can only pay orders in CREATED status"

# Query definitions
queries:
  GetOrder:
    name: "GetOrder"
    description: "Get order by ID"
    parameters:
      - name: "orderId"
        type: "OrderId"
        required: true
    returns:
      type: "Order"
      nullable: true
      
  ListOrders:
    name: "ListOrders"
    description: "List orders with filters"
    parameters:
      - name: "customerId"
        type: "CustomerId"
        required: false
      - name: "status"
        type: "OrderStatus"
        required: false
      - name: "page"
        type: "Integer"
        required: false
        default: 1
      - name: "pageSize"
        type: "Integer"
        required: false
        default: 20
    returns:
      type: "PagedResult<Order>"
```

## Type System

### Primitive Types

| Type | Description | Rust | Dart |
|------|-------------|------|------|
| String | Text data | String | String |
| Integer | Whole numbers | i64 | int |
| Decimal | Decimal numbers | Decimal | double |
| Boolean | True/false | bool | bool |
| DateTime | Date and time | DateTime<Utc> | DateTime |
| Date | Date only | NaiveDate | DateTime |
| Time | Time only | NaiveTime | DateTime |
| UUID | Unique identifier | Uuid | String |
| Bytes | Binary data | Vec<u8> | Uint8List |

### Collection Types

| Type | Description |
|------|-------------|
| List<T> | Ordered collection |
| Set<T> | Unique collection |
| Map<K,V> | Key-value pairs |
| Optional<T> | Nullable value |

### Custom Types

Custom types are defined as value objects with properties and validation rules.

## Validation Rules

### Property Validation

```yaml
validation:
  min: 0                    # Minimum value (numeric)
  max: 100                  # Maximum value (numeric)
  minLength: 1              # Minimum string length
  maxLength: 255            # Maximum string length
  pattern: "^[A-Z]{3}$"     # Regex pattern
  enum: ["A", "B", "C"]     # Allowed values
  custom: "isValidEmail"    # Custom validator function
```

### Aggregate Invariants

```yaml
invariants:
  - name: "InvariantName"
    description: "Human-readable description"
    expression: "boolean expression"
```

## Cross-Context References

### External Event Subscription

```yaml
external_events:
  - context: "Payment"
    event: "PaymentCompleted"
    handler: "handlePaymentCompleted"
```

### Shared Value Objects

```yaml
# In shared/types.yaml
shared_types:
  Money:
    name: "Money"
    properties:
      - name: "amount"
        type: "Decimal"
      - name: "currency"
        type: "String"
```

## Extensions

Custom extensions can be added using the `x-` prefix:

```yaml
aggregate:
  name: "Order"
  x-audit-enabled: true
  x-cache-ttl: 300
```

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-10 | Initial specification |

---

*This specification is subject to change as StormForge evolves.*
