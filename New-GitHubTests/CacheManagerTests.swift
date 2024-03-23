//
//  CacheManagerTests.swift
//  New-GitHubTests
//
//  Created by David Mansourian on 2024-03-23.
//

import XCTest
@testable import New_GitHub

final class CacheManagerTests: XCTestCase {
    var sut: MockCacheManager!
    
    override func setUp() {
        sut = MockCacheManager()
    }
    
    func testSetGet_setDataFromImage_setSuccess() {
        guard let image = UIImage(named: "testAvatar"),
              let imageData = image.pngData()
        else {
            XCTFail("Couldn't find image asset")
            return
        }
        
        sut.set(toCache: imageData, forKey: "testAvatar")
        
        let imageDataFromCache = sut.get(as: Data.self, forKey: "testAvatar")
        
        XCTAssertEqual(imageData, imageDataFromCache)
        
    }
    
    func testSetGet_setDataFromImage_getFailed() {
        guard let image = UIImage(named: "testAvatar"),
              let pngData = image.pngData(),
              let jpegData = image.jpegData(compressionQuality: 0.1)
        else {
            XCTFail("Couldn't find image asset")
            return
        }
        
        sut.set(toCache: pngData, forKey: "testAvatar")
        
        let pngDataFromCache = sut.get(as: Data.self, forKey: "testAvatar")
        
        XCTAssertNotEqual(jpegData, pngDataFromCache)
    }
    
    func testSetGet_setDataFromUser_getSuccess() {
        let user = User(id: 1, username: "Test", avatarUrl: "test", url: "test", reposUrl: "test", type: "test")
        
        sut.set(toCache: user, forKey: "testUser")
        
        let userFromCache = sut.get(as: User.self, forKey: "testUser")
        
        XCTAssertEqual(user, userFromCache)
    }
    
    func testSetGet_setDataFromUser_getFailed() {
        let user1 = User(id: 1, username: "Test 1", avatarUrl: "test", url: "test", reposUrl: "test", type: "test")
        let user2 = User(id: 2, username: "Test 2", avatarUrl: "test", url: "test", reposUrl: "test", type: "test")
        
        sut.set(toCache: user1, forKey: "testUser1")
        
        let user1FromCache = sut.get(as: User.self, forKey: "testUser1")
        
        XCTAssertNotEqual(user2, user1FromCache)
    }
    
    func testSetGet_setDataFromRepoArray_getSuccess() {
        let repository1 = Repository(name: "Test Repo 1", owner: RepositoryOwner(username: "test", avatarUrl: "test"), description: "test description", starGazersCount: 1, watchersCount: 1, forksCount: 1)
        let repository2 = Repository(name: "Test Repo 2", owner: RepositoryOwner(username: "test", avatarUrl: "test"), description: "test description", starGazersCount: 2, watchersCount: 1, forksCount: 1)
        
        let repositories: [Repository] = [repository1, repository2]
        
        sut.set(toCache: repositories, forKey: "testRepositories")
        
        let repositoriesFromCache = sut.get(as: [Repository].self, forKey: "testRepositories")
        
        XCTAssertEqual(repositories, repositoriesFromCache)
    }
    
    func testGet_getNonExistentData_getFailed() {
        let nonExistentCache = sut.get(as: Data.self, forKey: "nonExistent")
        
        XCTAssertNil(nonExistentCache)
    }
    
    func testSetGet_testSanitizingKey_keyIsSanitzed() {
        let unsanitizedKey = "https://tjena"
        let sanitizedKey = "tjena"
        
        sut.set(toCache: Data(), forKey: unsanitizedKey)
        
        let dataFromCacheWithSanitizedKey = sut.get(as: Data.self, forKey: sanitizedKey)
        
        XCTAssertNotNil(dataFromCacheWithSanitizedKey)
    }
    
    

}
