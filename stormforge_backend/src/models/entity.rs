use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use uuid::Uuid;

/// Entity type classification
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, ToSchema, Default)]
#[serde(rename_all = "camelCase")]
pub enum EntityType {
    #[default]
    Entity,
    AggregateRoot,
    ValueObject,
}

/// Validation rule type
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, ToSchema)]
#[serde(rename_all = "camelCase")]
pub enum ValidationType {
    Required,
    MinLength,
    MaxLength,
    Min,
    Max,
    Pattern,
    Email,
    Url,
    Custom,
}

/// Validation rule for entity properties
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct ValidationRule {
    pub id: String,
    pub validation_type: ValidationType,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub value: Option<serde_json::Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub error_message: Option<String>,
}

impl ValidationRule {
    #[allow(dead_code)]
    pub fn new(
        validation_type: ValidationType,
        value: Option<serde_json::Value>,
        error_message: Option<String>,
    ) -> Self {
        Self {
            id: Uuid::new_v4().to_string(),
            validation_type,
            value,
            error_message,
        }
    }
}

/// Entity property definition
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct EntityProperty {
    pub id: String,
    pub name: String,
    pub property_type: String,
    pub required: bool,
    pub is_identifier: bool,
    pub is_read_only: bool,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub default_value: Option<serde_json::Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
    pub display_order: i32,
    pub validations: Vec<ValidationRule>,
}

impl EntityProperty {
    #[allow(dead_code)]
    pub fn new(name: String, property_type: String) -> Self {
        Self {
            id: Uuid::new_v4().to_string(),
            name,
            property_type,
            required: false,
            is_identifier: false,
            is_read_only: false,
            default_value: None,
            description: None,
            display_order: 0,
            validations: Vec::new(),
        }
    }
}

/// Method parameter definition
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct MethodParameter {
    pub name: String,
    pub parameter_type: String,
    pub required: bool,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub default_value: Option<serde_json::Value>,
}

/// Method type classification
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, ToSchema)]
#[serde(rename_all = "camelCase")]
pub enum MethodType {
    Constructor,
    Command,
    Query,
    DomainLogic,
}

/// Entity method definition
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct EntityMethod {
    pub id: String,
    pub name: String,
    pub method_type: MethodType,
    pub return_type: String,
    pub parameters: Vec<MethodParameter>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
}

impl EntityMethod {
    #[allow(dead_code)]
    pub fn new(name: String, method_type: MethodType, return_type: String) -> Self {
        Self {
            id: Uuid::new_v4().to_string(),
            name,
            method_type,
            return_type,
            parameters: Vec::new(),
            description: None,
        }
    }
}

/// Entity invariant (business rule)
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct EntityInvariant {
    pub id: String,
    pub name: String,
    pub expression: String,
    pub error_message: String,
    pub enabled: bool,
}

impl EntityInvariant {
    #[allow(dead_code)]
    pub fn new(name: String, expression: String, error_message: String) -> Self {
        Self {
            id: Uuid::new_v4().to_string(),
            name,
            expression,
            error_message,
            enabled: true,
        }
    }
}

