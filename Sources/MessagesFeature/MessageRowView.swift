//
//  MessageRowView.swift
//  (c) 2022 Binary Scraping Co.
//  LICENSE: MIT
//

import Models
import SwiftUI

struct MessageRowView: View {
  let message: Message

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(message.author.username)
        .frame(maxWidth: .infinity, alignment: .leading)
        .font(.footnote)
        .foregroundColor(.secondary)

      Text(message.message)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .overlay(alignment: .topTrailing) {
      switch message.status {
      case .local:
        ProgressView()
      case .failure:
        Button {} label: {
          Image(systemName: "exclamationmark.icloud")
        }
        .tint(.red)
      case .remote:
        EmptyView()
      }
    }
  }
}

struct MessageRowView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      MessageRowView(message: .local)
      MessageRowView(message: .remote)
      MessageRowView(message: .failure)
    }
    .padding()
  }
}
