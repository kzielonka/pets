# Auth Module

This module manages user registration, email/password validation, credential persistence, secure password hashing, and stateless JWT token authentication.

---

## public API

The public interface for this module is documented directly in the code of the [Auth Facade](file:///Users/krzysztofzielonka/Projects/pets/modules/auth/lib/auth.rb) using YARD/Ruby documentation comments.

---

## Directory Structure

```directory
├── lib/
│   ├── auth.rb                  # Public facade
│   └── auth/
│       ├── access_token.rb       # DTO representing a raw access token
│       ├── credentials.rb        # Credential aggregate root (user_id, email, password)
│       ├── email.rb              # Email value object (validates email format)
│       ├── encrypted_password.rb # Secure hash value object
│       ├── errors.rb             # Module-specific runtime errors
│       ├── jwt_access_token.rb   # Handles JWT encoding, decoding, and validation logic
│       ├── password.rb           # Raw password value object (length/complexity checks)
│       ├── password_factory.rb   # Instantiates hashing engines (:bcrypt / :fake_crypt)
│       ├── repos.rb              # Repository adapter (InMemoryRepo / ActiveRecordRepo)
│       ├── serialized_credentials.rb # Read-model representation of credentials
│       └── user_id.rb            # UUID wrapper value object
└── test/                         # Unit and integration tests for auth Gem
```

---

## Infrastructure & Database Schema

This module owns and writes to the `credentials` table when utilizing the `:active_record` repository.

### Database Table: `credentials`
- `id` (uuid, primary key): Unique identifier.
- `user_id` (uuid, index, unique): Associated user ID.
- `email` (string, index, unique): User's email address.
- `password` (string): BCrypt hashed password.
- `created_at` / `updated_at` (timestamps)

---

## Events
This module does not publish or subscribe to any system events.

---

## Running Tests

Run tests in isolation:
```bash
# Locally
bundle exec rake test

# Via Docker
docker compose exec web /bin/bash -c "cd auth; rake test"
```
