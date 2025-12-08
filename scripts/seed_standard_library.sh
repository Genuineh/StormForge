#!/bin/bash

# Script to seed the library with standard components
# This should be run after the backend is running

API_URL="${API_URL:-http://localhost:8080}"

echo "Seeding Standard Library Components..."
echo "API URL: $API_URL"
echo ""

# Function to publish a component
publish_component() {
    local name=$1
    local namespace=$2
    local type=$3
    local description=$4
    local definition=$5
    
    echo "Publishing: $name ($namespace)"
    
    curl -X POST "$API_URL/api/library/components" \
        -H "Content-Type: application/json" \
        -d "{
            \"name\": \"$name\",
            \"namespace\": \"$namespace\",
            \"scope\": \"enterprise\",
            \"type\": \"$type\",
            \"version\": \"1.0.0\",
            \"description\": \"$description\",
            \"author\": \"StormForge Platform\",
            \"tags\": [\"standard\", \"common\"],
            \"definition\": $definition
        }" \
        -w "\nHTTP Status: %{http_code}\n\n"
}

# 1. Money Value Object
echo "1. Money Value Object"
publish_component \
    "Money" \
    "com.stormforge.common.Money" \
    "valueObject" \
    "Represents a monetary amount with currency" \
    '{
        "type": "valueObject",
        "properties": [
            {
                "name": "amount",
                "type": "decimal",
                "description": "The monetary amount",
                "validation": {
                    "required": true,
                    "min": 0
                }
            },
            {
                "name": "currency",
                "type": "string",
                "description": "ISO 4217 currency code",
                "validation": {
                    "required": true,
                    "pattern": "^[A-Z]{3}$"
                }
            }
        ],
        "methods": [
            {
                "name": "add",
                "parameters": [{"name": "other", "type": "Money"}],
                "returnType": "Money",
                "description": "Add two monetary amounts"
            },
            {
                "name": "subtract",
                "parameters": [{"name": "other", "type": "Money"}],
                "returnType": "Money",
                "description": "Subtract two monetary amounts"
            }
        ]
    }'

# 2. Address Value Object
echo "2. Address Value Object"
publish_component \
    "Address" \
    "com.stormforge.common.Address" \
    "valueObject" \
    "Represents a physical address" \
    '{
        "type": "valueObject",
        "properties": [
            {
                "name": "street",
                "type": "string",
                "description": "Street address",
                "validation": {"required": true}
            },
            {
                "name": "city",
                "type": "string",
                "description": "City name",
                "validation": {"required": true}
            },
            {
                "name": "state",
                "type": "string",
                "description": "State or province"
            },
            {
                "name": "postalCode",
                "type": "string",
                "description": "Postal or ZIP code",
                "validation": {"required": true}
            },
            {
                "name": "country",
                "type": "string",
                "description": "ISO 3166-1 alpha-2 country code",
                "validation": {
                    "required": true,
                    "pattern": "^[A-Z]{2}$"
                }
            }
        ]
    }'

# 3. Email Value Object
echo "3. Email Value Object"
publish_component \
    "Email" \
    "com.stormforge.common.Email" \
    "valueObject" \
    "Represents a validated email address" \
    '{
        "type": "valueObject",
        "properties": [
            {
                "name": "value",
                "type": "string",
                "description": "Email address",
                "validation": {
                    "required": true,
                    "pattern": "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
                }
            }
        ],
        "methods": [
            {
                "name": "getDomain",
                "returnType": "string",
                "description": "Extract domain from email"
            }
        ]
    }'

# 4. Phone Value Object
echo "4. Phone Value Object"
publish_component \
    "Phone" \
    "com.stormforge.common.Phone" \
    "valueObject" \
    "Represents a phone number with country code" \
    '{
        "type": "valueObject",
        "properties": [
            {
                "name": "countryCode",
                "type": "string",
                "description": "International country calling code",
                "validation": {
                    "required": true,
                    "pattern": "^\\+[1-9]\\d{0,3}$"
                }
            },
            {
                "name": "number",
                "type": "string",
                "description": "Phone number without country code",
                "validation": {
                    "required": true,
                    "pattern": "^[0-9]{6,15}$"
                }
            }
        ],
        "methods": [
            {
                "name": "format",
                "returnType": "string",
                "description": "Format phone number for display"
            }
        ]
    }'

# 5. Pagination Pattern
echo "5. Pagination Pattern"
publish_component \
    "Pagination" \
    "com.stormforge.patterns.Pagination" \
    "valueObject" \
    "Standard pagination parameters and metadata" \
    '{
        "type": "valueObject",
        "properties": [
            {
                "name": "page",
                "type": "integer",
                "description": "Current page number (1-based)",
                "validation": {
                    "required": true,
                    "min": 1
                }
            },
            {
                "name": "pageSize",
                "type": "integer",
                "description": "Number of items per page",
                "validation": {
                    "required": true,
                    "min": 1,
                    "max": 100
                }
            },
            {
                "name": "totalItems",
                "type": "integer",
                "description": "Total number of items"
            },
            {
                "name": "totalPages",
                "type": "integer",
                "description": "Total number of pages"
            }
        ]
    }'

# 6. Error Response Pattern
echo "6. Error Response Pattern"
publish_component \
    "ErrorResponse" \
    "com.stormforge.patterns.ErrorResponse" \
    "valueObject" \
    "Standard error response format" \
    '{
        "type": "valueObject",
        "properties": [
            {
                "name": "code",
                "type": "string",
                "description": "Error code",
                "validation": {"required": true}
            },
            {
                "name": "message",
                "type": "string",
                "description": "Human-readable error message",
                "validation": {"required": true}
            },
            {
                "name": "details",
                "type": "object",
                "description": "Additional error details"
            },
            {
                "name": "timestamp",
                "type": "datetime",
                "description": "When the error occurred"
            }
        ]
    }'

echo ""
echo "Standard library seeding completed!"
echo ""
echo "To verify, check the library browser at: http://localhost:8080/swagger-ui"
