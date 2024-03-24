//
//  ProfileViewModelTests.swift
//  New-GitHubTests
//
//  Created by David Mansourian on 2024-03-24.
//

import XCTest
@testable import New_GitHub

// Flaky and slow tests due to concurrency, hence sleeping
final class ProfileViewModelTests: XCTestCase {
    var sut: ProfileView.ViewModel!
    var apiService: MockApiService!
    var cacheManager: MockCacheManager!
    var avatarLoader: AvatarLoader!
    
    override func setUp() {
        cacheManager = MockCacheManager()
        apiService = MockApiService(cacheManager: cacheManager)
        avatarLoader = AvatarLoader(apiService: apiService)
        sut = ProfileView.ViewModel(apiService: apiService, avatarLoader: avatarLoader, username: "Pelle")
    }
    
    func testInit_loadingReposForTestUser_reposWereLoaded() async {
        try? await Task.sleep(for: .seconds(0.1))
        
        switch sut.state {
        case .error(_):
            XCTFail("Should not be error")
        case .loading:
            XCTFail("Should not be loading")
        case .loaded(let repos):
            XCTAssertEqual(repos.count, 30)
        }
    }
    
    func testScrollRepos_validCall_reposDidScroll() async {
        try? await Task.sleep(for: .seconds(0.1))
        
        XCTAssertEqual(sut.repoCount, 30)
        
        sut.scrollRepositories(consider: .all, and: .originalOrder)
        
        try? await Task.sleep(for: .seconds(0.3))
        
        XCTAssertEqual(sut.repoCount, 60)
        
    }
    
    func testsetUserResultsWithFilterAndSort_filterOwnedSortWatchersAsc_success() async {
        try? await Task.sleep(for: .seconds(0.1))
        XCTAssertEqual(sut.repoCount, 30)
        
        await sut.setUserResultsWithFilterAndSort(.owner, .watchersAscending)
        
        switch sut.state {
        case .error(_):
            XCTFail("Should not be error")
        case .loading:
            XCTFail("Should not be loading")
        case .loaded(let repos):
            XCTAssertEqual(repos.last?.watchersCount, 150)
        }
    }
    
    func testsetUserResultsWithFilterAndSort_filterOwnedSortWatchersDesc_success() async {
        try? await Task.sleep(for: .seconds(0.1))
        XCTAssertEqual(sut.repoCount, 30)
        
        await sut.setUserResultsWithFilterAndSort(.owner, .watchersDescending)
        
        switch sut.state {
        case .error(_):
            XCTFail("Should not be error")
        case .loading:
            XCTFail("Should not be loading")
        case .loaded(let repos):
            XCTAssertEqual(repos.first?.watchersCount, 150)
        }
    }
    
    func testSetUserResultWithFilterAndSort_filterContributor_emptyResult() async {
        try? await Task.sleep(for: .seconds(0.1))
        XCTAssertEqual(sut.repoCount, 30)
        
        await sut.setUserResultsWithFilterAndSort(.contributor, .watchersDescending)
        
        switch sut.state {
        case .error(_):
            XCTFail("Should not be error")
        case .loading:
            XCTFail("Should not be loading")
        case .loaded(let repos):
            XCTAssertEqual(repos.count, 0)
        }
    }
    
    func testsetUserResultsWithFilterAndSort_sortLatest_success() async {
        try? await Task.sleep(for: .seconds(0.1))
        XCTAssertEqual(sut.repoCount, 30)
        
        await sut.setUserResultsWithFilterAndSort(.owner, .latest)
        
        switch sut.state {
        case .error(_):
            XCTFail("Should not be error")
        case .loading:
            XCTFail("Should not be loading")
        case .loaded(let repos):
            XCTAssertEqual(repos.first?.name, "Latest project")
        }
    }
    
    func testsetUserResultsWithFilterAndSort_sortOldest_success() async {
        try? await Task.sleep(for: .seconds(0.1))
        XCTAssertEqual(sut.repoCount, 30)
        
        await sut.setUserResultsWithFilterAndSort(.owner, .oldest)
        
        switch sut.state {
        case .error(_):
            XCTFail("Should not be error")
        case .loading:
            XCTFail("Should not be loading")
        case .loaded(let repos):
            XCTAssertEqual(repos.first?.name, "Oldest project")
        }
    }
}
