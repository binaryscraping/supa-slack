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

public struct Message: Identifiable, Codable, Hashable {
  public typealias RemoteID = Tagged<Self, Int>

  public let id: Tagged<Self, UUID>
  public let remoteID: RemoteID?
  public let insertedAt: Date
  public let message: String
  public let channelID: Channel.ID
  public let authorID: User.ID
  public let status: Status

  public enum Status: Int, Codable {
    case local
    case remote
    case failure
  }

  public init(
    id: Tagged<Self, UUID>,
    remoteID: RemoteID?,
    insertedAt: Date,
    message: String,
    channelID: Channel.ID,
    authorID: User.ID,
    status: Status
  ) {
    self.id = id
    self.remoteID = remoteID
    self.insertedAt = insertedAt
    self.message = message
    self.channelID = channelID
    self.authorID = authorID
    self.status = status
  }
}
