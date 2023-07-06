//
//  AddEditItemViewModel.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/7/23.
//

import CoreNFC
import UIKit

final class AddEditItemViewModel: MainViewModel {
    /// The item that is created by `saveButtonTapped()`.
    @Published var newItem: Item?
    /// The item that is created by `saveButtonTapped()`.
    @Published var updatedItem: Item?
    @Published var error: Error?

    var itemToEdit: Item?

    var itemName = ""
    var itemPrice = 0.0
    var itemNotes = ""

    var nfcSession: NFCNDEFReaderSession?

    var navigationTitle: String {
        itemToEdit == nil ? "Create Item" : "Edit Item"
    }

    init(itemToEdit: Item? = nil) {
        self.itemToEdit = itemToEdit
    }
    
    /// Starts the `NFCNDEFReaderSession` for writing to an NFC tag.
    func beginNfcScanning() {
        do {
            if itemToEdit == nil,
               let newItem {
                try NfcService.shared.startScanning(withAction: .write(item: newItem))
            }
        } catch {
            self.error = error
        }
    }

    /// Determines whether or not the save button should update an existing item or create a new one.
    func saveButtonTapped() {
        if let itemToEdit {
            updateItem(itemToEdit)
        } else {
            createNewItem()
        }
    }
    
    /// Uses the data entered by the user to create a new item and save it to the database.
    func createNewItem() {
        let newItem = Item(
            name: itemName,
            price: itemPrice,
            notes: itemNotes.isReallyEmpty ? nil : itemNotes
        )

        DatabaseService.shared.saveData(save: newItem, at: Constants.apiItemsUrl) { [weak self] newItem, error in
            guard error == nil else {
                self?.error = HttpError.badResponse
                return
            }

            DispatchQueue.main.async {
                self?.newItem = newItem
            }
        }
    }
    
    /// Uses the data entered by the user to update an existing item in the database.
    /// - Parameter itemToEdit: The item to be updated within the database.
    func updateItem(_ itemToEdit: Item) {
        var updatedItem = Item(
            id: itemToEdit.id,
            name: itemName,
            price: itemPrice,
            hasTag: itemToEdit.hasTag,
            notes: itemNotes
        )

        DatabaseService.shared.updateData(update: updatedItem, at: Constants.apiItemsUrl) { [weak self] updatedItem, error in
            guard error == nil else {
                self?.error = HttpError.badResponse
                return
            }

            DispatchQueue.main.async {
                self?.updatedItem = updatedItem
            }
        }
    }
}
