import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentPostgreSQLProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    let db = Environment.get("POSTGRES_DB") ?? "test"
    let host = Environment.get("POSTGRES_HOST") ?? "db"
    let user = Environment.get("POSTGRES_USER") ?? "postgres"
    let pass = Environment.get("POSTGRES_PASSWORD")

    var port = 5432
    if let param = Environment.get("POSTGRES_PORT"), let newPort = Int(param) {
        port = newPort
    }

    let pgConfig = PostgreSQLDatabaseConfig(hostname: host, port: port, username: user, database: db, password: pass)
    let pgsql = PostgreSQLDatabase(config: pgConfig)
    var databases = DatabasesConfig()
    databases.add(database: pgsql, as: .psql)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Todo.self, database: .psql)
    services.register(migrations)

    // WebSocketサーバの作成
    let wss = NIOWebSocketServer.default()

    // WebSocketアップグレードサポートを/echoに追加
    let chatRoom = ChatRoom()
    wss.get("echo", use: chatRoom.handler())

    // WebSocketサーバの登録
    services.register(wss, as: WebSocketServer.self)
}
