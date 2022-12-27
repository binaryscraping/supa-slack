//
//  ToastState.swift
//  SupaSlack
//
//  Created by Guilherme Souza on 24/12/22.
//

import Foundation
import ToastUI

extension ToastState {
  init(_ error: Error) {
    self.init(style: .failure, icon: nil, title: error.localizedDescription, subtitle: nil)
  }
}