/// Complete entity definition
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct EntityDefinition {
    pub id: String,
    pub project_id: String,
    pub name: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub aggregate_id: Option<String>,
    pub entity_type: EntityType,
    pub properties: Vec<EntityProperty>,
    pub methods: Vec<EntityMethod>,
    pub invariants: Vec<EntityInvariant>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

impl EntityDefinition {
    pub fn new(project_id: String, name: String, entity_type: EntityType) -> Self {
        let now = Utc::now();
        Self {
            id: Uuid::new_v4().to_string(),
            project_id,
            name,
            description: None,
            aggregate_id: None,
            entity_type,
            properties: Vec::new(),
            methods: Vec::new(),
            invariants: Vec::new(),
            created_at: now,
            updated_at: now,
        }
    }
}

/// Request to create a new entity
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct CreateEntityRequest {
    pub project_id: String,
    pub name: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub aggregate_id: Option<String>,
    pub entity_type: EntityType,
}

/// Request to update an entity
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct UpdateEntityRequest {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub name: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub aggregate_id: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub entity_type: Option<EntityType>,
}

/// Request to add/update a property
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct PropertyRequest {
    pub name: String,
    pub property_type: String,
    #[serde(default)]
    pub required: bool,
    #[serde(default)]
    pub is_identifier: bool,
    #[serde(default)]
    pub is_read_only: bool,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub default_value: Option<serde_json::Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
    #[serde(default)]
    pub display_order: i32,
    #[serde(default)]
    pub validations: Vec<ValidationRule>,
}

/// Request to add/update a method
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct MethodRequest {
    pub name: String,
    pub method_type: MethodType,
    pub return_type: String,
    #[serde(default)]
    pub parameters: Vec<MethodParameter>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
}

/// Request to add/update an invariant
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct InvariantRequest {
    pub name: String,
    pub expression: String,
    pub error_message: String,
    #[serde(default = "default_enabled")]
    pub enabled: bool,
}

fn default_enabled() -> bool {
    true
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_entity_type_default() {
        assert_eq!(EntityType::default(), EntityType::Entity);
    }

    #[test]
    fn test_validation_rule_new() {
        let rule = ValidationRule::new(
            ValidationType::Required,
            None,
            Some("Field is required".to_string()),
        );
        assert!(!rule.id.is_empty());
        assert_eq!(rule.validation_type, ValidationType::Required);
        assert!(rule.value.is_none());
        assert_eq!(rule.error_message.unwrap(), "Field is required");
    }

    #[test]
    fn test_entity_property_new() {
        let property = EntityProperty::new("name".to_string(), "String".to_string());
        assert!(!property.id.is_empty());
        assert_eq!(property.name, "name");
        assert_eq!(property.property_type, "String");
        assert!(!property.required);
        assert!(!property.is_identifier);
        assert!(!property.is_read_only);
        assert!(property.default_value.is_none());
        assert!(property.validations.is_empty());
    }

    #[test]
    fn test_entity_method_new() {
        let method = EntityMethod::new(
            "create".to_string(),
            MethodType::Constructor,
            "Self".to_string(),
        );
        assert!(!method.id.is_empty());
        assert_eq!(method.name, "create");
        assert_eq!(method.method_type, MethodType::Constructor);
        assert_eq!(method.return_type, "Self");
        assert!(method.parameters.is_empty());
    }

    #[test]
    fn test_entity_invariant_new() {
        let invariant = EntityInvariant::new(
            "price_positive".to_string(),
            "price > 0".to_string(),
            "Price must be positive".to_string(),
        );
        assert!(!invariant.id.is_empty());
        assert_eq!(invariant.name, "price_positive");
        assert_eq!(invariant.expression, "price > 0");
        assert_eq!(invariant.error_message, "Price must be positive");
        assert!(invariant.enabled);
    }

    #[test]
    fn test_entity_definition_new() {
        let entity = EntityDefinition::new(
            "project-123".to_string(),
            "Order".to_string(),
            EntityType::AggregateRoot,
        );
        assert!(!entity.id.is_empty());
        assert_eq!(entity.project_id, "project-123");
        assert_eq!(entity.name, "Order");
        assert_eq!(entity.entity_type, EntityType::AggregateRoot);
        assert!(entity.properties.is_empty());
        assert!(entity.methods.is_empty());
        assert!(entity.invariants.is_empty());
    }

    #[test]
    fn test_entity_definition_timestamps() {
        let before = Utc::now();
        let entity = EntityDefinition::new(
            "project-123".to_string(),
            "Product".to_string(),
            EntityType::Entity,
        );
        let after = Utc::now();

        assert!(entity.created_at >= before && entity.created_at <= after);
        assert!(entity.updated_at >= before && entity.updated_at <= after);
        assert_eq!(entity.created_at, entity.updated_at);
    }

    #[test]
    fn test_validation_types() {
        let types = vec![
            ValidationType::Required,
            ValidationType::MinLength,
            ValidationType::MaxLength,
            ValidationType::Min,
            ValidationType::Max,
            ValidationType::Pattern,
            ValidationType::Email,
            ValidationType::Url,
            ValidationType::Custom,
        ];
        
        // Ensure all types can be created
        for validation_type in types {
            let rule = ValidationRule::new(validation_type.clone(), None, None);
            assert!(!rule.id.is_empty());
        }
    }

    #[test]
    fn test_method_types() {
        let constructor = EntityMethod::new(
            "new".to_string(),
            MethodType::Constructor,
            "Self".to_string(),
        );
        assert_eq!(constructor.method_type, MethodType::Constructor);

        let command = EntityMethod::new(
            "update".to_string(),
            MethodType::Command,
            "()".to_string(),
        );
        assert_eq!(command.method_type, MethodType::Command);

        let query = EntityMethod::new(
            "get_total".to_string(),
            MethodType::Query,
            "f64".to_string(),
        );
        assert_eq!(query.method_type, MethodType::Query);

        let logic = EntityMethod::new(
            "calculate".to_string(),
            MethodType::DomainLogic,
            "bool".to_string(),
        );
        assert_eq!(logic.method_type, MethodType::DomainLogic);
    }

    #[test]
    fn test_default_enabled() {
        assert!(default_enabled());
    }
}
