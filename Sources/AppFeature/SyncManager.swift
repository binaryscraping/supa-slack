//
//  SyncManager.swift
//  (c) 2023 Binary Scraping Co.
//  LICENSE: MIT
//

import APIClient
import AsyncAlgorithms
import Dependencies
import Foundation
import Models
import OSLog

actor SyncManager {
  @Dependency(\.api) var api
  @Dependency(\.db) var db

  private var runningTask: Task<Void, Never>?

  private let logger = Logger()

  func start() {
    runningTask = Task {
      logger.info("Start synchronization manager")
      do {
        for try await messages in db.observeUnsyncedMessages().debounce(for: .seconds(5)) {
          if !messages.isEmpty {
            logger.debug("Syncing \(messages.count) messages.")
            await submitMessages(messages)
          }
        }
      } catch {
        logger.error("Error syncing messages: \(String(describing: error))")
        stop()
        start()
      }
    }
  }

  func stop() {
    logger.info("Stop synchronization manager")
    runningTask?.cancel()
  }

  private func submitMessages(_ messages: [Message]) async {
    let payload = messages.map {
      InsertMessagePayload(
        message: $0.message,
        channelID: $0.channelID.rawValue,
        authorID: $0.author.id.rawValue
      )
    }

    do {
      let responses = try await api.insertMessages(payload)
      logger.info("Synced \(responses.count) messages.")
      for (local, remote) in zip(messages, responses) {
        try db.updateMessage(local.id, .init(remote.id), .remote)
      }
    } catch {
      for message in messages {
        try? db.updateMessage(message.id, nil, .failure)
      }

      dump(error)
    }
  }
}
