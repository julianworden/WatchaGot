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

    var tag: Int {
        switch self {
        case .name:
            return 0
        case .price:
            return 1
        }
    }

    var placeholder: String {
        switch self {
        case .name:
            return "Name"
        case .price:
            return "Price"
        }
    }

    var keyboardType: UIKeyboardType {
        switch self {
        case .name:
            return .default
        case .price:
            return .decimalPad
        }
    }

    static func getType(withTag tag: Int) -> AddEditItemTextFieldType {
        return AddEditItemTextFieldType.allCases[tag]
    }
}
