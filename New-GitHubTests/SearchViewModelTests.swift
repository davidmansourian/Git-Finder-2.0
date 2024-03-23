//
//  SearchViewModelTests.swift
//  New-GitHubTests
//
//  Created by David Mansourian on 2024-02-18.
//

import XCTest
@testable import New_GitHub

// Tests involving handleSearch have 0.5 seconds added to them due to a task.sleep for debouncing the search term.
final class SearchViewModelTests: XCTestCase {
    var sut: SearchView.ViewModel!
    var apiService: MockApiService!
    var cacheManager: MockCacheManager!
    var avatarLoader: AvatarLoader!
    
    override func setUp() {
        cacheManager = MockCacheManager()
        apiService = MockApiService(cacheManager: cacheManager)
        avatarLoader = AvatarLoader(apiService: apiService)
        sut = SearchView.ViewModel(apiService: apiService, avatarLoader: avatarLoader)
    }
    
    func testSearch_emptySearchTerm_viewStateIsIdle() async {
        await sut.handleSearch(for: "")
        
        XCTAssertTrue(sut.state == .idle)
    }
    
    func testSearch_withSearchTerm_usersHasMockData() async {
        await sut.handleSearch(for: "apple")
        
        switch sut.state {
        case .error(_):
            XCTFail("state should not be error")
        case .idle:
            XCTFail("state should not be idle")
        case .loading:
            XCTFail("state should not be loading")
        case .loaded(let users):
            XCTAssertEqual(users.first?.username, "apple")
        }
    }
    
    func testSearchTask_cancelTask_searchTaskIsNil() async {
        await sut.handleSearch(for: "test")
        
        guard let cancelValueBeforeCancel = sut.searchTask?.isCancelled else { return }
        
        XCTAssertFalse(cancelValueBeforeCancel)
        
        sut.cancelSearchTask()
        
        guard let cancelValueAfterCancel = sut.searchTask?.isCancelled else { return }
        
        XCTAssertTrue(cancelValueAfterCancel)
        
    }
    
    func testSearch_withSearchTerm_withError() async {
        apiService.mockError = .badServerResponse
        
        await sut.handleSearch(for: "apple")
        
        let correctError = CustomApiError.badServerResponse.localizedDescription
        XCTAssertEqual(sut.state, SearchView.ViewModel.State.error(correctError))
    }
    
    func testSearch_taskWasCancelled_errorIsSkipped() async {
        apiService.mockError = .unknownError("cancelled")
        
        await sut.handleSearch(for: "apple")
        
        XCTAssertEqual(sut.state, SearchView.ViewModel.State.loading)
    }
}
