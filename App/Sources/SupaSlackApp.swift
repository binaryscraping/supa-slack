//
//  SupaSlackApp.swift
//  (c) 2022 Binary Scraping Co.
//  LICENSE: MIT
//

import APIClientLive
import AppFeature
import AuthClientLive
import DatabaseClientLive
import SwiftUI

@main
struct SupaSlackApp: App {
  @StateObject var viewModel = AppViewModel()

  var body: some Scene {
    WindowGroup {
      AppView(viewModel: viewModel)
    }
  }
}
