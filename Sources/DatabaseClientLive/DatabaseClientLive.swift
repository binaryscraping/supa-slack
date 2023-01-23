//
//  DatabaseClientLive.swift
//  (c) 2023 Binary Scraping Co.
//  LICENSE: MIT
//

import DatabaseClient
import Dependencies
import Foundation
import GRDB
import Models

extension Channel: FetchableRecord {}

struct UserTable: Codable, FetchableRecord, PersistableRecord {
  static let databaseTableName = "user"

  let id: UUID
  let username: String

  enum Columns {
    static let id = Column(CodingKeys.id)
    static let username = Column(CodingKeys.username)
  }
}

struct ChannelTable: Codable, FetchableRecord, PersistableRecord {
  static let databaseTableName = "channel"

  let id: Int
  let insertedAt: Date
  let slug: String
  let createdBy: UUID

  enum Columns {
    static let id = Column(CodingKeys.id)
  }

  static let messages = hasMany(MessageTable.self)
  var messages: QueryInterfaceRequest<MessageTable> {
    request(for: Self.messages)
  }
}

struct MessageTable: Codable, FetchableRecord, PersistableRecord {
  static let databaseTableName = "message"

  let id: UUID
  let remoteID: Int?
  let insertedAt: Date
  let message: String
  let channelID: Int
  let authorID: UUID
  let status: Status
  let readAt: Date?

  enum Status: Int, Codable {
    case local, remote, failure
  }

  enum Columns {
    static let remoteID = Column(CodingKeys.remoteID)
    static let insertedAt = Column(CodingKeys.insertedAt)
    static let channelID = Column(CodingKeys.channelID)
    static let status = Column(CodingKeys.status)
    static let readAt = Column(CodingKeys.readAt)
  }

  static let channel = belongsTo(ChannelTable.self)
  var channel: QueryInterfaceRequest<ChannelTable> {
    request(for: Self.channel)
  }

  static let author = belongsTo(UserTable.self)
  var author: QueryInterfaceRequest<UserTable> {
    request(for: Self.author)
  }
}

extension DatabaseClient: DependencyKey {
  public static let liveValue = DatabaseClient(.shared)

  public static var memory: DatabaseClient {
    DatabaseClient(.memory)
  }
}

struct DatabaseClientLive {
  static let shared: DatabaseClientLive = {
    do {
      // Pick a folder for storing the SQLite database, as well as
      // the various temporary files created during normal database
      // operations (https://sqlite.org/tempfiles.html).
      let folderURL = URL.applicationSupportDirectory
        .appendingPathComponent("database", isDirectory: true)

      // Support for tests: delete the database if requested
      if CommandLine.arguments.contains("-reset") {
        try? FileManager.default.removeItem(at: folderURL)
      }

      // Create the database folder if needed
      try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)

      // Connect to a database on disk
      // See https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/databaseconnections
      let dbURL = folderURL.appendingPathComponent("db.sqlite")
      let dbPool = try DatabasePool(path: dbURL.path)

      // Create the AppDatabase
      let appDatabase = try DatabaseClientLive(dbPool)

      // Prepare the database with test fixtures if requested
      if CommandLine.arguments.contains("-fixedTestData") {
        //                try appDatabase.createPlayersForUITests()
      } else {
        // Otherwise, populate the database if it is empty, for better
        // demo purpose.
        //                try appDatabase.createRandomPlayersIfEmpty()
      }

      return appDatabase
    } catch {
      // Replace this implementation with code to handle the error appropriately.
      // fatalError() causes the application to generate a crash log and terminate.
      //
      // Typical reasons for an error here include:
      // * The parent directory cannot be created, or disallows writing.
      // * The database is not accessible, due to permissions or data protection when the device is
      // locked.
      // * The device is out of space.
      // * The database could not be migrated to its latest schema version.
      // Check the error message to determine what the actual problem was.
      fatalError("Unresolved error \(error)")
    }
  }()

  static var memory: DatabaseClientLive {
    var configuration = Configuration()
    configuration.prepareDatabase { db in
      db.trace {
        print($0.expandedDescription)
      }
    }
    return try! DatabaseClientLive(DatabaseQueue(configuration: configuration))
  }

  let dbWriter: any DatabaseWriter

  private init(_ dbWriter: any DatabaseWriter) throws {
    self.dbWriter = dbWriter
    try migrator.migrate(dbWriter)
  }

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
        //        t.column("status", .text).notNull()
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
        t.column("readAt", .date)
      }
    }

    return migrator
  }
}

