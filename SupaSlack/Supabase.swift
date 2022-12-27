//
//  Supabase.swift
//  SupaSlack
//
//  Created by Guilherme Souza on 23/12/22.
//

import Foundation
import Supabase

extension SupabaseClient {
  static let instance = SupabaseClient(
    supabaseURL: URL(string: "https://fxotbpyitfbhzzfzgalj.supabase.co")!,
    supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ4b3RicHlpdGZiaHp6ZnpnYWxqIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NzE4MTY5MDAsImV4cCI6MTk4NzM5MjkwMH0.W9ws8MlcxKlVk6pyRAkny8Vf-TGmLGqQQzeNiwza-ik"
  )
}
