//
//  TigonWebView.swift
//  Tigon
//
//  Created by Steven Vlaminck on 3/31/16.
//  Copyright © 2016 SmartThings. All rights reserved.
//

import Foundation
import WebKit

public protocol TigonMessageHandler {
    func handleMessage(id: String, payload: AnyObject)
}

public class TigonWebView: WKWebView {
    
    var messageHandler: TigonMessageHandler
    
    public init(messageHandler: TigonMessageHandler) {
        
        self.messageHandler = messageHandler
        
        let contentController = WKUserContentController()
        let scriptMessageHandler = TigonScriptMessageHandler()
        contentController.addScriptMessageHandler(scriptMessageHandler, name: "tigon")
        
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.userContentController = contentController
        
        super.init(frame: CGRectZero, configuration: configuration)
        scriptMessageHandler.delegate = self
    }
}

extension TigonWebView: WKScriptMessageHandler {
    public func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if let id = message.body["id"] as? String, optionalPayload = message.body["payload"], payload = optionalPayload {
            messageHandler.handleMessage(id, payload: payload)
        }
    }
}
