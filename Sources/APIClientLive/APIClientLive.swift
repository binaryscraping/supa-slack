//
//  APIClientLive.swift
//  (c) 2023 Binary Scraping Co.
//  LICENSE: MIT
//

import APIClient
import Dependencies
import Foundation
import Supabase

extension APIClient: DependencyKey {
  public static let liveValue: APIClient = {
    @Dependency(\.supabase) var supabase

    return APIClient(
      fetchChannels: {
        try await supabase.database.from("channels").select().execute().value
      },
      fetchUsers: { ids in
        try await supabase.database
          .from("users")
          .select()
          .in(column: "id", value: ids.map(\.rawValue))
          .execute()
          .value
      },
      fetchMessages: { channelId in
        try await supabase.database
          .from("messages")
          .select()
          .eq(column: "channel_id", value: channelId.rawValue)
          .execute()
          .value
      },
      insertMessage: { payload in
        try await supabase.database
          .from("messages")
          .insert(values: payload, returning: .representation)
          .single()
          .execute()
          .value
      }
    )
  }()
}
