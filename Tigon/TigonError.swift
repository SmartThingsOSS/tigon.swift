//
//  TigonError.swift
//  Tigon
//
//  Created by Steven Vlaminck on 4/4/16.
//  Copyright © 2016 SmartThings. All rights reserved.
//

import Foundation

/// An ErrorType used when parsing a message fails.
public enum TigonError: Error {
    /// The message identifier was missing or malformed.
    case invalidId
    /// The message payload was missing or malformed.
    case invalidPayload
    /// The message was unreadable.
    case unexpectedMessageFormat
}
