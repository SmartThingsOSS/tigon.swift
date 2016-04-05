//
//  TigonMessageHandler.swift
//  Tigon
//
//  Created by Steven Vlaminck on 4/4/16.
//  Copyright © 2016 SmartThings. All rights reserved.
//

import Foundation
import WebKit

public protocol TigonMessageHandler: WKScriptMessageHandler {
    func handleMessage(id: String, payload: AnyObject)
    func messageError(error: TigonError, message: WKScriptMessage)
}

extension TigonMessageHandler {
    func messageError(error: TigonError, message: WKScriptMessage) {
        print("\(error): \(message.body)")
    }
}

extension WKUserContentController {
    func addTigonMessageHandler(messageHandler: TigonMessageHandler) {
        let scriptMessageHandler = TigonScriptMessageHandler(delegate: messageHandler)
        addScriptMessageHandler(scriptMessageHandler, name: "tigon")
    }
}
