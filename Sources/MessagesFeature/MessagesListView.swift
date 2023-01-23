//
//  MessagesListView.swift
//  (c) 2022 Binary Scraping Co.
//  LICENSE: MIT
//

import APIClient
import AuthClient
import DatabaseClient
import Dependencies
import Models
import SwiftUI

@MainActor
public final class MessagesListViewModel: ObservableObject {
  let channel: Channel

  @Published var isLoadingMessages = false
  @Published var messages: [Message] = [] {
    didSet {
      retryMessages()
    }
  }

  @Published var newMessage: String = ""

  private var _scrollID: Message.ID?
  @Published var scrollToMessageId: Message.ID?

  @Dependency(\.db) private var db
  @Dependency(\.api) private var api
  @Dependency(\.auth) private var auth

  private var observeMessagesTask: Task<Void, Never>?

  public init(channel: Channel) {
    self.channel = channel

    observeMessagesTask = Task {
      do {
        for try await messages in db.observeMessages(channel.id) {
          self.messages = messages

          if messages.contains(where: { $0.id == _scrollID }) {
            scrollToMessageId = _scrollID
            _scrollID = nil
          }
        }
      } catch {
        dump(error)
      }
    }
  }

  deinit {
    observeMessagesTask?.cancel()
    observeMessagesTask = nil
  }

  func fetchMessages() async {
    isLoadingMessages = true
    defer { isLoadingMessages = false }

    do {
      let messages = try await api.fetchMessages(channel.id)
      try await fetchAndSaveUsers(ids: messages.map { .init($0.authorID) })
      try db.saveMessages(messages.map {
        .init(
          remoteID: $0.id,
          insertedAt: $0.insertedAt,
          message: $0.message,
          channelID: $0.channelID,
          authorID: $0.authorID
        )
      })
    } catch {
      dump(error)
    }
  }

  func fetchAndSaveUsers(ids: [User.ID]) async throws {
    let users = try await api.fetchUsers(ids)
    try db.saveUsers(users)
  }

  func submitNewMessageButtonTapped() {
    Task {
      do {
        let currentUserID = try await auth.session().user.id
        try await fetchAndSaveUsers(ids: [.init(currentUserID)])
        let insertMessagePayload = InsertMessagePayload(
          message: newMessage,
          channelID: channel.id.rawValue,
          authorID: currentUserID
        )
        let localMessageID = try db.insertMessage(insertMessagePayload)
        newMessage = ""
        _scrollID = localMessageID

        Task {
          await submitMessageToRemote(insertMessagePayload, localID: localMessageID)
        }

      } catch {
        dump(error)
      }
    }
  }

  func read(_ message: Message) {
    guard message.readAt == nil else { return }
    do {
      try db.readMessage(message.id)
    } catch {
      dump(error)
    }
  }

  private func submitMessageToRemote(_ payload: InsertMessagePayload, localID: Message.ID) async {
    do {
      let remoteMessage = try await api.insertMessage(payload)
      try? db.updateMessage(localID, .init(remoteMessage.id), .remote)
    } catch {
      dump(error)
      try? db.updateMessage(localID, nil, .failure)
    }
  }

  private func retryMessages() {
    Task {
      let unsyncedMessages = messages.filter { $0.status != .remote }
      for message in unsyncedMessages {
        let payload = InsertMessagePayload(
          message: message.message,
          channelID: channel.id.rawValue,
          authorID: message.author.id.rawValue
        )
        await submitMessageToRemote(payload, localID: message.id)
      }
    }
  }
}

public struct MessagesListView: View {
  @ObservedObject var model: MessagesListViewModel

  public init(model: MessagesListViewModel) {
    self.model = model
  }

  public var body: some View {
    ScrollViewReader { proxy in
      ScrollView {
        LazyVStack(spacing: 0) {
          if model.isLoadingMessages {
            ProgressView()
              .padding()
              .flippedUpsideDown()
          }

          ForEach(model.messages) { message in
            MessageRowView(message: message)
              .padding()
              .flippedUpsideDown()
              .id(message.id)
              .onAppear { model.read(message) }
          }
        }
        .animation(.default, value: model.messages)
      }
      .flippedUpsideDown()
      .frame(maxWidth: .infinity)
      .clipped()
      .safeAreaInset(edge: .bottom) {
        ComposeMessageView(message: $model.newMessage) {
          model.submitNewMessageButtonTapped()
        }
      }
      .onChange(of: model.scrollToMessageId) { messageId in
        if let messageId {
          model.scrollToMessageId = nil
          withAnimation {
            proxy.scrollTo(messageId, anchor: .bottom)
          }
        }
      }
    }
    .task { await model.fetchMessages() }
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle(model.channel.slug)
  }
}

extension View {
  func flippedUpsideDown() -> some View {
    rotationEffect(.radians(Double.pi))
      .scaleEffect(x: -1, y: 1, anchor: .center)
  }
}

struct MessagesListView_Previews: PreviewProvider {
  static var previews: some View {
    MessagesListView(model: MessagesListViewModel(channel: .withUnreadMessages))
  }
}
