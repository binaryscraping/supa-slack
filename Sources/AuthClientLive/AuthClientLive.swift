//
//  AuthClientLive.swift
//  (c) 2023 Binary Scraping Co.
//  LICENSE: MIT
//

import AuthClient
import Dependencies
@preconcurrency import GoTrue
@preconcurrency import Supabase
import SupabaseDependency

extension AuthClient: DependencyKey {
  public static var liveValue: Self {
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
        _ = try await supabase.auth.session
        return .init()
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
        let session = try await supabase.auth.signIn(
          email: email.rawValue,
          password: password.rawValue
        )
        if session.user.confirmedAt == nil {
          return .requiresConfirmation
        }
        return .signedIn
      }
    )
  }
}
