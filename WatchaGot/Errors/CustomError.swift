//
//  CustomError.swift
//  WatchaGot
//
//  Created by Julian Worden on 7/6/23.
//

import Foundation

enum CustomError: LocalizedError {
    case unexpectedNilValue

    var errorDescription: String? {
        switch self {
        case .unexpectedNilValue:
            return "We found an unexpected nil value. Please contact support."
        }
    }
}
