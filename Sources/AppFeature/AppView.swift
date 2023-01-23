//
//  AppView.swift
//  (c) 2022 Binary Scraping Co.
//  LICENSE: MIT
//

import AuthClient
import AuthFeature
import ChannelsFeature
import Dependencies
import MessagesFeature
import Models
import SwiftUI

@MainActor
public final class AppViewModel: ObservableObject {
  @Dependency(\.auth) private var auth

  @Published private(set) var authInitialized = false
  @Published private(set) var session: Session?
  private var authEventTask: Task<Void, Never>?

  let authViewModel = AuthViewModel()
  let channelListViewModel = ChannelListViewModel()
  let syncManager = SyncManager()

  @Published var messageViewModel: MessagesListViewModel?

  public init() {
    authEventTask = Task {
      for await _ in auth.authEvent() {
        let session = try? await auth.session()

        if session != nil {
          await syncManager.start()
        } else {
          await syncManager.stop()
        }

        withAnimation {
          self.session = session
        }
      }
    }
  }

  deinit {
    authEventTask?.cancel()
    authEventTask = nil
  }

  func initialize() async {
    await auth.initialize()
    authInitialized = true
  }

  func didSelectChannel(_ channel: Channel) {
    messageViewModel = withDependencies(from: self) {
      MessagesListViewModel(channel: channel)
    }
  }
}

public struct AppView: View {
  @ObservedObject var viewModel: AppViewModel

  public init(viewModel: AppViewModel) {
    self.viewModel = viewModel
  }

  @ViewBuilder
  public var body: some View {
    if viewModel.authInitialized {
      if viewModel.session == nil {
        AuthView(viewModel: viewModel.authViewModel)
      } else {
        NavigationStack {
          ChannelListView(model: viewModel.channelListViewModel) {
            viewModel.didSelectChannel($0)
          }
          .navigationDestination(unwrapping: $viewModel.messageViewModel) { $messageViewModel in
            MessagesListView(model: messageViewModel)
          }
        }
      }
    } else {
      ProgressView()
        .task {
          await viewModel.initialize()
        }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    AppView(viewModel: AppViewModel())
  }
}
