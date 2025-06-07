# Lost and found pets

[![Ruby](https://github.com/kzielonka/pets/actions/workflows/ruby.yml/badge.svg)](https://github.com/kzielonka/pets/actions/workflows/ruby.yml)

It is web app for pet owners to help them found theirs missing animals.
It allows to publish found/lost pet announcement and browse already published ones.

## How to run it locally?

Start app:
```
docker compose up
```

### Set up DB

Set up DB:
```
docker compose exec web rails db:create 
docker compose exec web rails db:migrate 
docker compose exec web rails db:migrate RAILS_ENV=test
```

### Backend tests
```
docker compose exec web rails test
docker compose exec web /bin/bash -c "cd auth; rake test"
docker compose exec web /bin/bash -c "cd announcements; rake test"
docker compose exec web /bin/bash -c "cd events_bus; rake test"
```

### Frontend tests
```
docker compose exec frontend npm run test:unit run
docker compose exec frontend npm run lint
docker compose exec frontend npm run type-check
```

## Architecture

It is not typical <b>Rails way</b> application but <b>modular-monolith</b> based on <b>Ruby on Rails</b>.

<b>Ruby on Rails</b> acts as "application layer" which exposes HTTP API and tooling like migrations.
All "domain" code which contains all kind of business logic (not http one) is spread around modules directory (done in form of gems - Ruby libraries).

There modules are:
* [auth](./auth) - email, password authentication,
* [announcements](./announcements) - managing user announcements,
* [announcements_search](./announcements_search) - allows searching for announcements by location,
* [events_bus](./events_bus) - module which provides event communication between modules.


Modules are done in the way to make it possible to extracted every single one of them to separate service (server instance) if needed.
To achive that, every one exposes its own Facade object:
* [./auth/lib/auth.rb](./auth/lib/auth.rb),
* [./announcements/lib/announcements.rb](./announcements/lib/announcements.rb),
which list all possible operations provided by the module and return data as simple objects - DTO (similar like http requests on remote server).
