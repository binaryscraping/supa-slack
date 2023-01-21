//
//  ChannelListView.swift
//  (c) 2023 Binary Scraping Co.
//  LICENSE: MIT
//

import APIClient
import DatabaseClient
import Dependencies
import Models
import SwiftUI

@MainActor
public final class ChannelListViewModel: ObservableObject {
  @Published private(set) var channels: [Channel] = []
  @Published private(set) var error: Error? {
    didSet {
      dump(error)
    }
  }

  @Dependency(\.db) var db
  @Dependency(\.api) var api

  public init() {
    Task {
      do {
        for try await channels in db.observeChannels() {
          self.channels = channels
        }
      } catch {
        self.error = error
      }
    }
  }

  func load() async {
    do {
      let channels = try await api.fetchChannels().map {
        SaveChannelPayload(
          id: $0.id,
          insertedAt: $0.insertedAt,
          slug: $0.slug,
          createdBy: $0.createdBy
        )
      }
      try await fetchAndSaveUsers(ids: channels.map(\.createdBy))
      try db.saveChannels(channels)
    } catch {
      self.error = error
    }
  }

  func reload() {
    Task { await load() }
  }

  private func fetchAndSaveUsers(ids: [UUID]) async throws {
    let users = try await api.fetchUsers(ids.map { User.ID($0) })
    try db.saveUsers(users)
  }
}

struct ErrorRow: View {
  let error: Error
  let retry: (() -> Void)?

  init(_ error: Error, retry: (() -> Void)? = nil) {
    self.error = error
    self.retry = retry
  }

  var body: some View {
    HStack(spacing: 12) {
      Text(error.localizedDescription)
        .frame(maxWidth: .infinity, alignment: .leading)

      if let retry {
        Button("Retry") {
          retry()
        }
        .buttonStyle(.bordered)
      }
    }
    .font(.footnote)
    .foregroundColor(Color.white)
    .listRowBackground(Color.error)
  }
}

extension Color {
  static let error = Color.red.opacity(0.8)
}

public struct ChannelListView: View {
  @ObservedObject var model: ChannelListViewModel

  public init(model: ChannelListViewModel) {
    self.model = model
  }

  public var body: some View {
    List {
      if let error = model.error {
        Section {
          ErrorRow(error, retry: { model.reload() })
        }
      }

      Section("Channels") {
        ForEach(model.channels) { channel in
          HStack {
            Text(channel.slug).frame(maxWidth: .infinity, alignment: .leading)
            if channel.unreadMessagesCount > 0 {
              Text("\(channel.unreadMessagesCount)")
            }
          }
          .bold(channel.unreadMessagesCount > 0)
        }
      }
    }
    .animation(.default, value: model.channels)
    .task { await model.load() }
    .refreshable { await model.load() }
    .navigationTitle("Channels")
  }
}

struct ChannelListView_Previews: PreviewProvider {
  static var previews: some View {
    ChannelListView(
      model: withDependencies {
        $0.db.observeChannels = {
          let (stream, continuation) = AsyncThrowingStream<[Channel], Error>
            .streamWithContinuation()
          continuation.yield([.withUnreadMessages, .withoutUnreadMessages])
          return stream
        }

        $0.api.fetchChannels = {
          struct Error: Swift.Error {}
          throw Error()
        }

      } operation: {
        ChannelListViewModel()
      }
    )
  }
}
