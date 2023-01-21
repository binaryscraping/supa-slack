//
//  MessagesListView.swift
//  (c) 2022 Binary Scraping Co.
//  LICENSE: MIT
//

////
////  MessagesListView.swift
////  SupaSlack
////
////  Created by Guilherme Souza on 26/12/22.
////
//
// import Combine
// import Dependencies
// import SwiftUI
//
// @MainActor
// final class MessagesListViewModel: ObservableObject, Equatable, Hashable {
//  @Dependency(\.store) private var store
//
//  let channel: Channel
//
//  var messages: [Message] {
//    store.messages[channel.id, default: []]
//      .sorted(by: { $0.insertedAt > $1.insertedAt })
//  }
//
//  @Published var newMessage: String = ""
//  @Published var scrollToMessageId: Message.ID?
//
//  private var cancellable: AnyCancellable?
//  init(channel: Channel) {
//    self.channel = channel
//
//    cancellable = store.objectWillChange
//      .sink { [weak self] _ in self?.objectWillChange.send() }
//  }
//
//  func fetchMessages() async {
//    await store.fetchMessages(channel.id)
//  }
//
//  func submitNewMessageButtonTapped() {
//    Task {
//      do {
//        let message = try await store.submitNewMessage(newMessage, channel.id)
//        self.newMessage = ""
//        self.scrollToMessageId = message.id
//      } catch {
//        dump(error)
//      }
//    }
//  }
//
//  nonisolated static func == (lhs: MessagesListViewModel, rhs: MessagesListViewModel) -> Bool {
//    lhs === rhs
//  }
//
//  nonisolated func hash(into hasher: inout Hasher) {
//    hasher.combine(ObjectIdentifier(self))
//  }
// }
//
// struct MessagesListView: View {
//  @ObservedObject var model: MessagesListViewModel
//
//  var body: some View {
//    ScrollViewReader { proxy in
//      ScrollView {
//        LazyVStack(spacing: 0) {
//          ForEach(model.messages) { message in
//            MessageRowView(message: message)
//              .padding()
//              .flippedUpsideDown()
//              .id(message.id)
//          }
//        }
//        .animation(.default, value: model.messages)
//      }
//      .flippedUpsideDown()
//      .frame(maxWidth: .infinity)
//      .clipped()
//      .safeAreaInset(edge: .bottom) {
//        ComposeMessageView(message: $model.newMessage) {
//          model.submitNewMessageButtonTapped()
//        }
//      }
//      .onChange(of: model.scrollToMessageId) { messageId in
//        if let messageId {
//          model.scrollToMessageId = nil
//          withAnimation {
//            proxy.scrollTo(messageId, anchor: .bottom)
//          }
//        }
//      }
//    }
//    .task { await model.fetchMessages() }
//    .navigationTitle(model.channel.slug)
//  }
// }
//
// extension View {
//  func flippedUpsideDown() -> some View {
//    rotationEffect(.radians(Double.pi))
//      .scaleEffect(x: -1, y: 1, anchor: .center)
//  }
// }
//
// struct MessagesListView_Previews: PreviewProvider {
//  static var previews: some View {
//    MessagesListView(model: MessagesListViewModel(channel: .mock))
//  }
// }
