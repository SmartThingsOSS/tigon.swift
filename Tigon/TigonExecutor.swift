//
//  TigonExecutor.swift
//  Tigon
//
//  Created by Steven Vlaminck on 4/4/16.
//  Copyright © 2016 SmartThings. All rights reserved.
//

import Foundation
import WebKit

public protocol TigonExecutor {
    func sendJavascriptError(id: String, error: NSError)
    func sendJavascriptSuccess(id: String, response: AnyObject)
    func stringifyResponse(object: AnyObject) -> String
    func executeJavascript(script: String)
}

extension TigonWebView: TigonExecutor {
    
    public func sendJavascriptError(id: String, error: NSError) {
        let responseString = stringifyResponse(error)
        let script = "tigon.receivedErrorResponse('\(id)', \(responseString))"
        executeJavascript(script)
    }
    
    public func sendJavascriptSuccess(id: String, response: AnyObject) {
        let responseString = stringifyResponse(response)
        let script = "tigon.receivedSuccessResponse('\(id)', \(responseString))"
        executeJavascript(script)
    }
    
    public func stringifyResponse(object: AnyObject) -> String {
        var responseString = "{}"
        
        do {
            switch object {
            case let dictionary as [NSObject: AnyObject]:
                let json = try NSJSONSerialization.dataWithJSONObject(dictionary, options: .PrettyPrinted)
                if let encodedString = String(data: json, encoding: NSUTF8StringEncoding) {
                    responseString = encodedString
                }
            case let array as [AnyObject]:
                let json = try NSJSONSerialization.dataWithJSONObject(array, options: .PrettyPrinted)
                if let encodedString = String(data: json, encoding: NSUTF8StringEncoding) {
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
    
    public func executeJavascript(script: String) {
        evaluateJavaScript(script) { (_, error) -> Void in
            if let error = error {
                print("Tigon failed to evaluate javascript: \(script); error: \(error.localizedDescription)")
            }
        }
    }
}
