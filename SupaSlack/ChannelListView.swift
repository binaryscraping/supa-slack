import Combine
import Dependencies
import Supabase
import SwiftUI
import ToastUI

@MainActor
final class ChannelListViewModel: ObservableObject {
  @Dependency(\.store) private var store

  var channels: [Channel] {
    store.channels
  }

  private var cancellable: AnyCancellable?
  init() {
    cancellable = store.objectWillChange.sink { [weak self] in self?.objectWillChange.send() }
  }

  func loadChannels() async {
    await store.fetchChannels()
  }

  func makeMessagesListViewModel(for channel: Channel) -> MessagesListViewModel {
    MessagesListViewModel(channel: channel)
  }
}

struct ChannelListView: View {
  @ObservedObject var model: ChannelListViewModel

  var body: some View {
    List {
      ForEach(model.channels) { channel in
        NavigationLink(channel.slug, value: model.makeMessagesListViewModel(for: channel))
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle("Channels")
    .animation(.default, value: model.channels)
    .task { await model.loadChannels() }
    .refreshable { await model.loadChannels() }
    .navigationDestination(for: MessagesListViewModel.self) { model in
      MessagesListView(model: model)
    }
  }
}

struct ChannelListView_Previews: PreviewProvider {
  static var previews: some View {
    ChannelListView(model: ChannelListViewModel())
  }
}
