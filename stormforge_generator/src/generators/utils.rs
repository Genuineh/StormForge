use heck::{ToSnakeCase, ToPascalCase, ToKebabCase};

/// Convert a type name to Rust type
pub fn to_rust_type(ir_type: &str) -> String {
    // Handle generic types
    if ir_type.starts_with("List<") || ir_type.starts_with("Vec<") {
        let inner = ir_type
            .trim_start_matches("List<")
            .trim_start_matches("Vec<")
            .trim_end_matches('>');
        return format!("Vec<{}>", to_rust_type(inner));
    }
    
    if ir_type.starts_with("Option<") {
        let inner = ir_type.trim_start_matches("Option<").trim_end_matches('>');
        return format!("Option<{}>", to_rust_type(inner));
    }
    
    if ir_type.starts_with("PagedResult<") {
        let inner = ir_type.trim_start_matches("PagedResult<").trim_end_matches('>');
        return format!("PagedResult<{}>", to_rust_type(inner));
    }
    
    // Map primitive types
    match ir_type {
        "String" => "String".to_string(),
        "Integer" => "i64".to_string(),
        "Decimal" => "rust_decimal::Decimal".to_string(),
        "Boolean" => "bool".to_string(),
        "DateTime" => "chrono::DateTime<chrono::Utc>".to_string(),
        "Date" => "chrono::NaiveDate".to_string(),
        "Time" => "chrono::NaiveTime".to_string(),
        "Uuid" => "uuid::Uuid".to_string(),
        // Handle common command DTOs that might not be defined
        // by mapping them to their entity equivalents
        t if t.starts_with("Create") || t.starts_with("Update") => {
            // Try to map CreateOrderItem -> OrderItem
            t.trim_start_matches("Create")
                .trim_start_matches("Update")
                .to_string()
        }
        // Custom types remain as-is (they are aggregate or value object names)
        _ => ir_type.to_string(),
    }
}

/// Convert to snake_case
pub fn to_snake_case(s: &str) -> String {
    s.to_snake_case()
}

/// Convert to PascalCase
pub fn to_pascal_case(s: &str) -> String {
    s.to_pascal_case()
}

/// Convert to kebab-case
pub fn to_kebab_case(s: &str) -> String {
    s.to_kebab_case()
}

/// Convert namespace to Rust module path
pub fn namespace_to_module(namespace: &str) -> String {
    namespace.replace('.', "::")
}

/// Generate file path from namespace and name
pub fn generate_file_path(base: &str, name: &str) -> String {
    format!("{}/{}.rs", base, to_snake_case(name))
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_to_rust_type() {
        assert_eq!(to_rust_type("String"), "String");
        assert_eq!(to_rust_type("Integer"), "i64");
        assert_eq!(to_rust_type("List<String>"), "Vec<String>");
        assert_eq!(to_rust_type("DateTime"), "chrono::DateTime<chrono::Utc>");
    }
    
    #[test]
    fn test_case_conversions() {
        assert_eq!(to_snake_case("OrderId"), "order_id");
        assert_eq!(to_pascal_case("order_id"), "OrderId");
        assert_eq!(to_kebab_case("OrderId"), "order-id");
    }
}
