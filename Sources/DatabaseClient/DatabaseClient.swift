//
//  DatabaseClient.swift
//  (c) 2023 Binary Scraping Co.
//  LICENSE: MIT
//

import Dependencies
import Foundation
import Models

public struct SaveChannelPayload {
  public let id: Int
  public let insertedAt: Date
  public let slug: String
  public let createdBy: UUID

  public init(id: Int, insertedAt: Date, slug: String, createdBy: UUID) {
    self.id = id
    self.insertedAt = insertedAt
    self.slug = slug
    self.createdBy = createdBy
  }
}

public struct SaveMessagePayload {
  public let remoteID: Int
  public let insertedAt: Date
  public let message: String
  public let channelID: Int
  public let authorID: UUID

  public init(remoteID: Int, insertedAt: Date, message: String, channelID: Int, authorID: UUID) {
    self.remoteID = remoteID
    self.insertedAt = insertedAt
    self.message = message
    self.channelID = channelID
    self.authorID = authorID
  }
}

public struct DatabaseClient {
  public var saveUsers: ([User]) throws -> Void
  public var observeChannels: () -> AsyncThrowingStream<[Channel], Error>
  public var saveChannels: ([SaveChannelPayload]) throws -> Void
  public var insertMessage: (InsertMessagePayload) throws -> Message.ID
  public var observeMessages: (Channel.ID) -> AsyncThrowingStream<[Message], Error>
  public var saveMessages: ([SaveMessagePayload]) throws -> Void
  public var updateMessage: (Message.ID, Message.RemoteID?, Message.Status) throws -> Void
  public var readMessage: (Message.ID) throws -> Void

  public init(
    saveUsers: @escaping ([User]) throws -> Void,
    observeChannels: @escaping () -> AsyncThrowingStream<[Channel], Error>,
    saveChannels: @escaping ([SaveChannelPayload]) throws -> Void,
    insertMessage: @escaping (InsertMessagePayload) throws -> Message.ID,
    observeMessages: @escaping (Channel.ID) -> AsyncThrowingStream<[Message], Error>,
    saveMessages: @escaping ([SaveMessagePayload]) throws -> Void,
    updateMessage: @escaping (Message.ID, Message.RemoteID?, Message.Status) throws -> Void,
    readMessage: @escaping (Message.ID) throws -> Void
  ) {
    self.saveUsers = saveUsers
    self.observeChannels = observeChannels
    self.saveChannels = saveChannels
    self.insertMessage = insertMessage
    self.observeMessages = observeMessages
    self.saveMessages = saveMessages
    self.updateMessage = updateMessage
    self.readMessage = readMessage
  }
}

extension DatabaseClient: TestDependencyKey {
  public static var testValue: DatabaseClient {
    DatabaseClient(
      saveUsers: unimplemented("DatabaseClient.saveUsers"),
      observeChannels: unimplemented("DatabaseClient.fetchChannels"),
      saveChannels: unimplemented("DatabaseClient.saveChannels"),
      insertMessage: unimplemented("DatabaseClient.insertMessage"),
      observeMessages: unimplemented("DatabaseClient.observeMessages"),
      saveMessages: unimplemented("DatabaseClient.saveMessages"),
      updateMessage: unimplemented("DatabaseClient.updateMessage"),
      readMessage: unimplemented("DatabaseClient.readMessage")
    )
  }
}

extension DependencyValues {
  public var db: DatabaseClient {
    get { self[DatabaseClient.self] }
    set { self[DatabaseClient.self] = newValue }
  }
}
