Tigon.swift
===========

Tigon is a communication layer between javascript and mobile clients. Tigon.swift is the iOS implementation of that communication layer.

Requirements
--------
**Tigon.swift will not work if [tigon-js](https://github.com/SmartThingsOSS/tigon-js/) is not included in your HTML document.**

* You can include `tigon.js` via a `script` tag in your HTML document.
```HTML
<head>
  <script src="https://cdn.my-server.com/js/tigon.js"></script>
</head>
```

* You can include `tigon.js` in your app and inject it as a `WKUserScript`.
```swift
func injectTigon(into webView: WKWebView) throws {
    guard let scriptPath = NSBundle.mainBundle().pathForResource("tigon", ofType: "js") else {
        throw NSError(description: "tigon.js couldn't be found in the main bundle", domain: NSCocoaErrorDomain, code: NSFileNoSuchFileError)
    }
    let scriptString = try NSString(contentsOfFile: scriptPath, encoding: NSUTF8StringEncoding) as String
    let script = WKUserScript(source: scriptString, injectionTime: .AtDocumentStart, forMainFrameOnly: true)
    webView.configuration.userContentController.addUserScript(script)
}
```

Installation
------------
[Carthage](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos) is recommended, but [Cocoapods](https://guides.cocoapods.org/) works too.

Usage
-----
Tigon is designed to stay out of your way while still providing you with an easy-to-use communication layer. All you have to do is implement the `TigonMessageHandler` protocol and add your implementer to your contentController by calling `addTigonMessageHandler(_)`. Whatever else you want to do with your `WKWebView` is up to you. Just make sure you call `removeTigonMessageHandler()` during `deinit` or you will leak your webView.

Here is an example ViewController that uses Tigon
```swift

import Tigon

class ExampleViewController: UIViewController {

  weak var webView: WKWebView?

  deinit {
    // Make sure we remove our message handler or we will leak our webView.
    webView?.configuration.userContentController.removeTigonMessageHandler()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let contentController = WKUserContentController()
    contentController.addTigonMessageHandler(self)

    let configuration = WKWebViewConfiguration()
    configuration.userContentController = contentController

    let webView = WKWebView(frame: CGRectZero, configuration: configuration)
    view.addSubview(webView)
    webView.translatesAutoresizingMaskIntoConstraints = false
    layoutConstraintsForWebView(webView)
    self.webView = webView
  }

  ...

}

extension ExampleViewController: TigonMessageHandler {

  func handleMessage(id: String, payload: AnyObject) {
    print("attempting to handle payload: \(payload)")
    do {
      // handle a message from javascript
      let successObject = try thatThing(payload)
      // let your javascript know it succeeded
      webView?.sendSuccessResponse(id, response: successObject)
    } catch {
      // let your javascript know it didn't succeed
      webView?.sendErrorResponse(id, error: error)
    }
  }

  func messageError(error: TigonError, message: WKScriptMessage) {
    // Handle errors. Tigon will call this if it failed to parse a message.
    // This is a good debugging tool.
    print("\(error): \(message.body)")
  }

}

extension ExampleViewController: WKScriptMessageHandler {
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        // handle non-tigon messages
        print("\(message.name): \(message.body)")
    }
}
```
