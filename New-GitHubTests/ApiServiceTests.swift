//
//  ApiServiceTests.swift
//  New-GitHubTests
//
//  Created by David Mansourian on 2024-02-09.
//

import XCTest
@testable import New_GitHub

final class ApiServiceTests: XCTestCase {
    
    func testFetch_fetchUserResults_resultsCountIsNine() async throws {
        let sut = MockApiService()
        sut.mockData = mockSearch_userResultsData
        
        do {
            let results = try await sut.fetchUsernames(for: "apple")
            XCTAssertEqual(results.resultsCount, 9)
        } catch {
            XCTFail("Incorrect resultCount")
        }
    }
    
    func testFetch_fetchUserResults_usersHasNineItems() async throws {
        let sut = MockApiService()
        sut.mockData = mockSearch_userResultsData
        
        do {
            let results = try await sut.fetchUsernames(for: "apple")
            XCTAssertEqual(results.users.count, 9)
        } catch {
            XCTFail("Incorrect users count")
        }
    }
    
    func testFetch_withInvalidData_customErrorThrown() async throws {
        let sut = MockApiService()
        sut.mockData = mockSearch_invalidData
        
        do {
            let results = try await sut.fetchUsernames(for: "apple")
        } catch {
            XCTAssertEqual("The data couldn’t be read because it is missing.", error.localizedDescription)
        }
    }
    
    func testFetch_testErrorThrown_badURLError() async throws {
        let sut = MockApiService()
        sut.mockError = .badURL
        
        do {
            let results = try await sut.fetchUsernames(for: "apple")
        } catch {
            if let error = error as? CustomApiError {
                XCTAssertEqual(error.customDescription, CustomApiError.badURL.customDescription)
            }
        }
    }
    
    func testFetch_testErrorThrown_badServerResponse() async throws {
        let sut = MockApiService()
        sut.mockError = .badServerResponse
        
        do {
            let results = try await sut.fetchUsernames(for: "apple")
        } catch {
            if let error = error as? CustomApiError {
                XCTAssertEqual(error.customDescription, CustomApiError.badServerResponse.customDescription)
            }
        }
    }
    
    func testFetch_testErrorThrown_invalidStatusCode() async throws {
        let sut = MockApiService()
        sut.mockError = .invalidStatusCode(404)
        
        do {
            let results = try await sut.fetchUsernames(for: "apple")
        } catch {
            if let error = error as? CustomApiError {
                XCTAssertEqual(error.customDescription, CustomApiError.invalidStatusCode(404).customDescription)
            }
        }
    }
    
    func testFetch_testErrorThrown_parsingError() async throws {
        let sut = MockApiService()
        sut.mockError = .parsingError("Couldn't parse")
        
        do {
            let results = try await sut.fetchUsernames(for: "apple")
        } catch {
            if let error = error as? CustomApiError {
                XCTAssertEqual(error.customDescription, CustomApiError.parsingError("Couldn't parse").customDescription)
            }
        }
    }
    
    func testFetch_testErrorThrown_unknownError() async throws {
        let sut = MockApiService()
        sut.mockError = .unknownError("Unknown")
        
        do {
            let results = try await sut.fetchUsernames(for: "apple")
        } catch {
            if let error = error as? CustomApiError {
                XCTAssertEqual(error.customDescription, CustomApiError.unknownError("Unknown").customDescription)
            }
        }
    }
    
    
}
