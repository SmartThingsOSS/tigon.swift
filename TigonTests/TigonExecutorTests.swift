//
//  TigonExecutorTests.swift
//  Tigon
//
//  Created by Steven Vlaminck on 4/4/16.
//  Copyright © 2016 SmartThings. All rights reserved.
//

import XCTest
import Tigon

class TigonExecutorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: stringifyResponse tests
    class MockTigonMessageHandler: TigonMessageHandler {
        func handleMessage(id: String, payload: AnyObject) {}
    }
    
    func testStringifyResponseDictionary() {
        let webView = TigonWebView(messageHandler: MockTigonMessageHandler())
        let testObject = ["an": "array"]
        let expectedResult: String? = "{\n  \"an\" : \"array\"\n}"
        
        let result = webView.stringifyResponse(testObject)
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testStringifyResponseArray() {
        let webView = TigonWebView(messageHandler: MockTigonMessageHandler())
        let testObject = ["an", "array"]
        let expectedResult: String? = "[\n  \"an\",\n  \"array\"\n]"
        
        let result = webView.stringifyResponse(testObject)
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testStringifyResponseString() {
        let webView = TigonWebView(messageHandler: MockTigonMessageHandler())
        let testObject = "a string"
        let expectedResult: String? = "{\n  \"response\" : \"a string\"\n}"
        
        let result = webView.stringifyResponse(testObject)
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testStringifyResponseError() {
        let webView = TigonWebView(messageHandler: MockTigonMessageHandler())
        let testObject = NSError(domain: "com.tigon", code: 0, userInfo: [NSLocalizedDescriptionKey: "test error"])
        let expectedResult: String? = "{\n  \"error\" : \"test error\"\n}"
        
        let result = webView.stringifyResponse(testObject)
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testStringifyResponseBool() {
        let webView = TigonWebView(messageHandler: MockTigonMessageHandler())
        let expectedTrue: String? = "{\n  \"response\" : true\n}"
        let expectedFalse: String? = "{\n  \"response\" : false\n}"
        
        let trueResult = webView.stringifyResponse(true)
        let falseResult = webView.stringifyResponse(false)
        
        XCTAssertEqual(trueResult, expectedTrue)
        XCTAssertEqual(falseResult, expectedFalse)
    }
    
    func testStringifyResponseFailureReturnsEmptyObject() {
        let webView = TigonWebView(messageHandler: MockTigonMessageHandler())
        let testObject = NSDate()
        let expectedResult: String? = "{}"
        
        let result = webView.stringifyResponse(testObject)
        
        XCTAssertEqual(result, expectedResult)
    }
}
