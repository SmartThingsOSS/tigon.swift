//
//  TigonScriptMessageHandlerTests.swift
//  Tigon
//
//  Created by Steven Vlaminck on 4/4/16.
//  Copyright © 2016 SmartThings. All rights reserved.
//

import XCTest
import WebKit

class TigonScriptMessageHandlerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    class MockTigonMessageHandler: NSObject, TigonMessageHandler {
        
        var messageId: String? = nil
        var messagePayload: AnyObject? = nil
        
        var messageError: TigonError? = nil
        var messageErrorMessage: WKScriptMessage? = nil
        
        var didReceiveScriptMessage: WKScriptMessage? = nil
        
        func handleMessage(id: String, payload: AnyObject) {
            messageId = id
            messagePayload = payload
        }
        func messageError(error: TigonError, message: WKScriptMessage) {
            messageError = error
            messageErrorMessage = message
        }
        func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
            didReceiveScriptMessage = message
        }
    }
    
    class MockScriptMessage: WKScriptMessage {
        
        let mockBody: AnyObject
        let mockName: String
        
        init(name: String, body: AnyObject) {
            mockName = name
            mockBody = body
        }
        
        override var body: AnyObject {
            return mockBody
        }
        
        override var name: String {
            return mockName
        }
    }
    
    func testDidReceiveScriptMessage_nonTigonMessages_areSentThroughDidReceiveScriptMessage() {
        let messageHandler = MockTigonMessageHandler()
        let scriptMessageHandler = TigonScriptMessageHandler(delegate: messageHandler)
        let mockMessage = MockScriptMessage(name: "test", body: "some non-tigon message")
        
        // pass a mock object to the scriptMessageHandler and verify that it passed it along to our other mocked object
        scriptMessageHandler.userContentController(WKUserContentController(), didReceiveScriptMessage: mockMessage)
        
        XCTAssertNotNil(messageHandler.didReceiveScriptMessage)
        XCTAssertEqual(messageHandler.didReceiveScriptMessage?.name, "test")
        XCTAssertEqual(messageHandler.didReceiveScriptMessage?.body as? String, "some non-tigon message")
    }
    
    func testDidReceiveScriptMessage_messagesWithUnexpectedMessageBody_areSentThroughMessageError() {
        let messageHandler = MockTigonMessageHandler()
        let scriptMessageHandler = TigonScriptMessageHandler(delegate: messageHandler)
        let mockMessage = MockScriptMessage(name: "tigon", body: "some non-tigon message")
        
        // pass a mock object to the scriptMessageHandler and verify that it passed it along to our other mocked object
        scriptMessageHandler.userContentController(WKUserContentController(), didReceiveScriptMessage: mockMessage)
        
        XCTAssertNotNil(messageHandler.messageError)
        XCTAssertEqual(messageHandler.messageError, TigonError.UnexpectedMessageFormat)
        XCTAssertNotNil(messageHandler.messageErrorMessage)
        XCTAssertEqual(messageHandler.messageErrorMessage, mockMessage)
    }
    
    func testDidReceiveScriptMessage_messagesWithInvalidId_areSentThroughMessageError() {
        let messageHandler = MockTigonMessageHandler()
        let scriptMessageHandler = TigonScriptMessageHandler(delegate: messageHandler)
        let mockMessage = MockScriptMessage(name: "tigon", body: ["id": 5, "payload": "some message"])
        
        // pass a mock object to the scriptMessageHandler and verify that it passed it along to our other mocked object
        scriptMessageHandler.userContentController(WKUserContentController(), didReceiveScriptMessage: mockMessage)
        
        XCTAssertNotNil(messageHandler.messageError)
        XCTAssertEqual(messageHandler.messageError, TigonError.InvalidId)
        XCTAssertNotNil(messageHandler.messageErrorMessage)
        XCTAssertEqual(messageHandler.messageErrorMessage, mockMessage)
    }
    
    func testDidReceiveScriptMessage_messagesWithInvalidPayload_areSentThroughMessageError() {
        let messageHandler = MockTigonMessageHandler()
        let scriptMessageHandler = TigonScriptMessageHandler(delegate: messageHandler)
        let mockMessage = MockScriptMessage(name: "tigon", body: ["id": "test"])
        
        // pass a mock object to the scriptMessageHandler and verify that it passed it along to our other mocked object
        scriptMessageHandler.userContentController(WKUserContentController(), didReceiveScriptMessage: mockMessage)
        
        XCTAssertNotNil(messageHandler.messageError)
        XCTAssertEqual(messageHandler.messageError, TigonError.InvalidPayload)
        XCTAssertNotNil(messageHandler.messageErrorMessage)
        XCTAssertEqual(messageHandler.messageErrorMessage, mockMessage)
    }
    
    func testDidReceiveScriptMessage_validTigonMessages_areSentThroughHandleMessage() {
        let messageHandler = MockTigonMessageHandler()
        let scriptMessageHandler = TigonScriptMessageHandler(delegate: messageHandler)
        let mockMessage = MockScriptMessage(name: "tigon", body: ["id": "test", "payload": "some message"])
        
        // pass a mock object to the scriptMessageHandler and verify that it passed it along to our other mocked object
        scriptMessageHandler.userContentController(WKUserContentController(), didReceiveScriptMessage: mockMessage)
        
        XCTAssertNotNil(messageHandler.messageId)
        XCTAssertEqual(messageHandler.messageId, "test")
        XCTAssertNotNil(messageHandler.messagePayload)
        XCTAssertEqual(messageHandler.messagePayload as? String, "some message")
    }
    
}
