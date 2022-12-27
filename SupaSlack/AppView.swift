import Dependencies
import GoTrue
import Supabase
import SwiftUI

@MainActor
final class AppViewModel: ObservableObject {
  @Dependency(\.auth) private var auth

  @Published private(set) var authInitialized = false
  @Published private(set) var session: Session?
  private var authEventTask: Task<Void, Never>?

  let authViewModel = AuthViewModel()
  let channelListViewModel = ChannelListViewModel()

  init() {
    authEventTask = Task {
      for await _ in auth.authEvent() {
        let session = try? await auth.session()
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
}

struct AppView: View {
  @ObservedObject var viewModel: AppViewModel

  @ViewBuilder
  var body: some View {
    if viewModel.authInitialized {
      if viewModel.session == nil {
        AuthView(viewModel: viewModel.authViewModel)
      } else {
        NavigationStack {
          ChannelListView(model: viewModel.channelListViewModel)
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
