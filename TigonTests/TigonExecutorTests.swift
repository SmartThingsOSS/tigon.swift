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
        
        webView = WKWebView(frame: CGRect.zero, configuration: configuration)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test m@objc ethod in the class.
        super.tearDown()
    }
    
    // MARK: stringifyResponse tests
    class MockTigonMessageHandler: NSObject, TigonMessageHandler {
        func handleMessage(_ id: String, payload: AnyObject) {}
        func messageError(_ error: Error, message: WKScriptMessage) {}
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {}
    }
    
    func testStringifyResponseDictionary() {
        let testObject = ["an": "array"]
        let expectedResult: String? = "{\n  \"an\" : \"array\"\n}"
        
        let result = webView.stringifyResponse(testObject as AnyObject)
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testStringifyResponseArray() {
        let testObject = ["an", "array"]
        let expectedResult: String? = "[\n  \"an\",\n  \"array\"\n]"
        
        let result = webView.stringifyResponse(testObject as AnyObject)
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testStringifyResponseString() {
        let testObject = "a string"
        let expectedResult: String? = "{\n  \"response\" : \"a string\"\n}"
        
        let result = webView.stringifyResponse(testObject as AnyObject)
        
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
        
        let trueResult = webView.stringifyResponse(true as AnyObject)
        let falseResult = webView.stringifyResponse(false as AnyObject)
        
        XCTAssertEqual(trueResult, expectedTrue)
        XCTAssertEqual(falseResult, expectedFalse)
    }
    
    func testStringifyResponseFailureReturnsEmptyObject() {
        let testObject = Date()
        let expectedResult: String? = "{}"
        
        let result = webView.stringifyResponse(testObject as AnyObject)
        
        XCTAssertEqual(result, expectedResult)
    }
}
