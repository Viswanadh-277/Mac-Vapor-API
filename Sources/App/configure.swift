import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor
import Mailgun

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "ios_db",
        password: Environment.get("DATABASE_PASSWORD") ?? "Krify@123",
        database: Environment.get("DATABASE_NAME") ?? "ios_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)
    
  
    app.migrations.add(CreateUser())
    app.migrations.add(CreateListMigration())
    app.migrations.add(CreateItemsListMigration())
    app.migrations.add(AddListIdToItemsList())
    app.migrations.add(AddUserIdToCreateList())
    try await app.autoMigrate()
    
    // register routes
    try routes(app)
}
