//
//  AddEditItemViewModel.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/7/23.
//

import CoreNFC
import UIKit

final class AddEditItemViewModel: MainViewModel {
    /// The `Item` that is updated or created by `saveButtonTapped()`.
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
               let updatedItem {
                try NfcService.shared.startScanning(withAction: .write(item: updatedItem))
            }
        } catch {
            self.error = error
        }
    }
    
    /// Saves the new or updated item to the database. If this operation completes successfully, it will use the `updatedItem`
    /// property to prompt the user to either update an existing NFC tag or to add the item's data to a new NFC tag.
    func saveButtonTapped() {
        if itemToEdit == nil {
            let newItem = Item(
                name: itemName,
                price: itemPrice,
                notes: itemNotes.isReallyEmpty ? nil : itemNotes
            )
            
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
