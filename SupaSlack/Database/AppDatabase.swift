//
//  AppDatabase.swift
//  SupaSlack
//
//  Created by Guilherme Souza on 19/01/23.
//

import Foundation
import GRDB

struct AppDatabase {
  init(_ dbWriter: any DatabaseWriter) throws {
    self.dbWriter = dbWriter
    try migrator.migrate(dbWriter)
  }

  private let dbWriter: any DatabaseWriter

  private var migrator: DatabaseMigrator {
    var migrator = DatabaseMigrator()

    #if DEBUG
      migrator.eraseDatabaseOnSchemaChange = true
    #endif

    migrator.registerMigration("createChannel") { db in
      try db.create(table: "channel") { t in
        t.column("id", .integer).primaryKey()
        t.column("insertedAt", .datetime).notNull()
        t.column("slug", .text).notNull()
        t.column("createdBy", .text).notNull().references("user", column: "id")
      }
    }

    migrator.registerMigration("createUser") { db in
      try db.create(table: "user") { t in
        t.column("id", .text).primaryKey()
        t.column("username", .text).notNull()
        t.column("status", .text).notNull()
      }
    }

    migrator.registerMigration("createMessage") { db in
      try db.create(table: "message") { t in
        t.column("id", .text).primaryKey()
        t.column("remoteID", .integer).unique()
        t.column("insertedAt", .date).notNull()
        t.column("message", .text).notNull().check { length($0) > 0 }
        t.column("channelId", .integer).notNull().references("channel", column: "id")
        t.column("authorId", .text).notNull().references("user", column: "id")
        t.column("status", .integer).notNull()
      }
    }

    return migrator
  }
}
