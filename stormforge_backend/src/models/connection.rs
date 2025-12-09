use serde::{Deserialize, Serialize};
use utoipa::ToSchema;

/// The type of connection between EventStorming elements.
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub enum ConnectionType {
    /// Command → Aggregate: Shows which aggregate handles a command
    CommandToAggregate,
    /// Aggregate → Event: Shows which events an aggregate produces
    AggregateToEvent,
    /// Event → Policy: Shows which policies react to an event
    EventToPolicy,
    /// Policy → Command: Shows which command a policy triggers
    PolicyToCommand,
    /// Event → Read Model: Shows which read models are updated by an event
    EventToReadModel,
    /// External System → Command: Shows external systems that trigger commands
    ExternalToCommand,
    /// UI → Command: Shows UI elements that trigger commands
    UiToCommand,
    /// Read Model → UI: Shows UI elements that display read models
    ReadModelToUI,
    /// Custom relationship between elements
    Custom,
}

/// The style of a line in a connection.
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub enum LineStyle {
    /// Solid line
    Solid,
    /// Dashed line
    Dashed,
    /// Dotted line
    Dotted,
}

/// The style of an arrow in a connection.
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub enum ArrowStyle {
    /// Filled arrow
    Filled,
    /// Open arrow
    Open,
    /// No arrow
    None,
}

/// The visual style of a connection.
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct ConnectionStyle {
    /// The color of the connection line (hex format, e.g., "#2196F3")
    pub color: String,
    /// The width of the connection line
    pub stroke_width: f32,
    /// The style of the connection line
    pub line_style: LineStyle,
    /// The style of the arrow
    pub arrow_style: ArrowStyle,
}

/// A typed connection between two elements on the canvas.
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct Connection {
    /// Unique identifier for this connection
    pub id: String,
    /// The ID of the project this connection belongs to
    pub project_id: String,
    /// The ID of the source element
    pub source_id: String,
    /// The ID of the target element
    pub target_id: String,
    /// The type of this connection
    #[serde(rename = "type")]
    pub connection_type: ConnectionType,
    /// Optional label for the connection
    #[serde(default)]
    pub label: String,
    /// The visual style of the connection
    pub style: ConnectionStyle,
    /// Additional metadata for the connection
    #[serde(default)]
    pub metadata: serde_json::Value,
    /// Timestamp when the connection was created
    #[serde(with = "bson::serde_helpers::chrono_datetime_as_bson_datetime")]
    pub created_at: chrono::DateTime<chrono::Utc>,
    /// Timestamp when the connection was last updated
    #[serde(with = "bson::serde_helpers::chrono_datetime_as_bson_datetime")]
    pub updated_at: chrono::DateTime<chrono::Utc>,
}

/// Request to create a new connection.
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct CreateConnectionRequest {
    /// The ID of the source element
    pub source_id: String,
    /// The ID of the target element
    pub target_id: String,
    /// The type of this connection
    #[serde(rename = "type")]
    pub connection_type: ConnectionType,
    /// Optional label for the connection
    #[serde(default)]
    pub label: String,
    /// Optional custom style (if not provided, uses default for connection type)
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub style: Option<ConnectionStyle>,
    /// Additional metadata for the connection
    #[serde(default)]
    pub metadata: serde_json::Value,
}

/// Request to update an existing connection.
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct UpdateConnectionRequest {
    /// Optional new label for the connection
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub label: Option<String>,
    /// Optional new style for the connection
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub style: Option<ConnectionStyle>,
    /// Optional new metadata for the connection
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub metadata: Option<serde_json::Value>,
}

impl Connection {
    /// Creates a new connection with the given parameters.
    pub fn new(
        project_id: String,
        source_id: String,
        target_id: String,
        connection_type: ConnectionType,
        label: String,
        style: ConnectionStyle,
        metadata: serde_json::Value,
    ) -> Self {
        let now = chrono::Utc::now();
        Self {
            id: uuid::Uuid::new_v4().to_string(),
            project_id,
            source_id,
            target_id,
            connection_type,
            label,
            style,
            metadata,
            created_at: now,
            updated_at: now,
        }
    }

