use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Root IR model structure
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct IRModel {
    pub version: String,
    pub bounded_context: BoundedContext,
    #[serde(default)]
    pub aggregates: HashMap<String, Aggregate>,
    #[serde(default)]
    pub value_objects: HashMap<String, ValueObject>,
    #[serde(default)]
    pub events: HashMap<String, Event>,
    #[serde(default)]
    pub commands: HashMap<String, Command>,
    #[serde(default)]
    pub queries: HashMap<String, Query>,
    #[serde(default)]
    pub external_events: Vec<ExternalEventSubscription>,
}

/// Bounded Context definition
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BoundedContext {
    pub name: String,
    pub namespace: String,
    #[serde(default)]
    pub description: Option<String>,
}

/// Aggregate definition
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Aggregate {
    pub name: String,
    #[serde(default)]
    pub description: Option<String>,
    pub root_entity: Entity,
    #[serde(default)]
    pub invariants: Vec<Invariant>,
}

/// Entity definition
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Entity {
    pub name: String,
    pub properties: Vec<Property>,
}

/// Property definition
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Property {
    pub name: String,
    #[serde(rename = "type")]
    pub prop_type: String,
    #[serde(default)]
    pub identifier: bool,
    #[serde(default = "default_true")]
    pub required: bool,
    #[serde(default)]
    pub default: Option<serde_json::Value>,
    #[serde(default)]
    pub description: Option<String>,
    #[serde(default)]
    pub validation: Option<Validation>,
    #[serde(default)]
    pub computed: Option<String>,
}

fn default_true() -> bool {
    true
}

/// Validation rules
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Validation {
    #[serde(default)]
    pub min: Option<f64>,
    #[serde(default)]
    pub max: Option<f64>,
    #[serde(rename = "minLength")]
    #[serde(default)]
    pub min_length: Option<usize>,
    #[serde(rename = "maxLength")]
    #[serde(default)]
    pub max_length: Option<usize>,
    #[serde(default)]
    pub pattern: Option<String>,
    #[serde(default)]
    pub precision: Option<usize>,
}

/// Business invariant
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Invariant {
    pub name: String,
    #[serde(default)]
    pub description: Option<String>,
    pub expression: String,
}

/// Value Object definition
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ValueObject {
    pub name: String,
    #[serde(default)]
    pub description: Option<String>,
    #[serde(rename = "type")]
    #[serde(default)]
    pub vo_type: Option<String>,
    #[serde(default)]
    pub underlying_type: Option<String>,
    #[serde(default)]
    pub format: Option<String>,
    #[serde(default)]
    pub prefix: Option<String>,
    #[serde(default)]
    pub properties: Vec<Property>,
    #[serde(default)]
    pub values: Vec<EnumValue>,
}

/// Enum value
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EnumValue {
    pub name: String,
    #[serde(default)]
    pub description: Option<String>,
}

/// Domain Event
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Event {
    pub name: String,
    #[serde(default)]
    pub description: Option<String>,
    #[serde(default)]
    pub aggregate: Option<String>,
    #[serde(default)]
    pub payload: Vec<Property>,
}

/// Command definition
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Command {
    pub name: String,
    #[serde(default)]
    pub description: Option<String>,
    #[serde(default)]
    pub aggregate: Option<String>,
    #[serde(default)]
    pub payload: Vec<Property>,
    #[serde(default)]
    pub produces: Vec<String>,
    #[serde(default)]
    pub preconditions: Vec<Condition>,
    #[serde(default)]
    pub validation: Vec<Condition>,
}

/// Query definition
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Query {
    pub name: String,
    #[serde(default)]
    pub description: Option<String>,
    #[serde(default)]
    pub parameters: Vec<Property>,
    #[serde(default)]
    pub returns: Option<ReturnType>,
}

/// Return type specification
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ReturnType {
    #[serde(rename = "type")]
    pub return_type: String,
    #[serde(default)]
    pub nullable: bool,
}

/// Condition definition
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Condition {
    pub expression: String,
    pub message: String,
}

/// External event subscription
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExternalEventSubscription {
    pub context: String,
    pub event: String,
    pub handler: String,
    #[serde(default)]
    pub description: Option<String>,
}
