//
//  TigonExecutor.swift
//  Tigon
//
//  Created by Steven Vlaminck on 4/4/16.
//  Copyright © 2016 SmartThings. All rights reserved.
//

import Foundation
import WebKit

/**
 TigonExecuter provides a simple interface for interacting with Javascript. It assumes Tigon.js is included in the HTML.
 
 TigonExecutor has default implementations for WKWebView.
 There is no need to implement this protocol unless you want custom behavior.

 - seealso:
    [tigon-js](https://github.com/SmartThingsOSS/tigon-js)
 
*/
public protocol TigonExecutor {
    
    /**
     A way to respond to a message with an error.
     
     - parameters:
        - id: The id of the original message
        - error: The error to pass back to the sender of the original message
     */
    func sendErrorResponse(_ id: String, error: NSError)

    /**
     A way to respond to a message with a success object.
     
     - parameters:
        - id: The id of the original message
        - response: The success object to pass back to the sender of the original message
     */
    func sendSuccessResponse(_ id: String, response: AnyObject)
    
    /**
     A way to send a message to javascript.
     
     - parameters:
        - message: The message to send. This can be a stringified object.
     */
    func sendMessage(_ message: String)
    
    /**
     A way to stringify objects in a way that is standard to Tigon
    
     - parameters:
        - object: The object to stringify
     
     This is called by `sendSuccessResponse` and `sendErrorResponse` before sending the message response.
     */
    func stringifyResponse(_ object: AnyObject) -> String
    
    /**
     A simplified wrapper for `evaluateJavaScript`
     
     - paramters:
        - script: The script to be executed
    */
    func executeJavascript(_ script: String)
}

extension WKWebView: TigonExecutor {
    
    open func sendErrorResponse(_ id: String, error: NSError) {
        let responseString = stringifyResponse(error)
        let script = "tigon.receivedErrorResponse('\(id)', \(responseString))"
        executeJavascript(script)
    }
    
    open func sendSuccessResponse(_ id: String, response: AnyObject) {
        let responseString = stringifyResponse(response)
        let script = "tigon.receivedSuccessResponse('\(id)', \(responseString))"
        executeJavascript(script)
    }
    
    public func sendMessage(_ message: String) {
        executeJavascript("tigon.receivedMessage(\(message))")
    }
    
    public func stringifyResponse(_ object: AnyObject) -> String {
        var responseString = "{}"
        
        do {
            switch object {
            case let dictionary as [AnyHashable: Any]:
                let json = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
                if let encodedString = String(data: json, encoding: String.Encoding.utf8) {
                    responseString = encodedString
                }
            case let array as [AnyObject]:
                let json = try JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
                if let encodedString = String(data: json, encoding: String.Encoding.utf8) {
                    responseString = encodedString
                }
            case let string as String:
                responseString = "{\n  \"response\" : \"\(string)\"\n}"
            case let error as NSError:
                responseString = "{\n  \"error\" : \"\(error.localizedDescription)\"\n}"
            case let b as Bool:
                responseString = "{\n  \"response\" : \(b)\n}"
            default:
                print("Failed to match a condition for response object \(object)")
            }
            
        } catch {
            print("Failed to stringify response object: \(object)")
        }
        
        return responseString
    }
    
    public func executeJavascript(_ script: String) {
        evaluateJavaScript(script) { (_, error) -> Void in
            if let error = error {
                print("Tigon failed to evaluate javascript: \(script); error: \(error.localizedDescription)")
            }
        }
    }
}
