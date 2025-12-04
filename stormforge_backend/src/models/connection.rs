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
