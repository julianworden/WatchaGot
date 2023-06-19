//
//  AddEditItemTextField.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/8/23.
//

import UIKit

enum AddEditItemTextFieldType: CaseIterable {
    case name
    case price
    case notes

    var tag: Int {
        switch self {
        case .name:
            return 0
        case .price:
            return 1
        case .notes:
            return 2
        }
    }

    var placeholder: String {
        switch self {
        case .name:
            return "Name"
        case .price:
            return "Price (\(Locale.current.currency?.identifier ?? "Your Currency"))"
        case .notes:
            return "Notes"
        }
    }

    var keyboardType: UIKeyboardType {
        switch self {
        case .name, .notes:
            return .default
        case .price:
            return .decimalPad
        }
    }

    static func getType(withTag tag: Int) -> AddEditItemTextFieldType {
        return AddEditItemTextFieldType.allCases[tag]
    }
}
