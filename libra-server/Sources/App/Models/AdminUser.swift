import FluentPostgreSQL
import Crypto

struct AdminUser: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        // !!!: Remember to set up environment variable
        let plainPassword = Environment.get("ADMIN_PASSWORD") ?? "password"
        guard let hashedPassword = try? BCrypt.hash(plainPassword) else {
            preconditionFailure("Failed to create the admin user")
        }

        let user = User(firstName: "admin", lastName: "admin", username: "admin", password: hashedPassword, email: "admin@libra.co")
        return user.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
