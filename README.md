# Lost and Found Pets (Modular Monolith)

[![Ruby CI](https://github.com/kzielonka/pets/actions/workflows/ruby.yml/badge.svg)](https://github.com/kzielonka/pets/actions/workflows/ruby.yml)

A web application designed for pet owners to report lost or found animals, publish announcements, and search for missing pets based on geographic location.

---

## Architecture Overview

This project is built as a **Modular Monolith** using **Ruby on Rails** for the backend infrastructure and **Vue 3 (Vite + TypeScript)** for the frontend.

Unlike traditional "Rails-way" applications where database models, controllers, and business logic are heavily coupled, this codebase isolates core domain responsibilities into separate, standalone Ruby libraries (Gems) in the `modules/` directory.

### Why a Modular Monolith?

The architectural choice is driven by three core priorities:

1. **Domain Encapsulation (Primary)**:
   By structuring modules as independent Gems, we establish clear architectural boundaries. Business logic is isolated from the database framework and HTTP routing layer. Modules do not leak domain details, preventing spaghetti dependencies.
2. **High Testability (Primary)**:
   Because the domain logic is decoupled from active record models, it can be tested in isolation using fast in-memory repositories. Tests run extremely fast (in milliseconds), without the overhead of booting a database or executing migrations.
3. **AI Context & Cost Optimization (Secondary)**:
   Isolating code into small modules with clean interfaces makes it easier for AI assistants to reason about the code. Agents only need to analyze a single submodule to perform a task, reducing prompt token usage and keeping context consumption minimal.

---

## Directory Structure

```directory
├── Dockerfile.dev          # Dev container configuration
├── README.md               # Main project architecture & orchestrator reference
├── compose.yml             # Docker compose configuration for Postgres, Rails & Frontend
├── frontend/               # Frontend single-page application (Vue 3, Vite, TypeScript)
├── rails/                  # Rails delivery layer (Routing, API Controllers, DB Config, Migrations)
└── modules/                # Domain libraries (Gems) implementing core business logic:
    ├── auth/               # User registration, signing in, and JWT authentication
    ├── announcements/      # Managing lost/found pet announcements drafts & publications
    ├── announcements_search/ # Location-based search index (asynchronous read model)
    ├── announcements_map/  # Geographic map pin rendering and clustering algorithms
    └── events_bus/         # Serialized in-memory publish-subscribe broker
```

---

## Module Integration Patterns

To preserve strict separation of concerns, the modules communicate and integrate using these patterns:

### 1. The Facade Pattern & DTOs
Modules do not expose internal models or active record objects. Instead, they expose a single public entry point (a **Facade** class) which takes primitives/DTOs and returns simple data objects (usually Ruby `Struct`s).
* Example: `Auth#sign_in` returns `SignInResult = Struct.new(:authenticated?, :access_token)`.

### 2. Infrastructure Decoupling (Repositories)
Every module defines a `Repos` class that compiles either an in-memory repository (for testing) or an ActiveRecord repository (for production/development):
* `InMemoryRepo`: Keeps data in a Ruby array/hash. Used automatically in test suites to keep them fast.
* `ActiveRecordRepo`: Talks to the database.
* Configured during initialization: `Announcements.new(events_bus, :active_record)` or `Announcements.new(events_bus, :in_memory)`.

### 3. Event-Driven Communication
Instead of modules calling each other directly, they publish events to the `EventsBus`. Decoupled submodules register as subscribers to update their own models.
* For example, when `announcements` publishes an announcement, it emits an `AnnouncementPublished` event. The `announcements_search` module receives this event and updates its read-model in the database table `public_announcements`.

### 4. Rails as an Infrastructure/Delivery Layer
The Rails application (`rails/`) acts solely as a delivery vehicle:
* **Routing and Controllers**: Receives HTTP requests, calls the module Facades, and returns JSON.
* **Dependency Injection**: Stored in `rails/config/initializers/dependencies.rb`. Instantiates the shared `EventsBus` and binds each facade to `Rails.application.config.<module>`.
* **Dynamic Migrations**: An initializer (`rails/config/initializers/module_migrations.rb`) scans `modules/*/db/migrate` and appends them to Rails' db migration paths.

---

## Local Development & Setup

### Prerequisites
- Docker & Docker Compose

### 1. Start the Stack
Start Postgres, the Rails API, and the Vue frontend development server:
```bash
docker compose up -d
```

### 2. Database Migrations
Create and migrate the PostgreSQL database. This aggregates migrations from the Rails app and all active submodules:
```bash
docker compose exec web rails db:create
docker compose exec web rails db:migrate
docker compose exec web rails db:migrate RAILS_ENV=test
```

---

## Test Suites

### Running Backend Integration Tests
These tests run in the Rails application context and test API routing, controllers, and database interactions:
```bash
docker compose exec web rails test
```

### Running Submodule Domain Tests
You can run tests for each individual domain Gem in isolation:
```bash
# Auth module tests
docker compose exec web /bin/bash -c "cd auth; rake test"

# Announcements module tests
docker compose exec web /bin/bash -c "cd announcements; rake test"

# Announcements Search module tests
docker compose exec web /bin/bash -c "cd announcements_search; rake test"

# Announcements Map module tests
docker compose exec web /bin/bash -c "cd announcements_map; rake test"

# Events Bus tests
docker compose exec web /bin/bash -c "cd events_bus; rake test"
```

### Running Frontend Tests
```bash
docker compose exec frontend npm run test:unit run  # Run unit tests
docker compose exec frontend npm run lint            # Run linter
docker compose exec frontend npm run type-check      # Run TypeScript compiler checks
```