    /// Gets the default style for a connection type.
    pub fn default_style_for_type(connection_type: &ConnectionType) -> ConnectionStyle {
        match connection_type {
            ConnectionType::CommandToAggregate
            | ConnectionType::PolicyToCommand
            | ConnectionType::ExternalToCommand
            | ConnectionType::UiToCommand => ConnectionStyle {
                color: "#2196F3".to_string(), // Blue
                stroke_width: 2.0,
                line_style: LineStyle::Dashed,
                arrow_style: ArrowStyle::Filled,
            },
            ConnectionType::AggregateToEvent => ConnectionStyle {
                color: "#FF9800".to_string(), // Orange
                stroke_width: 2.0,
                line_style: LineStyle::Solid,
                arrow_style: ArrowStyle::Filled,
            },
            ConnectionType::EventToPolicy => ConnectionStyle {
                color: "#9C27B0".to_string(), // Purple
                stroke_width: 2.0,
                line_style: LineStyle::Solid,
                arrow_style: ArrowStyle::Filled,
            },
            ConnectionType::EventToReadModel | ConnectionType::ReadModelToUI => ConnectionStyle {
                color: "#4CAF50".to_string(), // Green
                stroke_width: 2.0,
                line_style: LineStyle::Solid,
                arrow_style: ArrowStyle::Filled,
            },
            ConnectionType::Custom => ConnectionStyle {
                color: "#9E9E9E".to_string(), // Grey
                stroke_width: 2.0,
                line_style: LineStyle::Solid,
                arrow_style: ArrowStyle::Open,
            },
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_connection_type_variants() {
        let types = vec![
            ConnectionType::CommandToAggregate,
            ConnectionType::AggregateToEvent,
            ConnectionType::EventToPolicy,
            ConnectionType::PolicyToCommand,
            ConnectionType::EventToReadModel,
            ConnectionType::ExternalToCommand,
            ConnectionType::UiToCommand,
            ConnectionType::ReadModelToUI,
            ConnectionType::Custom,
        ];
        assert_eq!(types.len(), 9);
    }

    #[test]
    fn test_line_style_variants() {
        let _solid = LineStyle::Solid;
        let _dashed = LineStyle::Dashed;
        let _dotted = LineStyle::Dotted;
    }

    #[test]
    fn test_arrow_style_variants() {
        let _filled = ArrowStyle::Filled;
        let _open = ArrowStyle::Open;
        let _none = ArrowStyle::None;
    }

    #[test]
    fn test_connection_new() {
        let style = ConnectionStyle {
            color: "#FF0000".to_string(),
            stroke_width: 3.0,
            line_style: LineStyle::Solid,
            arrow_style: ArrowStyle::Filled,
        };

        let connection = Connection::new(
            "project-123".to_string(),
            "source-1".to_string(),
            "target-2".to_string(),
            ConnectionType::CommandToAggregate,
            "test connection".to_string(),
            style,
            serde_json::json!({}),
        );

        assert!(!connection.id.is_empty());
        assert_eq!(connection.project_id, "project-123");
        assert_eq!(connection.source_id, "source-1");
        assert_eq!(connection.target_id, "target-2");
        assert_eq!(connection.connection_type, ConnectionType::CommandToAggregate);
        assert_eq!(connection.label, "test connection");
        assert_eq!(connection.style.color, "#FF0000");
        assert_eq!(connection.style.stroke_width, 3.0);
    }

    #[test]
    fn test_connection_timestamps() {
        let style = Connection::default_style_for_type(&ConnectionType::Custom);
        let before = chrono::Utc::now();
        let connection = Connection::new(
            "project-123".to_string(),
            "source-1".to_string(),
            "target-2".to_string(),
            ConnectionType::Custom,
            "".to_string(),
            style,
            serde_json::json!({}),
        );
        let after = chrono::Utc::now();

        assert!(connection.created_at >= before && connection.created_at <= after);
        assert!(connection.updated_at >= before && connection.updated_at <= after);
        assert_eq!(connection.created_at, connection.updated_at);
    }

    #[test]
    fn test_default_style_for_command_to_aggregate() {
        let style = Connection::default_style_for_type(&ConnectionType::CommandToAggregate);
        assert_eq!(style.color, "#2196F3");
        assert_eq!(style.stroke_width, 2.0);
        assert_eq!(style.line_style, LineStyle::Dashed);
        assert_eq!(style.arrow_style, ArrowStyle::Filled);
    }

    #[test]
    fn test_default_style_for_aggregate_to_event() {
        let style = Connection::default_style_for_type(&ConnectionType::AggregateToEvent);
        assert_eq!(style.color, "#FF9800");
        assert_eq!(style.line_style, LineStyle::Solid);
        assert_eq!(style.arrow_style, ArrowStyle::Filled);
    }

    #[test]
    fn test_default_style_for_event_to_policy() {
        let style = Connection::default_style_for_type(&ConnectionType::EventToPolicy);
        assert_eq!(style.color, "#9C27B0");
        assert_eq!(style.line_style, LineStyle::Solid);
        assert_eq!(style.arrow_style, ArrowStyle::Filled);
    }

    #[test]
    fn test_default_style_for_event_to_read_model() {
        let style = Connection::default_style_for_type(&ConnectionType::EventToReadModel);
        assert_eq!(style.color, "#4CAF50");
        assert_eq!(style.line_style, LineStyle::Solid);
        assert_eq!(style.arrow_style, ArrowStyle::Filled);
    }

    #[test]
    fn test_default_style_for_custom() {
        let style = Connection::default_style_for_type(&ConnectionType::Custom);
        assert_eq!(style.color, "#9E9E9E");
        assert_eq!(style.line_style, LineStyle::Solid);
        assert_eq!(style.arrow_style, ArrowStyle::Open);
    }

    #[test]
    fn test_all_connection_types_have_default_styles() {
        let types = vec![
            ConnectionType::CommandToAggregate,
            ConnectionType::AggregateToEvent,
            ConnectionType::EventToPolicy,
            ConnectionType::PolicyToCommand,
            ConnectionType::EventToReadModel,
            ConnectionType::ExternalToCommand,
            ConnectionType::UiToCommand,
            ConnectionType::ReadModelToUI,
            ConnectionType::Custom,
        ];

        for connection_type in types {
            let style = Connection::default_style_for_type(&connection_type);
            assert!(!style.color.is_empty());
            assert!(style.stroke_width > 0.0);
        }
    }
}
