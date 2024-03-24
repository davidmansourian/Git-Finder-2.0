//
//  AvatarLoaderTests.swift
//  New-GitHubTests
//
//  Created by David Mansourian on 2024-03-24.
//

import XCTest
@testable import New_GitHub

final class AvatarLoaderTests: XCTestCase {
    var sut: AvatarLoader!
    var apiService: MockApiService!
    var cacheManager: MockCacheManager!
    
    override func setUp() {
        cacheManager = MockCacheManager()
        apiService = MockApiService(cacheManager: cacheManager)
        sut = AvatarLoader(apiService: apiService)
    }
    
    func testLoadAvatarImages_repositoryObject_imageExistsForTestUser() async {
        let repository = Repository(name: "Test repo", owner: Repository.Owner(username: "Test", avatarUrl: "test"), description: "test description", starGazersCount: 10, watchersCount: 1, forksCount: 2, lastUpdated: "2023-09-05T22:41:23Z")
        let repositories: [Repository] = [repository]
        
        do {
            let images = try await sut.loadAvatarImages(for: repositories, requestedHeight: 32)
            XCTAssertFalse(images.isEmpty)
            XCTAssertEqual(images.first?.key, "Test")
        } catch {
            XCTFail("Unexpected result")
        }
    }
    
    func testLoadAvatarImages_userObject_imageExistsForTestUser() async {
        let user = User(id: 1, username: "Test", avatarUrl: "test", url: "test", reposUrl: "test", type: "test")
        let users: [User] = [user]
        
        do {
            let images = try await sut.loadAvatarImages(for: users, requestedHeight: 32)
            XCTAssertFalse(images.isEmpty)
            XCTAssertEqual(images.first?.key, "Test")
        } catch {
            XCTFail("Unexpected result")
        }
    }
    
    func testLoadAvatarImages_userObject_errorPreventedImageFetch() async {
        let user = User(id: 1, username: "Test", avatarUrl: "test", url: "test", reposUrl: "test", type: "test")
        let users: [User] = [user]
        apiService.mockError = .badURL
        
        do {
            let images = try await sut.loadAvatarImages(for: users, requestedHeight: 32)
            XCTAssertTrue(images.isEmpty)
        } catch {
            XCTFail("Unexpected result")
        }
    }
    
    func testLoadAvatarImages_addToCurrentDictionary_successfullyAdded() async {
        let repository = Repository(name: "Test repo", owner: Repository.Owner(username: "Test 2", avatarUrl: "test"), description: "test description", starGazersCount: 10, watchersCount: 1, forksCount: 2, lastUpdated: "2023-09-05T22:41:23Z")
        
        let repositories: [Repository] = [repository]
    
        do {
            guard let avatar = UIImage(named: "testAvatar") else { throw(AvatarLoader.LoadingError.invalidObjects) }
            let currentAvatars: [String:UIImage] = ["Test 1" : avatar]
            
            let images = try await sut.loadAvatarImages(
                for: repositories,
                requestedHeight: 32,
                currentAvatars: currentAvatars
            )
            
            XCTAssertEqual(images.count, 2)
        } catch {
            XCTFail("Unexpected result")
        }
    }
    
    func testLoadAvatarImages_emptyObjectType_invalidObjectErrorWasThrown() async {
        do {
            _ = try await sut.loadAvatarImages(for: nil, requestedHeight: 32)
        } catch {
            XCTAssertEqual(error.localizedDescription, AvatarLoader.LoadingError.invalidObjects.localizedDescription)
        }
    }
    
    func testLoadAvatarImages_unsupportedObjectType_returnIsEmpty() async {
        let invalidObject = UserSearchResult(resultsCount: 0, incompleteResults: true, users: [User(id: 0, username: "0", avatarUrl: "0", url: "0", reposUrl: "0", type: "0")])
        
        let invalidObjects = [invalidObject]
        
        do {
            let images = try await sut.loadAvatarImages(for: invalidObjects, requestedHeight: 32)
            XCTAssertTrue(images.isEmpty)
        } catch {
            XCTFail("Unexpected result")
        }
    }
}
