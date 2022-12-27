import Dependencies
import Foundation
import Supabase
import XCTestDynamicOverlay

struct APIClient {
  var fetchChannels: @Sendable () async throws -> [Channel]
  var fetchUser: @Sendable (User.ID) async throws -> User
  var fetchMessages: @Sendable (Channel.ID) async throws -> [Message]
  var addMessage: @Sendable (String, Channel.ID, User.ID) async throws -> Message
}

struct AddMessagePayload: Encodable {
  let message: String
  let channelId: Channel.ID
  let userId: User.ID

  enum CodingKeys: String, CodingKey {
    case message
    case channelId = "channel_id"
    case userId = "user_id"
  }
}

extension APIClient: DependencyKey {
  static let liveValue = Self(
    fetchChannels: {
      try await SupabaseClient.instance.database.from("channels").select().execute().value
    },
    fetchUser: { id in
      try await SupabaseClient.instance.database
        .from("users")
        .select()
        .eq(column: "id", value: id.rawValue)
        .single()
        .execute()
        .value
    },
    fetchMessages: { channelId in
      try await SupabaseClient.instance.database
        .from("messages")
        .select(columns: "*, author:user_id(*)")
        .eq(column: "channel_id", value: channelId.rawValue)
        .order(column: "inserted_at", ascending: false)
        .execute()
        .value
    },
    addMessage: { message, channelId, userId in
      try await SupabaseClient.instance.database
        .from("messages")
        .insert(
          values: AddMessagePayload(message: message, channelId: channelId, userId: userId),
          returning: .representation
        )
        .single()
        .execute()
        .value
    }
  )

  static let testValue = Self(
    fetchChannels: XCTUnimplemented("APIClient.fetchChannels"),
    fetchUser: XCTUnimplemented("APIClient.fetchUser"),
    fetchMessages: XCTUnimplemented("APIClient.fetchMessages"),
    addMessage: XCTUnimplemented("APIClient.addMessage")
  )
}

extension DependencyValues {
  var api: APIClient {
    get { self[APIClient.self] }
    set { self[APIClient.self] = newValue }
  }
}
