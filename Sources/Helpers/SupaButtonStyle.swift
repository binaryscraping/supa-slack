//
//  SupaButtonStyle.swift
//  (c) 2022 Binary Scraping Co.
//  LICENSE: MIT
//

import SwiftUI

public struct SupaButtonStyle: ButtonStyle {
  public func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .frame(maxWidth: .infinity)
      .padding()
      .background(Color.accentColor)
      .foregroundColor(.white)
      .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
      .scaleEffect(
        configuration
          .isPressed ? CGSize(width: 1.05, height: 1.05) : CGSize(width: 1, height: 1)
      )
  }
}

extension ButtonStyle where Self == SupaButtonStyle {
  public static var supa: SupaButtonStyle {
    SupaButtonStyle()
  }
}

struct SupaButtonStyle_Previews: PreviewProvider {
  static var previews: some View {
    Button("Click me") {}
      .buttonStyle(.supa)
      .padding()
  }
}
