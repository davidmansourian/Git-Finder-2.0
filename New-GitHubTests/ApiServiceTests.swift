//
//  ApiServiceTests.swift
//  New-GitHubTests
//
//  Created by David Mansourian on 2024-02-09.
//

import XCTest
@testable import New_GitHub

final class ApiServiceTests: XCTestCase {
    var sut: MockApiService!
    var cacheManager: MockCacheManager!
    
    override func setUp() {
        cacheManager = MockCacheManager()
        sut = MockApiService(cacheManager: cacheManager)
    }
    
    func testFetch_fetchUserResults_resultsCountIsNine() async throws {
        sut.mockData = mockSearch_userResultsData
        
        do {
            let results = try await sut.fetchUserResult(for: "apple")
            XCTAssertEqual(results.resultsCount, 9)
        } catch {
            XCTFail("Incorrect resultCount")
        }
    }
    
    func testFetch_fetchUserResults_usersHasNineItems() async throws {
        sut.mockData = mockSearch_userResultsData
        
        do {
            let results = try await sut.fetchUserResult(for: "apple")
            XCTAssertEqual(results.users.count, 9)
        } catch {
            XCTFail("Incorrect users count")
        }
    }
    
    func testFetch_withInvalidData_customErrorThrown() async throws {
        sut.mockData = mockSearch_invalidData
        
        do {
            _ = try await sut.fetchUserResult(for: "apple")
        } catch {
            XCTAssertEqual("The data couldn’t be read because it is missing.", error.localizedDescription)
        }
    }
    
    func testFetch_testErrorThrown_badURLError() async throws {
        sut.mockError = .badURL
        
        do {
            _ = try await sut.fetchUserResult(for: "apple")
        } catch {
            XCTAssertEqual(error.localizedDescription, CustomApiError.badURL.localizedDescription)
        }
    }
    
    func testFetch_testErrorThrown_badServerResponse() async throws {
        sut.mockError = .badServerResponse
        
        do {
            _ = try await sut.fetchUserResult(for: "apple")
        } catch {
            print("error localizedDescription: \(error.localizedDescription)")
            print("customapierror, badserveresponse localizedDescription: \(CustomApiError.badServerResponse.localizedDescription)")
            XCTAssertEqual(error.localizedDescription, CustomApiError.badServerResponse.localizedDescription)
        }
    }
    
    func testFetch_testErrorThrown_invalidStatusCode() async throws {
        sut.mockError = .invalidStatusCode(404)
        
        do {
            _ = try await sut.fetchUserResult(for: "apple")
        } catch {
            XCTAssertEqual(error.localizedDescription, CustomApiError.invalidStatusCode(404).localizedDescription)
        }
    }
    
    func testFetch_testErrorThrown_parsingError() async throws {
        sut.mockError = .parsingError("Couldn't parse")
        
        do {
            _ = try await sut.fetchUserResult(for: "apple")
        } catch {
            XCTAssertEqual(error.localizedDescription, CustomApiError.parsingError("Couldn't parse").localizedDescription)
        }
    }
    
    func testFetch_testErrorThrown_unknownError() async throws {
        sut.mockError = .unknownError("Unknown")
        
        do {
            _ = try await sut.fetchUserResult(for: "apple")
        } catch {
            XCTAssertEqual(error.localizedDescription, CustomApiError.unknownError("Unknown").localizedDescription)
        }
    }
    
    func testFetch_testErrorThrown_invalidData() async throws {
        sut.mockError = .invalidData
        
        do {
            _ = try await sut.fetchUserResult(for: "apple")
        } catch {
            XCTAssertEqual(error.localizedDescription, CustomApiError.invalidData.localizedDescription)
        }
    }
    
    func testFetch_fetchDataType_notNil() async throws {
        do {
            let result = try await sut.fetchImageData(for: "someURL")
            XCTAssertNotNil(result)
        } catch {
            XCTFail("Unexpected result")
        }
    }
    
    func testFetch_fetchDataTypeFromCache_successFromCache() async throws {
        do {
            let _ = try await sut.fetchImageData(for: "someURL")
            XCTAssertFalse(sut.latestFetchWasFromCache)
            let _ = try await sut.fetchImageData(for: "someURL")
            XCTAssertTrue(sut.latestFetchWasFromCache)
        } catch {
            XCTFail("Unexpected result")
        }
    }
    
    func testFetch_fetchUserInfo_notNil() async throws {
        do {
            let result = try await sut.fetchUserInfo(for: "someURL")
            XCTAssertNotNil(result)
        } catch {
            XCTFail("Unexpected result")
        }
    }
    
    func testFetch_fetchUserInfo_usernameIsTest() async throws {
        do {
            let result = try await sut.fetchUserInfo(for: "someURL")
            XCTAssertEqual(result.username, "Test")
        } catch {
            XCTFail("Unexpected result")
        }
    }
    
    func testFetch_fetchRepositories_repoOwnerIsPelle() async throws {
        do {
            let result = try await sut.fetchRepositories(for: "someUser", pageNumber: 1)
            XCTAssertEqual(result.first?.owner.username, "Pelle")
        } catch {
            XCTFail("Unexpected result")
        }
    }
}
