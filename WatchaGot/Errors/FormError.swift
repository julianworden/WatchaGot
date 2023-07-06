//
//  FormError.swift
//  WatchaGot
//
//  Created by Julian Worden on 7/6/23.
//

import Foundation

enum FormError: LocalizedError {
    case incompleteAddEditItemViewControllerForm

    var errorDescription: String? {
        switch self {
        case .incompleteAddEditItemViewControllerForm:
            return "The Name field is required, please ensure that you've entered a valid item name."
        }
    }
}
