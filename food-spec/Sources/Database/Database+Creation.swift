import Foundation
import GRDB
import os

func createAppDatabase() -> some DatabaseWriter {
    do {
        // Apply recommendations from
        // <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/databaseconnections>
        //
        // Create the "Application Support/Database" directory if needed
        let fileManager = FileManager.default
        let appSupportURL = try fileManager.url(
            for: .applicationSupportDirectory, in: .userDomainMask,
            appropriateFor: nil, create: true)
        let directoryURL = appSupportURL.appendingPathComponent("Database", isDirectory: true)

        // Support for tests: delete the database if requested
        if CommandLine.arguments.contains("-reset") {
            try? fileManager.removeItem(at: directoryURL)
        }

        // Create the database folder if needed
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)

        // Open or create the database
        let databaseURL = directoryURL.appendingPathComponent("db.sqlite")
        NSLog("Database stored at \(databaseURL.path)")
        let dbPool = try DatabasePool(
            path: databaseURL.path,
            // Use default AppDatabase configuration
            configuration: createDatabaseConfiguration()
        )

        // Create the AppDatabase
        try setupDatabase(dbPool)

        return dbPool
    } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate.
        //
        // Typical reasons for an error here include:
        // * The parent directory cannot be created, or disallows writing.
        // * The database is not accessible, due to permissions or data protection when the device is locked.
        // * The device is out of space.
        // * The database could not be migrated to its latest schema version.
        // Check the error message to determine what the actual problem was.
        fatalError("Unresolved error \(error)")
    }
}

fileprivate func setupDatabase(_ writer: any DatabaseWriter) throws {
    var migrator = DatabaseMigrator()

//#if DEBUG
//    // Speed up development by nuking the database when migrations change
//    // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/migrations>
//    migrator.eraseDatabaseOnSchemaChange = true
//#endif

    migrator.registerMigration("createFood") { db in
        // Create a table
        // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/databaseschema>
        try db.create(table: "food") { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("name", .text).notNull().unique(onConflict: .replace)
            t.column("energy", .double)
            t.column("fatTotal", .double)
            t.column("fatSaturated", .double)
            t.column("protein", .double)
            t.column("sodium", .double)
            t.column("potassium", .double)
            t.column("cholesterol", .double)
            t.column("carbohydrate", .double)
            t.column("fiber", .double)
            t.column("sugar", .double)
        }
    }

    migrator.registerMigration("createRecipe") { db in
        try db.create(table: "recipe") { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("name", .text).notNull().unique(onConflict: .replace)
            t.column("instructions")
        }

        try db.create(table: "foodQuantity") { t in
            t.autoIncrementedPrimaryKey("id")
            t.belongsTo("recipe").notNull()
            t.column("foodId", .integer).notNull().references("food")
            t.column("quantity", .double).notNull()
        }
    }


    // Migrations for future application versions will be inserted here:
    // migrator.registerMigration(...) { db in
    //     ...
    // }

    try migrator.migrate(writer)
}

fileprivate func createDatabaseConfiguration(_ base: Configuration = Configuration()) -> Configuration {
    var config = base

    // An opportunity to add required custom SQL functions or
    // collations, if needed:
    // config.prepareDatabase { db in
    //     db.add(function: ...)
    // }

    // Log SQL statements if the `SQL_TRACE` environment variable is set.
    // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/database/trace(options:_:)>
    if ProcessInfo.processInfo.environment["SQL_TRACE"] != nil {
        let sqlLogger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "GRDB")
        config.prepareDatabase { db in
            db.trace {
                sqlLogger.log(level: .debug, "\($0)")
            }
        }
    }

#if DEBUG
    // Protect sensitive information by enabling verbose debugging in
    // DEBUG builds only.
    // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/configuration/publicstatementarguments>
    config.publicStatementArguments = true
#endif

    return config
}
