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
