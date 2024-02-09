//
//  New_GitHubApp.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-02-07.
//

import SwiftUI

@main
struct New_GitHubApp: App {
    @State private var apiService = ApiService()
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(apiService)
        }
    }
}
