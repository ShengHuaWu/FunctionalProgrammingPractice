## Libra

### Troubleshooting
1. Docker command example for running PostgreSQL DB: `docker run --name libra-db -e POSTGRES_DB=libra -e POSTGRES_USER=libra -e POSTGRES_PASSWORD=password -p 5432:5432 -d postgres`, and `docker run --name libra-db-test -e POSTGRES_DB=libra-test -e POSTGRES_USER=libra -e POSTGRES_PASSWORD=password -p 5433:5432 -d postgres`.
2. `PostgreSQL error column xxx of relation yyy does not exist`: try to run `vapor run revert --all` to revert all migrations, because they might be incomplete.
3. Decode `Date` type with custom `JSONDecoder`: `req.content.decode(json: Record.self, using: .custom(dates: .millisecondsSince1970))`.
4. `[Future<A>]` has `flatten`, `map` and `flatMap` methods which are able to flatten the array.
5. Consider using `FilterOperator` to make a complex filter on `Model` type.
6. The `attach` method on `Siblings` will NOT handle duplications.
7. It's important to set up environment variable for admin user or just not seeding the admin user in production.
8. Access PostgreSQL on Docker: `docker exec -it libra-db psql -U libra`.
9. Drop all tables: `DROP SCHEMA public CASCADE; CREATE SCHEMA public;`
10. There is a default limit of 1 million bytes for incoming requests, but we can override it by registering a custom `NIOServerConfig` instance `configure.swift`. For example, `services.register(NIOServerConfig.default(maxBodySize: 20_000_000))`.
11. Use `HTTPResponse` to return data directly instead of JSON.
12. Remember to encrypt user's password in unit tests.
13. Generate different tokens for different users respectively while testing. Otherwise, the `requireAuthenticated` method could return an unexpected user.
14. Use `syncShutdownGracefully` to avoid `Sorry, too many clients already` issue on PostgreSQL database while testing.
15. `docker-compose build` and `docker-compose up --abort-on-container-exit` to run the tests with Docker on Linux.
