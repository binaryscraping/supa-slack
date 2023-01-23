//
//  Models.swift
//  (c) 2023 Binary Scraping Co.
//  LICENSE: MIT
//

import Foundation
import Tagged

public struct User: Identifiable, Codable, Hashable {
  public let id: Tagged<Self, UUID>
  public let username: String

  public init(id: Tagged<Self, UUID>, username: String) {
    self.id = id
    self.username = username
  }
}

public struct Channel: Identifiable, Codable, Hashable {
  public let id: Tagged<Self, Int>
  public let slug: String
  public let lastMessageAt: Date?
  public let unreadMessagesCount: Int

  public init(id: Tagged<Self, Int>, slug: String, lastMessageAt: Date?, unreadMessagesCount: Int) {
    self.id = id
    self.slug = slug
    self.lastMessageAt = lastMessageAt
    self.unreadMessagesCount = unreadMessagesCount
  }

  public static let withUnreadMessages = Channel(
    id: 1,
    slug: "public",
    lastMessageAt: Date(),
    unreadMessagesCount: 3
  )

  public static let withoutUnreadMessages = Channel(
    id: 2,
    slug: "random",
    lastMessageAt: nil,
    unreadMessagesCount: 0
  )
}

public struct Message: Identifiable, Hashable {
  public typealias RemoteID = Tagged<Self, Int>

  public let id: Tagged<Self, UUID>
  public let insertedAt: Date
  public let message: String
  public let author: User
  public let status: Status
  public let readAt: Date?

  public enum Status: Int {
    case local
    case remote
    case failure
  }

  public init(
    id: Tagged<Self, UUID>,
    insertedAt: Date,
    message: String,
    author: User,
    status: Status,
    readAt: Date?
  ) {
    self.id = id
    self.insertedAt = insertedAt
    self.message = message
    self.author = author
    self.status = status
    self.readAt = readAt
  }

  public static let local = Message(
    id: Tagged<Message, UUID>(),
    insertedAt: .now,
    message: "Local message",
    author: .init(id: .init(), username: "grsouza"),
    status: .local,
    readAt: .now
  )
  public static let remote = Message(
    id: Tagged<Message, UUID>(),
    insertedAt: .now,
    message: "Remote message",
    author: .init(id: .init(), username: "grsouza"),
    status: .remote,
    readAt: .now
  )
  public static let failure = Message(
    id: Tagged<Message, UUID>(),
    insertedAt: .now,
    message: "Failure message",
    author: .init(id: .init(), username: "grsouza"),
    status: .failure,
    readAt: .now
  )
}

public struct InsertMessagePayload: Encodable {
  public let message: String
  public let channelID: Int
  public let authorID: UUID

  public init(message: String, channelID: Int, authorID: UUID) {
    self.message = message
    self.channelID = channelID
    self.authorID = authorID
  }

  enum CodingKeys: String, CodingKey {
    case message
    case channelID = "channel_id"
    case authorID = "user_id"
  }
}
