# Pets

[![Ruby](https://github.com/kzielonka/pets/actions/workflows/ruby.yml/badge.svg)](https://github.com/kzielonka/pets/actions/workflows/ruby.yml)


Start app:
```
docker compose up
```

Set up DB:
```
docker compose exec web rails db:create 
docker compose exec web rails db:migrate 
docker compose exec web rails db:migrate RAILS_ENV=test
```

Run tests
```
docker compose exec web rails test
docker compose exec web /bin/bash -c "cd auth; rake test"
docker compose exec web /bin/bash -c "cd announcements; rake test"
```

## Architecture

It is not typical <b>Rails way</b> application but <b>modular-monolith</b> based on <b>Ruby on Rails</b>.

<b>Ruby on Rails</b> has resposibility of application layer exposing HTTP API and providing programming libraries like `ActiveRecord` or tools like migrations. 
All "domain" code which consists any kind of business logic (not http one) is spread around modules (done in form of gems - Ruby libraries).

There are two modules currently:
* [auth](./auth) - email, password authentication,
* [announcements](./announcements) - managing user announcements.


Modules are done in to make it possible to extracted every single one of them to separate service (server instance) if needed.
To achive that, every one exposes its own Facade object:
* [./auth/lib/auth.rb](./auth/lib/auth.rb),
* [./announcements/lib/announcements.rb](./announcements/lib/announcements.rb),
which list all possible operations provided by the module and return data as simple objects - DTO (similar like http requests on remote server).
