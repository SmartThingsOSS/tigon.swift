//
//  TigonWebView.swift
//  Tigon
//
//  Created by Steven Vlaminck on 3/31/16.
//  Copyright © 2016 SmartThings. All rights reserved.
//

import Foundation
import WebKit

public protocol TigonRequestHandler {
    var webView: TigonWebView? { get set }
    func handleRequest(request: TigonRequest) throws
}

public extension TigonRequestHandler {
    func handleRequest(request: TigonRequest) throws {
        throw TigonException.InvalidPath
    }
}

public enum TigonRequestMethod: String {
    case GET
    case PUT
    case POST
    case DELETE
    case HEAD
    case OPTIONS
}

public enum TigonException: ErrorType {
    case InvalidRequest     // Catch-all exception. A use case might be when a required key in `params` is missing for a given request.
    case InvalidId          // In case Tigon somehow failed to send an id in the request. This probably won't happen unless someone is overwriting Tigon.js
    case InvalidPath        // The given `path` is not supported. Either the app implementing Tigon, or not allowed for the given `method`.
    case InvalidMethod      // The method (GET, PUT, etc) is not supported for the given request
    case AppSpecific(localizedDescription: String)
    var localizedDescription: String {
        switch self {
        case .InvalidId: return NSLocalizedString("TIGON_EXCEPTION_MESSAGE_MISSING_ID", comment: "")
        case .InvalidPath: return NSLocalizedString("TIGON_EXCEPTION_MESSAGE_INVALID_PATH", comment: "")
        case .InvalidMethod: return NSLocalizedString("TIGON_EXCEPTION_MESSAGE_INVALID_METHOD", comment: "")
        case .InvalidRequest: return NSLocalizedString("TIGON_EXCEPTION_MESSAGE_INVALID_REQUEST", comment: "")
        case .AppSpecific(let localizedDescription): return localizedDescription
        }
    }
}

public struct TigonRequest {
    let id: String
    let method: TigonRequestMethod
    let path: String
    let params: [String: AnyObject]?
    
    init(_ body: [NSObject: AnyObject]) throws {
        guard let id = body["id"] as? String where id.characters.count > 0 else {
            throw TigonException.InvalidId
        }
        guard let path = body["path"] as? String else {
            throw TigonException.InvalidPath
        }
        guard let rawMethod = body["method"] as? String,
            let method = TigonRequestMethod(rawValue: rawMethod) else {
                throw TigonException.InvalidMethod
        }
        
        self.id = id
        self.method = method
        self.path = path
        self.params = body["params"] as? [String: AnyObject]
    }
}

public class TigonWebView: WKWebView {
    
    var requestHandler: TigonRequestHandler
    
    public init(requestHandler: TigonRequestHandler) {
        
        self.requestHandler = requestHandler
        
        let contentController = WKUserContentController()
        let messageHandler = TigonScriptMessageHandler()
        contentController.addScriptMessageHandler(messageHandler, name: "tigon")
        
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.userContentController = contentController
        
        super.init(frame: CGRectZero, configuration: configuration)
        messageHandler.delegate = self
    }
    
    
}

extension TigonWebView: WKScriptMessageHandler {
    public func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        
        guard let id = message.body["id"] as? String else {
            print("internal error!")
            return
        }
        
        do {
            guard let body = message.body as? [String: AnyObject] else { 
                throw TigonException.InvalidPath 
            }
            let request = try TigonRequest(body)
            try requestHandler.handleRequest(request)
        } catch (let error as TigonException) {
            sendJavascriptError(id, error: NSError(domain: "com.tigon", code: 0, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription]))
        } catch {
            print(error)
        }
    }
}

public protocol TigonExecutor {
    func sendJavascriptError(responseId: String, error: NSError)
    func sendJavascriptSuccess(responseId: String, response: AnyObject)
    func stringifyResponse(object: AnyObject) -> String
    func executeJavascript(script: String)
}

extension TigonWebView: TigonExecutor {
    
    public func sendJavascriptError(responseId: String, error: NSError) {
        let responseString = stringifyResponse(error)
        let script = "Tigon.receivedTigonMessageError('\(responseId)', \(responseString))"
        executeJavascript(script)
    }
    
    public func sendJavascriptSuccess(responseId: String, response: AnyObject) {
        let responseString = stringifyResponse(response)
        let script = "Tigon.receivedTigonMessageSuccess('\(responseId)', \(responseString))"
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



