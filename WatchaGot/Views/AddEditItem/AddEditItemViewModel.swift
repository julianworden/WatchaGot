//
//  AddEditItemViewModel.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/7/23.
//

import UIKit

final class AddEditItemViewModel {
    @Published var dismissViewController = false

    var itemToEdit: Item?

    var itemName = ""
    var itemPrice = 0.0

    var navigationTitle: String {
        itemToEdit == nil ? "Create Item" : "Edit Item"
    }

    init(itemToEdit: Item? = nil) {
        self.itemToEdit = itemToEdit
    }

    func saveButtonTapped() {
        if itemToEdit == nil {
            let newItem = Item(name: itemName, price: itemPrice)
            DatabaseService.shared.saveData(save: newItem, at: Constants.apiItemsUrl) { [weak self] error in
                guard error == nil else {
                    print("ERROR: \(error!)")
                    return
                } //  TODO: Handle Error
                self?.dismissViewController = true
            }
        }
    }
}
