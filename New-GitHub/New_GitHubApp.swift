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
    @State private var avatarLoader: AvatarLoader
    
    private let cacheManager: CacheManaging = CacheManager()
    private var apiService: ApiServing
    
    init() {
        self.apiService = ApiService(cacheManager: cacheManager)
        self._avatarLoader = State(wrappedValue: AvatarLoader(apiService: apiService))
    }
    
    var body: some Scene {
        WindowGroup {
            SearchView(apiService: apiService, avatarLoader: avatarLoader)
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
