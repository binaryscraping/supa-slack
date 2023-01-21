//
//  APIClient.swift
//  (c) 2022 Binary Scraping Co.
//  LICENSE: MIT
//

// import Dependencies
// import Foundation
// @preconcurrency import Supabase
// import XCTestDynamicOverlay
//
// struct APIClient {
//  var fetchChannels: @Sendable () async throws -> [Channel]
//  var fetchUser: @Sendable (User.ID) async throws -> User
//  var fetchMessages: @Sendable (Channel.ID) async throws -> [MessageResponse]
//  var addMessage: @Sendable (String, Channel.ID, User.ID) async throws -> MessageResponse
// }
//
// struct AddMessagePayload: Encodable {
//  let message: String
//  let channelId: Channel.ID
//  let userId: User.ID
//
//  enum CodingKeys: String, CodingKey {
//    case message
//    case channelId = "channel_id"
//    case userId = "user_id"
//  }
// }
//
// extension APIClient: DependencyKey {
//  static var liveValue: Self {
//    @Dependency(\.supabase) var supabase
//
//    return Self(
//      fetchChannels: {
//        try await supabase.database.from("channels").select().execute().value
//      },
//      fetchUser: { id in
//        try await supabase.database
//          .from("users")
//          .select()
//          .eq(column: "id", value: id.rawValue)
//          .single()
//          .execute()
//          .value
//      },
//      fetchMessages: { channelId in
//        try await supabase.database
//          .from("messages")
//          .select(columns: "*, author:user_id(*),channel:channel_id(*)")
//          .eq(column: "channel_id", value: channelId.rawValue)
//          .order(column: "inserted_at", ascending: false)
//          .execute()
//          .value
//      },
//      addMessage: { message, channelId, userId in
//        try await supabase.database
//          .from("messages")
//          .insert(
//            values: AddMessagePayload(message: message, channelId: channelId, userId: userId),
//            returning: .representation
//          )
//          .single()
//          .execute()
//          .value
//      }
//    )
//  }
//
//  static let testValue = Self(
//    fetchChannels: XCTUnimplemented("APIClient.fetchChannels"),
//    fetchUser: XCTUnimplemented("APIClient.fetchUser"),
//    fetchMessages: XCTUnimplemented("APIClient.fetchMessages"),
//    addMessage: XCTUnimplemented("APIClient.addMessage")
//  )
// }
//
// extension DependencyValues {
//  var api: APIClient {
//    get { self[APIClient.self] }
//    set { self[APIClient.self] = newValue }
//  }
// }
