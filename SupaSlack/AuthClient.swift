//
//  AuthClient.swift
//  SupaSlack
//
//  Created by Guilherme Souza on 23/12/22.
//

import ConcurrencyHelpers
import Dependencies
import Foundation
import GoTrue
import Supabase
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
  static let liveValue = Self(
    initialize: {
      await SupabaseClient.instance.auth.initialize()
    },
    authEvent: {
      let (stream, continuation) = AsyncStream<AuthEvent>.streamWithContinuation()

      Task.detached {
        for await event in SupabaseClient.instance.auth.authEventChange {
          switch event {
          case .signedIn:
            continuation.yield(.signedIn)
          default:
            continuation.yield(.signedOut)
          }
        }
      }

      return stream
    },
    session: { try await SupabaseClient.instance.auth.session },
    signUp: { email, password in
      let result = try await SupabaseClient.instance.auth.signUp(
        email: email.rawValue,
        password: password.rawValue
      )

      switch result {
      case let .session(session):
        return .signedIn
      case let .user(user):
        return .requiresConfirmation
      }
    },
    signIn: { email, password in
      try await SupabaseClient.instance.auth.signIn(
        email: email.rawValue,
        password: password.rawValue
      )
    }
  )

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
