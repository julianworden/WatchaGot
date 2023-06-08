//
//  AddEditItemViewModel.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/7/23.
//

import UIKit

final class AddEditItemViewModel {
    var itemToEdit: Item?

    var itemName = ""
    var itemPrice = 0.0

    var navigationTitle: String {
        itemToEdit == nil ? "Create Item" : "Edit Item"
    }

    init(itemToEdit: Item? = nil) {
        self.itemToEdit = itemToEdit
    }
}
