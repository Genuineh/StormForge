use std::process::Command;
use std::path::Path;
use tempfile::TempDir;

#[test]
fn test_generator_order_context() {
    // Skip test if example file doesn't exist
    let input_path = Path::new("../ir_schema/examples/ecommerce/order_context.yaml");
    if !input_path.exists() {
        println!("Skipping test: example file not found");
        return;
    }
    
    // Create temporary output directory
    let temp_dir = TempDir::new().expect("Failed to create temp dir");
    let output_path = temp_dir.path().to_str().unwrap();
    
    // Build the generator in debug mode
    let build_status = Command::new("cargo")
        .args(&["build"])
        .status()
        .expect("Failed to build generator");
    
    assert!(build_status.success(), "Generator build failed");
    
    // Run the generator
    let generate_status = Command::new("./target/debug/stormforge-generator")
        .args(&[
            "generate",
            "--input", input_path.to_str().unwrap(),
            "--output", output_path,
        ])
        .status()
        .expect("Failed to run generator");
    
    assert!(generate_status.success(), "Generator execution failed");
    
    // Verify key files were created
    let generated_files = vec![
        "Cargo.toml",
        "README.md",
        "src/main.rs",
        "src/lib.rs",
        "src/domain/entities.rs",
        "src/domain/commands.rs",
        "src/domain/events.rs",
        "src/api/routes.rs",
        "src/repository/mod.rs",
        "src/infrastructure/event_store.rs",
    ];
    
    for file in generated_files {
        let file_path = Path::new(output_path).join(file);
        assert!(
            file_path.exists(),
            "Expected file not found: {}",
            file
        );
    }
    
    // Try to build the generated service
    let build_generated_status = Command::new("cargo")
        .args(&["build"])
        .current_dir(output_path)
        .status()
        .expect("Failed to build generated service");
    
    assert!(
        build_generated_status.success(),
        "Generated service build failed"
    );
}

#[test]
fn test_validate_command() {
    let input_path = Path::new("../ir_schema/examples/ecommerce/order_context.yaml");
    if !input_path.exists() {
        println!("Skipping test: example file not found");
        return;
    }
    
    // Build the generator
    let build_status = Command::new("cargo")
        .args(&["build"])
        .status()
        .expect("Failed to build generator");
    
    assert!(build_status.success(), "Generator build failed");
    
    // Run validate command
    let validate_status = Command::new("./target/debug/stormforge-generator")
        .args(&[
            "validate",
            "--input", input_path.to_str().unwrap(),
        ])
        .status()
        .expect("Failed to run validator");
    
    assert!(validate_status.success(), "Validation failed");
}
