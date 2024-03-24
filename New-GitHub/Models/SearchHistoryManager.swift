//
//  SearchHistoryManager.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-03-24.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
public final class SearchHistoryManager {
    private var modelContext: ModelContext
    var searchHistory = [SearchHistory]()
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        Task { await fetchSearchHistory() }
    }
    
    @MainActor
    private func fetchSearchHistory() {
        do {
            let descriptor = FetchDescriptor<SearchHistory>(sortBy: [SortDescriptor(\.lastVisited, order: .reverse)])
            self.searchHistory = try modelContext.fetch(descriptor)
        } catch {
            print("Fetching from modelContext failed")
        }
    }
    
    @MainActor
    public func addSearchHistoryInstance(_ username: String, avatarData: Data?) {
        guard let avatarData = avatarData else { return }
        if existsInHistory(username: username) {
            //print("user: \(username) already exists in history only updating date for lastVisited")
            let historyInstance = searchHistory.first(where: {$0.username ==  username})
            historyInstance?.lastVisited = .now
        } else {
            //print("user: \(username) does not exist in history, adding instance")
            let newHistoryInstance = SearchHistory(username: username, lastVisited: .now, avatarData: avatarData)
            modelContext.insert(newHistoryInstance)
        }
        
        fetchSearchHistory()
    }
    
    private func existsInHistory(username: String) -> Bool {
        searchHistory.contains(where: { $0.username == username })
    }
    
    @MainActor
    public func remove(_ searchHistoryInstance: SearchHistory) {
        modelContext.delete(searchHistoryInstance)
        
        fetchSearchHistory()
    }
    
}
