//
//  MessageRowView.swift
//  SupaSlack
//
//  Created by Guilherme Souza on 26/12/22.
//

import SwiftUI

struct MessageRowView: View {
  let message: Message

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      if let author = message.author {
        Text(author.username)
          .frame(maxWidth: .infinity, alignment: .leading)
          .font(.footnote)
          .foregroundColor(.secondary)
      }

      Text(message.message)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .overlay(alignment: .topTrailing) {
      switch message.status {
      case .local:
        ProgressView()
      case .failure:
        Button {

        } label: {
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