extension DatabaseClient {
  init(_ client: DatabaseClientLive) {
    self.init(
      saveUsers: { users in
        try client.dbWriter.write { db in
          //          try UserTable
          //            .filter(!users.map(\.id.rawValue).contains(UserTable.Columns.id))
          //            .deleteAll(db)

          try users
            .map { UserTable(id: $0.id.rawValue, username: $0.username) }
            .forEach { try $0.save(db) }
        }
      },
      observeChannels: {
        AsyncThrowingStream(
          ValueObservation.tracking { db in
            // TODO: improve following code by using a single Query.
            let allChannels = try ChannelTable.fetchAll(db)
            return try allChannels.map { channel in
              let lastMessageAt = try channel.messages.select([MessageTable.Columns.insertedAt])
                .order(MessageTable.Columns.insertedAt.desc).asRequest(of: Date.self).fetchOne(db)
              let unreadMessagesCount = try channel.messages
                .filter(MessageTable.Columns.readAt == nil).fetchCount(db)
              return Channel(
                id: .init(channel.id),
                slug: channel.slug,
                lastMessageAt: lastMessageAt,
                unreadMessagesCount: unreadMessagesCount
              )
            }
          }
          .values(in: client.dbWriter)
        )
      },
      saveChannels: { channels in
        try client.dbWriter.write { db in
          //          try ChannelTable
          //            .filter(!channels.map(\.id).contains(ChannelTable.Columns.id))
          //            .deleteAll(db)

          try channels.map {
            ChannelTable(
              id: $0.id,
              insertedAt: $0.insertedAt,
              slug: $0.slug,
              createdBy: $0.createdBy
            )
          }
          .forEach { channel in
            try channel.save(db)
          }
        }
      },
      insertMessage: { message in
        try client.dbWriter.write { db in
          let now = Date.now
          let savedMessage = try MessageTable(
            id: UUID(),
            remoteID: nil,
            insertedAt: now,
            message: message.message,
            channelID: message.channelID,
            authorID: message.authorID,
            status: .local,
            readAt: now
          ).saved(db)

          return .init(savedMessage.id)
        }
      },
      observeUnsyncedMessages: {
        AsyncThrowingStream(
          ValueObservation.tracking { db in
            let messages = try MessageTable
              .filter(MessageTable.Columns.status != MessageTable.Status.remote.rawValue)
              .fetchAll(db)
            return try messages.map { message in
              let author = try message.author.fetchOne(db)!
              return Message(
                id: .init(message.id),
                insertedAt: message.insertedAt,
                message: message.message,
                author: .init(id: .init(author.id), username: author.username),
                channelID: .init(message.channelID),
                status: .init(from: message.status),
                readAt: message.readAt
              )
            }
          }
          .values(in: client.dbWriter)
        )
      },
      observeMessages: { channelId in
        AsyncThrowingStream(
          ValueObservation.tracking { db in
            let messages = try MessageTable
              .filter(MessageTable.Columns.channelID == channelId.rawValue)
              .order(MessageTable.Columns.insertedAt.desc).fetchAll(db)
            return try messages.map { message in
              let author = try message.author.fetchOne(db)!
              return Message(
                id: .init(message.id),
                insertedAt: message.insertedAt,
                message: message.message,
                author: .init(id: .init(author.id), username: author.username),
                channelID: .init(message.channelID),
                status: .init(from: message.status),
                readAt: message.readAt
              )
            }
          }
          .values(in: client.dbWriter)
        )
      },
      saveMessages: { messages in
        try client.dbWriter.write { db in
          for message in messages {
            if let storedMessage = try MessageTable
              .filter(MessageTable.Columns.remoteID == message.remoteID).fetchOne(db)
            {
              try MessageTable(
                id: storedMessage.id,
                remoteID: message.remoteID,
                insertedAt: message.insertedAt,
                message: message.message,
                channelID: message.channelID,
                authorID: message.authorID,
                status: .remote,
                readAt: storedMessage.readAt
              )
              .update(db)
            } else {
              try MessageTable(
                id: UUID(),
                remoteID: message.remoteID,
                insertedAt: message.insertedAt,
                message: message.message,
                channelID: message.channelID,
                authorID: message.authorID,
                status: .remote,
                readAt: nil
              )
              .insert(db)
            }
          }
        }
      },
      updateMessage: { id, remoteID, status in
        try client.dbWriter.write { db in
          _ = try MessageTable.filter(key: id.rawValue)
            .updateAll(
              db,
              MessageTable.Columns.remoteID.set(to: remoteID?.rawValue),
              MessageTable.Columns.status.set(to: status.rawValue)
            )
        }
      },
      readMessage: { id in
        try client.dbWriter.write { db in
          _ = try MessageTable.filter(key: id.rawValue)
            .updateAll(db, MessageTable.Columns.readAt.set(to: Date()))
        }
      }
    )
  }
}

extension MessageTable.Status {
  init(from status: Message.Status) {
    switch status {
    case .local:
      self = .local
    case .remote:
      self = .remote
    case .failure:
      self = .failure
    }
  }
}

extension Message.Status {
  init(from status: MessageTable.Status) {
    switch status {
    case .local:
      self = .local
    case .remote:
      self = .remote
    case .failure:
      self = .failure
    }
  }
}
