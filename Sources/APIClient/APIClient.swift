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

public struct APIClient: Sendable {
  public var fetchChannels: @Sendable () async throws -> [ChannelResponse]
  public var fetchUsers: @Sendable ([User.ID]) async throws -> [User]

  public init(
    fetchChannels: @escaping @Sendable () async throws -> [ChannelResponse],
    fetchUsers: @escaping @Sendable ([User.ID]) async throws -> [User]
  ) {
    self.fetchChannels = fetchChannels
    self.fetchUsers = fetchUsers
  }
}

extension APIClient: TestDependencyKey {
  public static let testValue = APIClient(
    fetchChannels: unimplemented("APIClient.fetchChannels"),
    fetchUsers: unimplemented("APIClient.fetchUsers")
  )
}

extension DependencyValues {
  public var api: APIClient {
    get { self[APIClient.self] }
    set { self[APIClient.self] = newValue }
  }
}
