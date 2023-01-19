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
  @Published private(set) var channels: IdentifiedArrayOf<Channel> = []
  @Published private(set) var messages: [Channel.ID: IdentifiedArrayOf<Message>] = [:]

  private var remoteIdToLocalIdMap: [Int: UUID] = [:]

  private func makeMessage(from response: MessageResponse) -> Message {
    if remoteIdToLocalIdMap[response.id] == nil {
      remoteIdToLocalIdMap[response.id] = UUID()
    }

    let message = Message(
      id: remoteIdToLocalIdMap[response.id]!,
      remoteID: response.id,
      insertedAt: response.insertedAt,
      message: response.message,
      channel: response.channel,
      author: response.author,
      status: .remote
    )
    return message
  }

  func fetchChannels() async {
    do {
      channels = try await IdentifiedArrayOf(uniqueElements: api.fetchChannels())
    } catch {
      dump(error)
    }
  }

  func fetchMessages(_ channelId: Channel.ID) async {
    do {
      messages[channelId] = IdentifiedArrayOf(
        uniqueElements: try await api
          .fetchMessages(channelId).map { makeMessage(from: $0) }
      )
    } catch {
      dump(error)
    }
  }

  func submitNewMessage(_ message: String, _ channelId: Channel.ID) async throws -> Message {
    let session = try await auth.session()
    let userID = User.ID(session.user.id)

    // Create a local message object without a remote id.
    var localMessage = try await Message(id: UUID(), remoteID: nil, insertedAt: Date(), message: message, channel: channel(for: channelId), author: author(for: userID), status: .local)

    // Insert local message to update UI.
    messages[channelId, default: []].append(localMessage)

    Task {
      do {
        // Submit message to api.
        let response = try await api.addMessage(message, channelId, User.ID(session.user.id))
        localMessage.apply(response)
        remoteIdToLocalIdMap[response.id] = localMessage.id

      } catch {
        localMessage.status = .failure
      }

      messages[channelId]?.updateOrAppend(localMessage)
    }

    return localMessage
  }

  private func handleMessageDeleted(_ message: Message) {
    messages[message.channel.id]?.remove(id: message.id)
  }

  private func channel(for id: Channel.ID) throws -> Channel {
    guard let channel = channels[id: id] else {
      throw ChannelNotFoundError(id: id)
    }

    return channel
  }

  private func author(for id: User.ID) async throws -> User {
    if let user = users[id: id] {
      return user
    }

    let user = try await api.fetchUser(id)
    users.updateOrAppend(user)
    return user
  }
}

struct ChannelNotFoundError: Error {
  let id: Channel.ID
}
