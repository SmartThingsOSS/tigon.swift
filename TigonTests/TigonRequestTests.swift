//
//  TigonRequestTests.swift
//  Tigon
//
//  Created by Steven Vlaminck on 4/1/16.
//  Copyright © 2016 SmartThings. All rights reserved.
//

import XCTest
import Tigon

class TigonRequestTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitWithoutIdThrows() {
        let requestBody: [NSObject: AnyObject] = [:]
        
        do {
            var request: TigonRequest?
            defer {
                XCTAssertNil(request)
            }
            request = try TigonRequest(requestBody)
            XCTFail("Expected to throw .InvalidId")
        } catch {
            guard case TigonException.InvalidId = error else {
                XCTFail("Expected to throw .InvalidId")
                return
            }
            XCTAssertNotNil(error)
        }
    }
    
    func testInitWithNonStringIdThrows() {
        let requestBody: [NSObject: AnyObject] = [
            "id": ["not", "a", "string"]
        ]
        
        do {
            var request: TigonRequest?
            defer {
                XCTAssertNil(request)
            }
            request = try TigonRequest(requestBody)
            XCTFail("Expected to throw .InvalidId")
        } catch {
            guard case TigonException.InvalidId = error else {
                XCTFail("Expected to throw .InvalidId")
                return
            }
            XCTAssertNotNil(error)
        }
    }
    
    func testInitWithoutPathThrows() {
        let requestBody: [NSObject: AnyObject] = [
            "id": "test"
        ]
        
        do {
            var request: TigonRequest?
            defer {
                XCTAssertNil(request)
            }
            request = try TigonRequest(requestBody)
            XCTFail("Expected to throw .InvalidPath")
        } catch {
            guard case TigonException.InvalidPath = error else {
                XCTFail("Expected to throw .InvalidPath")
                return
            }
            XCTAssertNotNil(error)
        }
    }
    
    func testInitWithNonStringPathThrows() {
        let requestBody: [NSObject: AnyObject] = [
            "id": "test",
            "path": ["not", "a", "string"]
        ]
        
        do {
            var request: TigonRequest?
            defer {
                XCTAssertNil(request)
            }
            request = try TigonRequest(requestBody)
            XCTFail("Expected to throw .InvalidPath")
        } catch {
            guard case TigonException.InvalidPath = error else {
                XCTFail("Expected to throw .InvalidPath")
                return
            }
            XCTAssertNotNil(error)
        }
    }
    
    func testInitWithoutMethodThrows() {
        let requestBody: [NSObject: AnyObject] = [
            "id": "test",
            "path": "testPath"
        ]
        
        do {
            var request: TigonRequest?
            defer {
                XCTAssertNil(request)
            }
            request = try TigonRequest(requestBody)
            XCTFail("Expected to throw .InvalidMethod")
        } catch {
            guard case TigonException.InvalidMethod = error else {
                XCTFail("Expected to throw .InvalidMethod")
                return
            }
            XCTAssertNotNil(error)
        }
    }
    
    func testInitWithNonStringMethodThrows() {
        let requestBody: [NSObject: AnyObject] = [
            "id": "test",
            "path": "testPath",
            "method": ["not", "a", "string"]
        ]
        
        do {
            var request: TigonRequest?
            defer {
                XCTAssertNil(request)
            }
            request = try TigonRequest(requestBody)
            XCTFail("Expected to throw .InvalidMethod")
        } catch {
            guard case TigonException.InvalidMethod = error else {
                XCTFail("Expected to throw .InvalidMethod")
                return
            }
            XCTAssertNotNil(error)
        }
    }
    
    func testInitWithValidMethods() {
        
        // YES, I know this test is laid out terribly.
        // I did it this way so the compiler will catch it 
        // if TigonRequestMethod is ever updated.
        
        func testMethod(method: TigonRequestMethod) {
            let requestBody: [NSObject: AnyObject] = [
                "id": "test",
                "path": "testPath",
                "method": method.rawValue
            ]
            
            let request = try? TigonRequest(requestBody)
            XCTAssertNotNil(request?.method == method)
            
        }
        
        var validMethods: [TigonRequestMethod: Bool] = [
            .GET: false,
            .PUT: false,
            .POST: false,
            .DELETE: false,
            .HEAD: false,
            .OPTIONS: false
        ]

        validMethods.forEach {
            let method = $0.0
            switch method {
            case .GET:
                testMethod(method)
                validMethods[method] = true
            case .PUT:
                testMethod(method)
                validMethods[method] = true
            case .POST:
                testMethod(method)
                validMethods[method] = true
            case .DELETE:
                testMethod(method)
                validMethods[method] = true
            case .HEAD:
                testMethod(method)
                validMethods[method] = true
            case .OPTIONS:
                testMethod(method)
                validMethods[method] = true
            }
        }
        
        validMethods.forEach {
            XCTAssertTrue($0.1)
        }
    }
    
    

    
}
