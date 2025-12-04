use anyhow::Result;
use chrono::{Duration, Utc};
use jsonwebtoken::{decode, encode, DecodingKey, EncodingKey, Header, Validation};
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct Claims {
    pub sub: String, // user_id
    pub username: String,
    pub role: String,
    pub exp: i64, // expiration time
    pub iat: i64, // issued at
}

#[derive(Clone)]
pub struct AuthService {
    secret: String,
}

impl AuthService {
    pub fn new(secret: String) -> Self {
        Self { secret }
    }

    pub fn generate_token(&self, user_id: &str, username: &str, role: &str) -> Result<String> {
        let now = Utc::now();
        let expiration = now + Duration::hours(24); // 24 hour expiration

        let claims = Claims {
            sub: user_id.to_string(),
            username: username.to_string(),
            role: role.to_string(),
            exp: expiration.timestamp(),
            iat: now.timestamp(),
        };

        let token = encode(
            &Header::default(),
            &claims,
            &EncodingKey::from_secret(self.secret.as_bytes()),
        )?;

        Ok(token)
    }

    #[allow(dead_code)]
    pub fn verify_token(&self, token: &str) -> Result<Claims> {
        let token_data = decode::<Claims>(
            token,
            &DecodingKey::from_secret(self.secret.as_bytes()),
            &Validation::default(),
        )?;

        Ok(token_data.claims)
    }

    pub fn hash_password(&self, password: &str) -> Result<String> {
        let hash = bcrypt::hash(password, bcrypt::DEFAULT_COST)?;
        Ok(hash)
    }

    pub fn verify_password(&self, password: &str, hash: &str) -> Result<bool> {
        let valid = bcrypt::verify(password, hash)?;
        Ok(valid)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_password_hashing() {
        let auth = AuthService::new("test_secret".to_string());
        let password = "my_secure_password";

        let hash = auth.hash_password(password).unwrap();
        assert!(auth.verify_password(password, &hash).unwrap());
        assert!(!auth.verify_password("wrong_password", &hash).unwrap());
    }

    #[test]
    fn test_token_generation_and_verification() {
        let auth = AuthService::new("test_secret".to_string());
        let user_id = "user123";
        let username = "testuser";
        let role = "developer";

        let token = auth.generate_token(user_id, username, role).unwrap();
        let claims = auth.verify_token(&token).unwrap();

        assert_eq!(claims.sub, user_id);
        assert_eq!(claims.username, username);
        assert_eq!(claims.role, role);
    }
}
