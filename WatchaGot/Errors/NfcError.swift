//
//  NfcError.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/17/23.
//

import Foundation

enum NfcError: LocalizedError {
    case jsonEncodingFailed
    case jsonDecodingFailed
    case scanningNotSupported
    case moreThanOneTagDetected
    case connectionFailed
    case statusQueryFailed
    case unsupportedTag
    case tagIsReadOnly
    case dataNotFound
    case readFailed
    case writeFailed
    case unknownNdefStatus
    case tagIsEmpty
    case databaseUpdateFailed

    var errorDescription: String? {
        switch self {
        case .jsonEncodingFailed:
            return "Failed to encode item data. Please contact support."
        case .jsonDecodingFailed:
            return "Failed to decode item data. Please contact support."
        case .scanningNotSupported:
            return "This device does not support NFC tag scanning."
        case .moreThanOneTagDetected:
            return "More than 1 NFC tag has been detected. Please remove all tags but one and try again."
        case .connectionFailed:
            return "NFC tag connection failed. Please try again."
        case .statusQueryFailed:
            return "NDEF status query failed. Please try again."
        case .unsupportedTag:
            return "This NFC tag is not NDEF compliant. Please try again with an NFC tag that is NDEF compliant."
        case .tagIsReadOnly:
            return "This NFC tag's data can only be read, so you cannot write data to it. Please try again with an NFC tag that allows writing."
        case .dataNotFound:
            return "The data you requested to write to your NFC tag could not be found. Please try again."
        case .readFailed:
            return "Failed to read data from NFC tag. Please try again."
        case .writeFailed:
            return "Failed to write data to NFC tag. Please try again."
        case .unknownNdefStatus:
            return "An unknown NDEF status was found. Please contact support."
        case .tagIsEmpty:
            return "The NFC tag you're attempting to read from has no data on it. Please try again with an NFC tag that is not empty."
        case .databaseUpdateFailed:
            return "Failed to update this item's status in database. Please contact support."
        }
    }
}
