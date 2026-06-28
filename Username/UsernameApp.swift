//
//  UsernameApp.swift
//  Username
//
//  Created by u on 28/06/2026.
//

import SwiftUI

@main
struct UsernameApp: App {
    @State private var username = "femi"

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView(initialUsername: username) { newName in
                    username = newName
                }
            }
        }
    }
}
