//
//  TigonScriptMessageHandler.swift
//  Tigon
//
//  Created by Steven Vlaminck on 3/31/16.
//  Copyright © 2016 SmartThings. All rights reserved.
//

import Foundation
import WebKit

/**
 `TigonScriptMessageHandler` parses `Tigon` messages from javascript and passes them to the `TigonMessageHandler` provided in `addTigonMessageHandler(_:)`.
 If the message is not a `Tigon` message, it passes through to the default `userContentController(_:didReceiveScriptMessage:)` method specified by `WKScriptMessageHandler`
 
 `WKUserContentController` retains its message handler.
 `TigonScriptMessageHandler` is a trampoline object between the `WKUserContentController` and the message handler.
 
 seealso:
  [stackoverflow - WKWebView causes my view controller to leak](http://stackoverflow.com/questions/26383031/wkwebview-causes-my-view-controller-to-leak)
*/
open class TigonScriptMessageHandler: NSObject, WKScriptMessageHandler {
    
    open weak var delegate: TigonMessageHandler?
    
    public init(delegate: TigonMessageHandler) {
        self.delegate = delegate
        super.init()
    }
    
    open func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        guard message.name == "tigon" else {
            // not a tigon message; allow WKScriptMessageHandler to do it's thing
            delegate?.userContentController(userContentController, didReceive: message)
            return
        }
        
        do {
            guard let body = message.body as? [String: AnyObject] else {
                throw TigonError.unexpectedMessageFormat
            }
            guard let id = body["id"] as? String else {
                throw TigonError.invalidId
            }
            guard let payload = body["payload"] else {
                throw TigonError.invalidPayload
            }
            
            delegate?.handleMessage(id, payload: payload)
            
        } catch let error as TigonError {
            delegate?.messageError(error, message: message)
        } catch {
            // do something here?
        }
    }
}
