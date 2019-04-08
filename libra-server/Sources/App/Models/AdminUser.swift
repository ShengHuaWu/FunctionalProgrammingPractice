import FluentPostgreSQL
import Crypto

struct AdminUser: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        let plainPassword = Environment.get("ADMIN_PASSWORD") ?? "password" // !!!: Remember to set up environment variable
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
