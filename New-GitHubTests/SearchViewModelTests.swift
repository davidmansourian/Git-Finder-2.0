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
    var apiService: ApiServing!
    
    override func setUp() {
        apiService = MockApiService()
        sut = SearchView.ViewModel(apiService: apiService)
    }
    
    func testSearch_emptySearchTerm_viewStateIsIdle() async {
        await sut.handleSearch(for: "")
        
        XCTAssertTrue(sut.viewState == .idle)
    }
    
    func testSearch_withSearchTerm_usersHasMockData() async {
        await sut.handleSearch(for: "apple")
        
        switch sut.viewState {
        case .error(_):
            XCTFail("viewState should not be error")
        case .idle:
            XCTFail("viewState should not be idle")
        case .loading:
            XCTFail("viewState should not be loading")
        case .loaded(let users):
            XCTAssertEqual(users.first?.username, "apple")
        }
    }
    
    func testSearch_withSearchTerm_avatarDataIsNotNil() async {
        await sut.handleSearch(for: "apple")
        
        switch sut.viewState {
        case .error(_):
            XCTFail("viewState should not be error")
        case .idle:
            XCTFail("viewState should not be idle")
        case .loading:
            XCTFail("viewState should not be loading")
        case .loaded(let users):
            XCTAssertNotNil(users.first?.avatarImageData)
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
        let apiService = MockApiService()
        apiService.mockError = .badServerResponse
        let sut = SearchView.ViewModel(apiService: apiService)
        
        await sut.handleSearch(for: "apple")
        
        XCTAssertEqual(sut.viewState, SearchView.ViewModel.ViewState.error("Search failed"))
    }
}
