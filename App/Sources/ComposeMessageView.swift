//
//  ComposeMessageView.swift
//  SupaSlack
//
//  Created by Guilherme Souza on 26/12/22.
//

import SwiftUI

struct ComposeMessageView: View {
  @Binding var message: String
  let onSubmit: () -> Void

  var isValid: Bool {
    message.isEmpty == false
  }

  var body: some View {
    VStack(spacing: 8) {
      TextField("Compose message", text: $message)
        .submitLabel(.send)
        .onSubmit { onSubmit() }

      HStack {
        Spacer()
        Button(action: onSubmit) {
          Image(systemName: isValid ? "paperplane.fill" : "paperplane")
        }
        .disabled(!isValid)
      }
    }
    .padding()
    .background(.bar)
  }
}

struct ComposeMessageView_Previews: PreviewProvider {
  static var previews: some View {
    ComposeMessageView(message: .constant("")) {}
      .previewLayout(.sizeThatFits)
  }
}
