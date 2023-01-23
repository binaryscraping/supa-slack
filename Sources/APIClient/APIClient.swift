//
//  APIClient.swift
//  (c) 2023 Binary Scraping Co.
//  LICENSE: MIT
//

import Dependencies
import Foundation
import Models

public struct ChannelResponse: Decodable {
  public let id: Int
  public let insertedAt: Date
  public let slug: String
  public let createdBy: UUID

  enum CodingKeys: String, CodingKey {
    case id
    case insertedAt = "inserted_at"
    case slug
    case createdBy = "created_by"
  }
}

public struct MessageResponse: Decodable {
  public let id: Int
  public let insertedAt: Date
  public let message: String
  public let channelID: Int
  public let authorID: UUID

  public init(id: Int, insertedAt: Date, message: String, channelID: Int, authorID: UUID) {
    self.id = id
    self.insertedAt = insertedAt
    self.message = message
    self.channelID = channelID
    self.authorID = authorID
  }

  enum CodingKeys: String, CodingKey {
    case id
    case insertedAt = "inserted_at"
    case message
    case channelID = "channel_id"
    case authorID = "user_id"
  }
}

public struct APIClient: Sendable {
  public var fetchChannels: @Sendable () async throws -> [ChannelResponse]
  public var fetchUsers: @Sendable ([User.ID]) async throws -> [User]
  public var fetchMessages: @Sendable (Channel.ID) async throws -> [MessageResponse]
  public var insertMessage: @Sendable (InsertMessagePayload) async throws -> MessageResponse

  public init(
    fetchChannels: @escaping @Sendable () async throws -> [ChannelResponse],
    fetchUsers: @escaping @Sendable ([User.ID]) async throws -> [User],
    fetchMessages: @escaping @Sendable (Channel.ID) async throws -> [MessageResponse],
    insertMessage: @escaping @Sendable (InsertMessagePayload) async throws -> MessageResponse
  ) {
    self.fetchChannels = fetchChannels
    self.fetchUsers = fetchUsers
    self.fetchMessages = fetchMessages
    self.insertMessage = insertMessage
  }
}

extension APIClient: TestDependencyKey {
  public static let testValue = APIClient(
    fetchChannels: unimplemented("APIClient.fetchChannels"),
    fetchUsers: unimplemented("APIClient.fetchUsers"),
    fetchMessages: unimplemented("APIClient.fetchMessages"),
    insertMessage: unimplemented("APIClient.insertMessage")
  )
}

extension DependencyValues {
  public var api: APIClient {
    get { self[APIClient.self] }
    set { self[APIClient.self] = newValue }
  }
}
