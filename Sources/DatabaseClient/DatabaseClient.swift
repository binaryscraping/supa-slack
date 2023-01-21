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

public struct DatabaseClient {
  public var saveUsers: ([User]) throws -> Void
  public var observeChannels: () -> AsyncThrowingStream<[Channel], Error>
  public var saveChannels: ([SaveChannelPayload]) throws -> Void
  public var insertMessage: (Message) throws -> Void

  public init(
    saveUsers: @escaping ([User]) throws -> Void,
    observeChannels: @escaping () -> AsyncThrowingStream<[Channel], Error>,
    saveChannels: @escaping ([SaveChannelPayload]) throws -> Void,
    insertMessage: @escaping (Message) throws -> Void
  ) {
    self.saveUsers = saveUsers
    self.observeChannels = observeChannels
    self.saveChannels = saveChannels
    self.insertMessage = insertMessage
  }
}

extension DatabaseClient: TestDependencyKey {
  public static var testValue: DatabaseClient {
    DatabaseClient(
      saveUsers: XCTUnimplemented("DatabaseClient.saveUsers"),
      observeChannels: XCTUnimplemented("DatabaseClient.fetchChannels"),
      saveChannels: XCTUnimplemented("DatabaseClient.saveChannels"),
      insertMessage: XCTUnimplemented("DatabaseClient.insertMessage")
    )
  }
}

extension DependencyValues {
  public var db: DatabaseClient {
    get { self[DatabaseClient.self] }
    set { self[DatabaseClient.self] = newValue }
  }
}
