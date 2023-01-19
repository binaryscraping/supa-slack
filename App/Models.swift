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

struct MessageResponse: Decodable, Hashable {
  let id: Int
  let insertedAt: Date
  let message: String
  let channel: Channel
  let author: User

  enum CodingKeys: String, CodingKey {
    case id
    case insertedAt = "inserted_at"
    case message
    case channel
    case author
  }
}

struct Message: Identifiable, Hashable, Codable {
  let id: UUID
  var remoteID: Int?
  var insertedAt: Date
  var message: String
  var channel: Channel
  var author: User
  var status: Status

  enum Status: Int, Codable {
    case local
    case remote
    case failure
  }

  static let local = Self(
    id: UUID(),
    remoteID: nil,
    insertedAt: Date(),
    message: "Local message",
    channel: .mock,
    author: .mock,
    status: .local
  )
  static let remote = Self(
    id: UUID(),
    remoteID: 1,
    insertedAt: Date(),
    message: "Remote message",
    channel: .mock,
    author: .mock,
    status: .remote
  )
  static let failure = Self(
    id: UUID(),
    remoteID: nil,
    insertedAt: Date(),
    message: "Failure message",
    channel: .mock,
    author: .mock,
    status: .failure
  )
}

extension Message {
  mutating func apply(_ response: MessageResponse) {
    remoteID = response.id
    message = response.message
    channel = response.channel
    author = response.author
    status = .remote
  }
}
