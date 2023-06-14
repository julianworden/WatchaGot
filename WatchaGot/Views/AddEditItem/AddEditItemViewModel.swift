//
//  AddEditItemViewModel.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/7/23.
//

import UIKit

final class AddEditItemViewModel {
    @Published var updatedItem: Item?
    @Published var error: Error?

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
            DatabaseService.shared.saveData(save: newItem, at: Constants.apiItemsUrl) { [weak self] item, error in
                guard error == nil else {
                    self?.error = HttpError.badResponse
                    return
                }

                DispatchQueue.main.async {
                    self?.updatedItem = item
                }
            }
        }
    }
}
