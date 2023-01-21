//
//  ToastState.swift
//  (c) 2022 Binary Scraping Co.
//  LICENSE: MIT
//

import Foundation
import ToastUI

extension ToastState {
  public init(_ error: Error) {
    self.init(style: .failure, icon: nil, title: error.localizedDescription, subtitle: nil)
  }
}
