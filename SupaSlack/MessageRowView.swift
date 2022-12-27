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
  }
}

struct MessageRowView_Previews: PreviewProvider {
  static var previews: some View {
    MessageRowView(message: .mock)
  }
}
