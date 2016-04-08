//
//  TigonMessageHandler.swift
//  Tigon
//
//  Created by Steven Vlaminck on 4/4/16.
//  Copyright © 2016 SmartThings. All rights reserved.
//

import Foundation
import WebKit

/// `TigonMessageHandler` is how your app receives messages from `Tigon`.
public protocol TigonMessageHandler: WKScriptMessageHandler {
    /**
     A way to receive messages sent from javascript
     
     You are expected to call `sendErrorResponse(_:error:)` or `sendSuccessResponse(_:response:)` where appropriate.
     
     - parameters:
        - id: the id of the message. Use this when calling `sendErrorResponse(_:error:)` or `sendSuccessResponse(_:response:)`.
        - payload: The object that was sent from javascript
     
     - seealso:
      [tigon-js](https://github.com/SmartThingsOSS/tigon-js/)
    */
    func handleMessage(id: String, payload: AnyObject)

    /**
     A way to receive errors when a `Tigon` fails to handle a message.
     
     - parameters:
        - error: The error that occurred while trying to parse the message
        - message: The `WKScriptMessage` that couldn't be parsed.
     */
    func messageError(error: ErrorType, message: WKScriptMessage)
}

public extension TigonMessageHandler {
    /// The default implementation for `messageError(_:message:)`
    func messageError(error: TigonError, message: WKScriptMessage) {
        print("\(error): \(message.body)")
    }
}

public extension WKUserContentController {
    /**
     A way to set yourself as the `TigonMessageHandler` for your `WKWebView`.
     
     - paramters:
        - messageHandler: The message handler for the given `WKWebView` that uses Tigon.
     
     
         let contentController = WKUserContentController()
         contentController.addTigonMessageHandler(self)
     
         let configuration = WKWebViewConfiguration()
         configuration.userContentController = contentController
     
         let webView = WKWebView(frame: CGRectZero, configuration: configuration)

    */
    func addTigonMessageHandler(messageHandler: TigonMessageHandler) {
        let scriptMessageHandler = TigonScriptMessageHandler(delegate: messageHandler)
        addScriptMessageHandler(scriptMessageHandler, name: "tigon")
    }
    
    /**
     A way to remove yourself as the `TigonMessageHandler` for your `WKWebView`.
     Make sure you do this in the `deinit` of the viewController that holds your `WKWebView`.
     Failing to call this will cause a leak due to the retain logic between `WKWebView` and `WKUserContentController`
     
         deinit {
             webView?.configuration.userContentController.removeTigonMessageHandler()
         }
     */
    func removeTigonMessageHandler() {
        removeScriptMessageHandlerForName("tigon")
    }
}
