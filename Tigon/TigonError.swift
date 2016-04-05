//
//  TigonError.swift
//  Tigon
//
//  Created by Steven Vlaminck on 4/4/16.
//  Copyright © 2016 SmartThings. All rights reserved.
//

import Foundation

public enum TigonError: ErrorType {
    case InvalidId
    case InvalidPayload
    case UnexpectedMessageFormat
    case Unknown
}
