//
//  TigonExecutorTests.swift
//  Tigon
//
//  Created by Steven Vlaminck on 4/4/16.
//  Copyright © 2016 SmartThings. All rights reserved.
//

import XCTest
import Tigon
import WebKit

class TigonExecutorTests: XCTestCase {
    
    var webView: WKWebView!
    
    override func setUp() {
        super.setUp()
        let contentController = WKUserContentController()
        contentController.addTigonMessageHandler(MockTigonMessageHandler())
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = contentController
        
        webView = WKWebView(frame: CGRectZero, configuration: configuration)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test m@objc ethod in the class.
        super.tearDown()
    }
    
    // MARK: stringifyResponse tests
    class MockTigonMessageHandler: NSObject, TigonMessageHandler {
        func handleMessage(id: String, payload: AnyObject) {}
        func messageError(error: TigonError, message: WKScriptMessage) {}
        func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {}
    }
    
    func testStringifyResponseDictionary() {
        let testObject = ["an": "array"]
        let expectedResult: String? = "{\n  \"an\" : \"array\"\n}"
        
        let result = webView.stringifyResponse(testObject)
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testStringifyResponseArray() {
        let testObject = ["an", "array"]
        let expectedResult: String? = "[\n  \"an\",\n  \"array\"\n]"
        
        let result = webView.stringifyResponse(testObject)
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testStringifyResponseString() {
        let testObject = "a string"
        let expectedResult: String? = "{\n  \"response\" : \"a string\"\n}"
        
        let result = webView.stringifyResponse(testObject)
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testStringifyResponseError() {
        let testObject = NSError(domain: "com.tigon", code: 0, userInfo: [NSLocalizedDescriptionKey: "test error"])
        let expectedResult: String? = "{\n  \"error\" : \"test error\"\n}"
        
        let result = webView.stringifyResponse(testObject)
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testStringifyResponseBool() {
        let expectedTrue: String? = "{\n  \"response\" : true\n}"
        let expectedFalse: String? = "{\n  \"response\" : false\n}"
        
        let trueResult = webView.stringifyResponse(true)
        let falseResult = webView.stringifyResponse(false)
        
        XCTAssertEqual(trueResult, expectedTrue)
        XCTAssertEqual(falseResult, expectedFalse)
    }
    
    func testStringifyResponseFailureReturnsEmptyObject() {
        let testObject = NSDate()
        let expectedResult: String? = "{}"
        
        let result = webView.stringifyResponse(testObject)
        
        XCTAssertEqual(result, expectedResult)
    }
}
