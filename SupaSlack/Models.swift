//
//  Models.swift
//  SupaSlack
//
//  Created by Guilherme Souza on 24/12/22.
//

import Foundation
import Tagged

struct Channel: Identifiable, Codable, Hashable {
  let id: Tagged<Self, Int>
  let insertedAt: Date
  let slug: String
  let createdBy: User.ID

  enum CodingKeys: String, CodingKey {
    case id
    case insertedAt = "inserted_at"
    case slug
    case createdBy = "created_by"
  }

  static let mock = Self(id: .init(1), insertedAt: Date(), slug: "random", createdBy: .init(UUID()))
}

enum UserStatus: String, Codable {
  case online = "ONLINE"
  case offline = "OFFLINE"
}

struct User: Identifiable, Codable, Hashable {
  let id: Tagged<Self, UUID>
  let username: String
  let status: UserStatus

  static let mock = User(id: .init(), username: "grsouza", status: .online)
}

struct Message: Identifiable, Codable, Hashable {
  let id: Tagged<Self, Int>
  let insertedAt: Date
  let message: String
  let userID: User.ID
  let channelID: Channel.ID
  var author: User?

  enum CodingKeys: String, CodingKey {
    case id
    case insertedAt = "inserted_at"
    case message
    case userID = "user_id"
    case channelID = "channel_id"
    case author
  }

  static let mock = Self(
    id: 1,
    insertedAt: Date(),
    message: "",
    userID: User.mock.id,
    channelID: 1,
    author: .mock
  )
}
