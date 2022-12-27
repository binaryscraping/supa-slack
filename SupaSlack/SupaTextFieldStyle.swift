//
//  SwiftUIView.swift
//  SupaSlack
//
//  Created by Guilherme Souza on 23/12/22.
//

import SwiftUI

struct SupaTextFieldStyle: TextFieldStyle {
  func _body(configuration: TextField<Self._Label>) -> some View {
    configuration
      .padding()
      .background(.regularMaterial)
      .clipShape(
        RoundedRectangle(cornerRadius: 6, style: .continuous)
      )
      .overlay {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
          .stroke(Color.secondary.opacity(0.1), lineWidth: 2)
      }
  }
}

extension TextFieldStyle where Self == SupaTextFieldStyle {
  static var supa: SupaTextFieldStyle {
    SupaTextFieldStyle()
  }
}

struct SwiftUIView_Previews: PreviewProvider {
  static var previews: some View {
    VStack(spacing: 8) {
      TextField("Email", text: .constant(""))
      SecureField("Password", text: .constant(""))
    }
    .textFieldStyle(.supa)
    .padding()
  }
}
