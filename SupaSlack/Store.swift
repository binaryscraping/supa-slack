//
//  Store.swift
//  SupaSlack
//
//  Created by Guilherme Souza on 24/12/22.
//

import Dependencies
import Foundation
import IdentifiedCollections

extension Store: DependencyKey {
  static let liveValue = Store()
}

extension DependencyValues {
  var store: Store {
    get { self[Store.self] }
    set { self[Store.self] = newValue }
  }
}

@MainActor
final class Store: ObservableObject {
  @Dependency(\.api) private var api
  @Dependency(\.auth) private var auth

  @Published private(set) var users: IdentifiedArrayOf<User> = []
  @Published private(set) var channels: [Channel] = []
  @Published private(set) var messages: [Channel.ID: IdentifiedArrayOf<Message>] = [:]

  func fetchChannels() async {
    do {
      channels = try await api.fetchChannels()
    } catch {}
  }

  func fetchMessages(_ channelId: Channel.ID) async {
    do {
      messages[channelId] = IdentifiedArrayOf(
        uniqueElements: try await api
          .fetchMessages(channelId)
      )
    } catch {}
  }

  func submitNewMessage(_ message: String, _ channelId: Channel.ID) async throws -> Message {
    let session = try await auth.session()
    let message = try await api.addMessage(message, channelId, User.ID(session.user.id))
    return await handleNewMessage(message)
  }

  private func handleNewMessage(_ message: Message) async -> Message {
    var message = message

    if message.author == nil {
      do {
        message.author = try await fetchUser(message.userID)
      } catch {}
    }

    messages[message.channelID, default: []].updateOrAppend(message)

    return message
  }

  private func fetchUser(_ id: User.ID) async throws -> User {
    if let user = users[id: id] {
      return user
    }

    let user = try await api.fetchUser(id)
    users.updateOrAppend(user)
    return user
  }

  private func handleMessageDeleted(_ message: Message) {
    messages[message.channelID]?.remove(id: message.id)
  }
}
