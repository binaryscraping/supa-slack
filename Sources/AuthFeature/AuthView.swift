//
//  AuthView.swift
//  (c) 2022 Binary Scraping Co.
//  LICENSE: MIT
//

import AuthClient
import Dependencies
import Helpers
import SwiftUI
import SwiftUIHelpers
import ToastUI

@MainActor
public final class AuthViewModel: ObservableObject {
  public enum Mode {
    case signIn, signUp
  }

  @Dependency(\.auth) private var auth

  @Published var mode: Mode
  @Published var email: EmailAddress
  @Published var password: Password
  @Published var toast: ToastState?

  public init(
    mode: Mode = .signIn,
    email: EmailAddress = EmailAddress(""),
    password: Password = Password("")
  ) {
    self.mode = mode
    self.email = email
    self.password = password
  }

  func primaryActionButtonTapped() async {
    do {
      if mode == .signUp {
        try await signUp()
      } else {
        try await signIn()
      }
    } catch {
      toast = ToastState(error)
    }
  }

  func toggleModeButtonTapped() {
    if mode == .signIn {
      mode = .signUp
    } else {
      mode = .signIn
    }
  }

  private func signUp() async throws {
    let result = try await auth.signUp(email, password)
    if result == .requiresConfirmation {
      toast = ToastState(style: .info, title: "A confirmation email was sent to \(email.rawValue).")
    }
  }

  private func signIn() async throws {
    let result = try await auth.signIn(email, password)
    if result == .requiresConfirmation {
      toast = ToastState(style: .info, title: "A confirmation email was sent to \(email.rawValue).")
    }
  }
}

public struct AuthView: View {
  @ObservedObject var viewModel: AuthViewModel

  public init(viewModel: AuthViewModel) {
    self.viewModel = viewModel
  }

  public var body: some View {
    VStack(spacing: 12) {
      TextField("Email", text: $viewModel.email.rawValue)
        .keyboardType(.emailAddress)
        .textContentType(.emailAddress)
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)

      SecureField("Password", text: $viewModel.password.rawValue)
        .textContentType(.password)
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)

      AsyncButton(viewModel.mode == .signUp ? "Sign up" : "Sign in") {
        await viewModel.primaryActionButtonTapped()
      }
      .buttonStyle(.supa)

      Button(
        viewModel
          .mode == .signUp ? "Already have an account? Sign in." :
          "Don't have an account? Sign up."
      ) {
        viewModel.toggleModeButtonTapped()
      }
    }
    .textFieldStyle(.supa)
    .padding(20)
    .toast(unwrapping: $viewModel.toast)
  }
}

struct AuthView_Previews: PreviewProvider {
  static var previews: some View {
    AuthView(viewModel: AuthViewModel())
  }
}
