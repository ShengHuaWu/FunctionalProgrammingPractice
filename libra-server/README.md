## Libra

### Troubleshooting
1. Docker command example for running PostgreSQL DB: `docker run --name libra-db -e POSTGRES_DB=libra -e POSTGRES_USER=libra -e POSTGRES_PASSWORD=password -p 5432:5432 -d postgres`.
2. `PostgreSQL error column xxx of relation yyy does not exist`: try to run `vapor run revert --all` to revert all migrations, because they might be incomplete.
3. Decode `Date` type with custom `JSONDecoder`: `req.content.decode(json: Record.self, using: .custom(dates: .millisecondsSince1970))`.
