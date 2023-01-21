//
//  DatabaseClientLiveTests.swift
//  (c) 2023 Binary Scraping Co.
//  LICENSE: MIT
//

import DatabaseClient
@testable import DatabaseClientLive
import Models
import XCTest

final class DatabaseClientLiveTests: XCTestCase {
  let sut = DatabaseClient.memory
  let now = Date()

  func testIntegration() async throws {
    var channelsIterator = sut.observeChannels().makeAsyncIterator()

    let user = User(id: .init(), username: "guilherme")
    try sut.saveUsers([user])

    let `public` = SaveChannelPayload(
      id: 1,
      insertedAt: now,
      slug: "Public",
      createdBy: user.id.rawValue
    )
    let random = SaveChannelPayload(
      id: 2,
      insertedAt: now,
      slug: "Random",
      createdBy: user.id.rawValue
    )
    let swiftUI = SaveChannelPayload(
      id: 3,
      insertedAt: now,
      slug: "SwiftUI",
      createdBy: user.id.rawValue
    )

    var channels = try await channelsIterator.next()
    XCTAssertEqual(channels, [])

    try sut.saveChannels([`public`, random, swiftUI])
    channels = try await channelsIterator.next()
    XCTAssertEqual(channels?.map(\.slug), ["Public", "Random", "SwiftUI"])
    XCTAssertNil(channels?[0].lastMessageAt)

    let message = Message(
      id: .init(),
      remoteID: nil,
      insertedAt: now,
      message: "hello world",
      channelID: .init(`public`.id),
      authorID: user.id,
      status: .local
    )
    try sut.insertMessage(message)
    channels = try await channelsIterator.next()
    XCTAssertEqual(channels?[0].lastMessageAt?.formatted(), message.insertedAt.formatted())
    XCTAssertEqual(channels?[0].unreadMessagesCount, 1)

    try sut.saveChannels([`public`, random])
    channels = try await channelsIterator.next()
    XCTAssertEqual(channels?.map(\.slug), ["Public", "Random"])
  }
}
