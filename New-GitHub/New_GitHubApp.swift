//
//  New_GitHubApp.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-02-07.
//

import SwiftData
import SwiftUI

@main
struct New_GitHubApp: App {
    let cacheManager = CacheManager()
    @State private var apiService: ApiServing
    
    init() {
        self._apiService = State(wrappedValue: ApiService(cacheManager: cacheManager))
    }
    
    var body: some Scene {
        WindowGroup {
            SearchView(apiService: apiService)
        }
    }
}

//struct ApiServiceKey: EnvironmentKey {
//    static let defaultValue: any ApiServing = MockApiService()
//}
//
//extension EnvironmentValues {
//    var apiService: any ApiServing {
//        get { self[ApiServiceKey.self] }
//        set { self[ApiServiceKey.self] = newValue }
//    }
//}
