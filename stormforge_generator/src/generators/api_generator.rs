use crate::generators::utils::*;
use crate::ir::{Command, IRModel, Query};
use anyhow::Result;

pub struct ApiGenerator;

impl ApiGenerator {
    /// Generate Rust code for API endpoints
    pub fn generate(model: &IRModel) -> Result<String> {
        let mut code = String::new();

        // Add imports
        code.push_str(&Self::generate_imports(&model.bounded_context.name));
        code.push_str("\n\n");

        // Generate API router
        code.push_str(&Self::generate_router(model)?);
        code.push_str("\n\n");

        // Generate command endpoints
        for (name, command) in &model.commands {
            code.push_str(&Self::generate_command_handler(name, command)?);
            code.push_str("\n\n");
        }

        // Generate query endpoints
        for (name, query) in &model.queries {
            code.push_str(&Self::generate_query_handler(name, query)?);
            code.push_str("\n\n");
        }

        Ok(code)
    }

    fn generate_imports(context_name: &str) -> String {
        format!(
            r#"use axum::{{
    http::StatusCode,
    response::{{IntoResponse, Json}},
    routing::{{get, post}},
    Router,
}};
use serde::{{Deserialize, Serialize}};
use utoipa::{{ToSchema, OpenApi}};

use crate::domain::{{entities::*, commands::*, events::*}};

/// API documentation
#[derive(OpenApi)]
#[openapi(
    paths(
        // Command endpoints will be listed here
    ),
    components(
        schemas(ApiError)
    ),
    tags(
        (name = "{}", description = "{} API endpoints")
    )
)]
pub struct ApiDoc;

/// Standard API error response
#[derive(Debug, Serialize, Deserialize, ToSchema)]
pub struct ApiError {{
    pub code: String,
    pub message: String,
}}

/// Standard API success response (String variant)
#[derive(Debug, Serialize, Deserialize, ToSchema)]
pub struct ApiResponseString {{
    pub data: String,
}}"#,
            context_name, context_name
        )
    }

    fn generate_router(model: &IRModel) -> Result<String> {
        let mut code = String::new();

        code.push_str("/// Create the API router\n");
        code.push_str("pub fn create_router() -> Router {\n");
        code.push_str("    Router::new()\n");

        // Add command routes
        for (name, _) in &model.commands {
            let endpoint = format!("/{}", to_kebab_case(name));
            let handler = to_snake_case(name);
            code.push_str(&format!(
                "        .route(\"{}\", post({}))\n",
                endpoint, handler
            ));
        }

        // Add query routes
        for (name, _) in &model.queries {
            let endpoint = format!("/{}", to_kebab_case(name));
            let handler = to_snake_case(name);
            code.push_str(&format!(
                "        .route(\"{}\", get({}))\n",
                endpoint, handler
            ));
        }

        code.push_str("}");

        Ok(code)
    }

    fn generate_command_handler(name: &str, command: &Command) -> Result<String> {
        let mut code = String::new();
        let handler_name = to_snake_case(name);

        // Add documentation
        if let Some(desc) = &command.description {
            code.push_str(&format!("/// {}\n", desc));
        }

        code.push_str(&format!("#[utoipa::path(\n"));
        code.push_str(&format!("    post,\n"));
        code.push_str(&format!("    path = \"/{}\",\n", to_kebab_case(name)));
        code.push_str(&format!("    request_body = {},\n", name));
        code.push_str(&format!("    responses(\n"));
        code.push_str(&format!(
            "        (status = 200, description = \"Command executed successfully\"),\n"
        ));
        code.push_str(&format!(
            "        (status = 400, description = \"Invalid request\", body = ApiError),\n"
        ));
        code.push_str(&format!(
            "        (status = 500, description = \"Internal server error\", body = ApiError)\n"
        ));
        code.push_str(&format!("    )\n"));
        code.push_str(&format!(")]\n"));

        code.push_str(&format!("pub async fn {}(\n", handler_name));
        code.push_str(&format!("    Json(payload): Json<{}>,\n", name));
        code.push_str(") -> impl IntoResponse {\n");

        code.push_str("    // Validate command\n");
        code.push_str("    if let Err(e) = payload.validate() {\n");
        code.push_str("        return (StatusCode::BAD_REQUEST, Json(ApiError {\n");
        code.push_str("            code: \"VALIDATION_ERROR\".to_string(),\n");
        code.push_str("            message: e.to_string(),\n");
        code.push_str("        })).into_response();\n");
        code.push_str("    }\n\n");

        code.push_str("    // TODO: Implement command handler logic\n");
        code.push_str("    // 1. Load aggregate from repository\n");
        code.push_str("    // 2. Execute command on aggregate\n");
        code.push_str("    // 3. Store events in event store\n");
        code.push_str("    // 4. Publish events to event bus\n");
        code.push_str("    // 5. Return response\n\n");

        code.push_str("    (StatusCode::OK, Json(ApiResponseString {\n");
        code.push_str("        data: \"Command executed successfully\".to_string(),\n");
        code.push_str("    })).into_response()\n");
        code.push_str("}");

        Ok(code)
    }

    fn generate_query_handler(name: &str, query: &Query) -> Result<String> {
        let mut code = String::new();
        let handler_name = to_snake_case(name);

        // Add documentation
        if let Some(desc) = &query.description {
            code.push_str(&format!("/// {}\n", desc));
        }

        code.push_str(&format!("#[utoipa::path(\n"));
        code.push_str(&format!("    get,\n"));
        code.push_str(&format!("    path = \"/{}\",\n", to_kebab_case(name)));
        code.push_str(&format!("    responses(\n"));
        code.push_str(&format!(
            "        (status = 200, description = \"Query executed successfully\"),\n"
        ));
        code.push_str(&format!(
            "        (status = 404, description = \"Not found\", body = ApiError),\n"
        ));
        code.push_str(&format!(
            "        (status = 500, description = \"Internal server error\", body = ApiError)\n"
        ));
        code.push_str(&format!("    )\n"));
        code.push_str(&format!(")]\n"));

        code.push_str(&format!(
            "pub async fn {}() -> impl IntoResponse {{\n",
            handler_name
        ));

        code.push_str("    // TODO: Implement query handler logic\n");
        code.push_str("    // 1. Fetch data from read model/repository\n");
        code.push_str("    // 2. Transform to response format\n");
        code.push_str("    // 3. Return response\n\n");

        code.push_str("    (StatusCode::OK, Json(ApiResponseString {\n");
        code.push_str("        data: \"Query result\".to_string(),\n");
        code.push_str("    })).into_response()\n");
        code.push_str("}");

        Ok(code)
    }
}
