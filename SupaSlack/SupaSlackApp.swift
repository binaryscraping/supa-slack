//
//  SupaSlackApp.swift
//  SupaSlack
//
//  Created by Guilherme Souza on 23/12/22.
//

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
