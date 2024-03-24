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
    private let cacheManager: CacheManaging
    private let apiService: ApiServing
    private let avatarLoader: AvatarLoader
    
    private var container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: SearchHistory.self)
            self.cacheManager = CacheManager()
            self.apiService = ApiService(cacheManager: cacheManager)
            self.avatarLoader = AvatarLoader(apiService: apiService)
        } catch {
            fatalError("Failed to setup SwiftData container")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            SearchView(
                apiService: apiService,
                avatarLoader: avatarLoader,
                modelContext: container.mainContext
            )
        }
        .modelContainer(container)
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
