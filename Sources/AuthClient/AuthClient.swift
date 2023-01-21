//
//  AuthClient.swift
//  (c) 2022 Binary Scraping Co.
//  LICENSE: MIT
//

import Dependencies
import Foundation
import Tagged
import XCTestDynamicOverlay

public enum EmailAddressTag {}
public typealias EmailAddress = Tagged<EmailAddressTag, String>

public enum PasswordTag {}
public typealias Password = Tagged<PasswordTag, String>

public enum AuthEvent {
  case signedIn, signedOut
}

public enum AuthResult {
  case signedIn
  case requiresConfirmation
}

public struct Session {
  public init() {}
}

public struct AuthClient {
  public var initialize: @Sendable () async -> Void
  public var authEvent: @Sendable () -> AsyncStream<AuthEvent>
  public var session: @Sendable () async throws -> Session
  public var signUp: @Sendable (EmailAddress, Password) async throws -> AuthResult
  public var signIn: @Sendable (EmailAddress, Password) async throws -> AuthResult

  public init(
    initialize: @escaping @Sendable () async -> Void,
    authEvent: @escaping @Sendable () -> AsyncStream<AuthEvent>,
    session: @escaping @Sendable () async throws -> Session,
    signUp: @escaping @Sendable (EmailAddress, Password) async throws -> AuthResult,
    signIn: @escaping @Sendable (EmailAddress, Password) async throws -> AuthResult
  ) {
    self.initialize = initialize
    self.authEvent = authEvent
    self.session = session
    self.signUp = signUp
    self.signIn = signIn
  }
}

extension AuthClient: TestDependencyKey {
  public static let testValue = Self(
    initialize: XCTUnimplemented("AuthClient.initialize"),
    authEvent: XCTUnimplemented("AuthClient.authEvent"),
    session: XCTUnimplemented("AuthClient.session"),
    signUp: XCTUnimplemented("AuthClient.signUp"),
    signIn: XCTUnimplemented("AuthClient.signIn")
  )
}

extension DependencyValues {
  public var auth: AuthClient {
    get { self[AuthClient.self] }
    set { self[AuthClient.self] = newValue }
  }
}
