## Libra

### Troubleshooting
1. Docker command example for running PostgreSQL DB: `docker run --name libra-db -e POSTGRES_DB=libra -e POSTGRES_USER=libra -e POSTGRES_PASSWORD=password -p 5432:5432 -d postgres`.
2. `PostgreSQL error column xxx of relation yyy does not exist`: try to run `vapor run revert --all` to revert all migrations, because they might be incomplete.
3. Decode `Date` type with custom `JSONDecoder`: `req.content.decode(json: Record.self, using: .custom(dates: .millisecondsSince1970))`.
4. Revert all of the migrations: `vapor run revert --all`.
5. `[Future<A>]` has `map` and `flatMap` methods which are able to flatten the array.
6. Consider using `FilterOperator` to make a complex filter on `Model` type.
7. The `attach` method on `Siblings` will NOT handle duplications.
8. It's important to set up environment variable for admin user or just not seeding the admin user in production.
9. Access PostgreSQL on Docker: `docker exec -it libra-db psql -U libra`.
