//
//  AuthClient.swift
//  SupaSlack
//
//  Created by Guilherme Souza on 23/12/22.
//

import ConcurrencyHelpers
import Dependencies
import Foundation
@preconcurrency import GoTrue
@preconcurrency import Supabase
import Tagged
import XCTestDynamicOverlay

enum EmailAddressTag {}
typealias EmailAddress = Tagged<EmailAddressTag, String>

enum PasswordTag {}
typealias Password = Tagged<PasswordTag, String>

enum AuthEvent {
  case signedIn, signedOut
}

enum SignUpResult {
  case signedIn
  case requiresConfirmation
}

struct AuthClient {
  var initialize: @Sendable () async -> Void
  var authEvent: @Sendable () -> AsyncStream<AuthEvent>
  var session: @Sendable () async throws -> Session
  var signUp: @Sendable (EmailAddress, Password) async throws -> SignUpResult
  var signIn: @Sendable (EmailAddress, Password) async throws -> Session
}

extension AuthClient: DependencyKey {
  static var liveValue: Self {
    @Dependency(\.supabase) var supabase
    return Self(
      initialize: {
        await supabase.auth.initialize()
      },
      authEvent: {
        AsyncStream(
          supabase.auth.authEventChange.map { event in
            switch event {
            case .signedIn:
              return .signedIn
            default:
              return .signedOut
            }
          }
        )
      },
      session: {
        try await supabase.auth.session
      },
      signUp: { email, password in
        let result = try await supabase.auth.signUp(
          email: email.rawValue,
          password: password.rawValue
        )

        switch result {
        case let .session(session):
          if session.user.confirmedAt == nil {
            return .requiresConfirmation
          }
          return .signedIn
        case .user:
          return .requiresConfirmation
        }
      },
      signIn: { email, password in
        try await supabase.auth.signIn(
          email: email.rawValue,
          password: password.rawValue
        )
      }
    )
  }

  static let testValue = Self(
    initialize: XCTUnimplemented("AuthClient.initialize"),
    authEvent: XCTUnimplemented("AuthClient.authEvent"),
    session: XCTUnimplemented("AuthClient.session"),
    signUp: XCTUnimplemented("AuthClient.signUp"),
    signIn: XCTUnimplemented("AuthClient.signIn")
  )
}

extension DependencyValues {
  var auth: AuthClient {
    get { self[AuthClient.self] }
    set { self[AuthClient.self] = newValue }
  }
}
