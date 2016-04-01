//
//  TigonScriptMessageHandler.swift
//  Tigon
//
//  Created by Steven Vlaminck on 3/31/16.
//  Copyright © 2016 SmartThings. All rights reserved.
//

import Foundation
import WebKit

/*!
 *  WKUserContentController retains its message handler
 *  TigonScriptMessageHandler is a trampoline object between the WKUserContentController and the message handler
 *  http://stackoverflow.com/questions/26383031/wkwebview-causes-my-view-controller-to-leak
 */


public class TigonScriptMessageHandler: NSObject, WKScriptMessageHandler {
    
    public weak var delegate: WKScriptMessageHandler?
    
    public func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceiveScriptMessage: message)
    }
}
