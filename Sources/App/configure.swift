import Vapor
import Fluent
import FluentSQLiteDriver

// configures your application
public func configure(_ app: Application) throws {

    app.databases.use(.sqlite(.memory), as: .sqlite)
    app.migrations.add(CreateUserEventRecordTable.migration)
    try app.autoMigrate().wait()

    
    // register routes
    try routes(app)
}
