//
//  SearchHistoryManagerTests.swift
//  New-GitHubTests
//
//  Created by David Mansourian on 2024-03-24.
//

import SwiftData
import XCTest
@testable import New_GitHub

final class SearchHistoryManagerTests: XCTestCase {
    var sut: SearchHistoryManager!

    @MainActor
    override func setUp() {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: SearchHistory.self, configurations: config)
            
            sut = SearchHistoryManager(modelContext: container.mainContext)
        } catch {
            XCTFail("Couldn't setup modelcontainer")
        }
    }
    
    func testSearchHistory_checkInit_searchHistoryIsEmpty() {
        XCTAssertEqual(sut.searchHistory.count, 0)
    }
    
    @MainActor
    func testAddSearchHistoryInstance_userDoesNotExist_added() {
        let username = "Test"
        let avatarData = Data()
        
        sut.addSearchHistoryInstance(username, avatarData: avatarData)
        
        XCTAssertEqual(sut.searchHistory.count, 1)
    }
    
    @MainActor
    func testAddSearchHistory_multipleUsersDoNotExist_added() {
        let username1 = "Test 1"
        let username2 = "Test 2"
        let avatarData = Data()
        
        sut.addSearchHistoryInstance(username1, avatarData: avatarData)
        sut.addSearchHistoryInstance(username2, avatarData: avatarData)
        
        XCTAssertEqual(sut.searchHistory.count, 2)
    }
    
    @MainActor
    func testAddSearchHistory_usernameAlreadyExists_notAddedAgain() {
        let username1 = "Test 1"
        let username2 = "Test 1"
        let avatarData = Data()
        
        sut.addSearchHistoryInstance(username1, avatarData: avatarData)
        sut.addSearchHistoryInstance(username2, avatarData: avatarData)
        
        XCTAssertEqual(sut.searchHistory.count, 1)
    }
    
    @MainActor
    func testRemove_addAndRemoveInstance_success() {
        let username = "Test"
        let avatarData = Data()
        
        sut.addSearchHistoryInstance(username, avatarData: avatarData)
        
        XCTAssertEqual(sut.searchHistory.count, 1)
        
        guard let instance = sut.searchHistory.first 
        else {
            XCTFail("Unexpected result")
            return
        }
        
        sut.remove(instance)
        
        XCTAssertEqual(sut.searchHistory.count, 0)
        
    }

}
