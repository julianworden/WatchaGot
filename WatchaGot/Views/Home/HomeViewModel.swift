//
//  HomeViewModel.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/12/23.
//

import Combine
import Foundation

final class HomeViewModel: MainViewModel {
    @Published var items = [Item]()
    @Published var error: Error?

    func fetchItems() {
        DatabaseService.shared.getData(get: Item.self, at: Constants.apiItemsUrl) { [weak self] items, error in
            guard error == nil,
                  let items else {
                self?.error = error
                return
            }

            DispatchQueue.main.async {
                self?.items = items.sorted { $0.name.lowercased() < $1.name.lowercased() }
            }
        }
    }

    func deleteItem(at indexPath: IndexPath) {
        do {
            guard items.indices.contains(indexPath.row) else { return }

            let itemToDelete = items[indexPath.row]
            let url = try Constants.getApiUrl(for: itemToDelete)
            DatabaseService.shared.deleteData(at: url) { [weak self] error in
                guard error == nil else {
                    self?.error = error
                    return
                }
            }

            items.remove(at: indexPath.row)
        } catch {
            self.error = error
        }
    }


    func addItemToItemsArray(_ item: Item) {
        DispatchQueue.main.async { [weak self] in
            self?.items.append(item)
            self?.items.sort { $0.name < $1.name }
        }
    }

    func updateItemInItemsArray(_ updatedItem: Item) {
        DispatchQueue.main.async { [weak self] in
            if let itemIndex = self?.items.firstIndex(where: { $0.id == updatedItem.id }) {
                self?.items.remove(at: itemIndex)
                self?.items.insert(updatedItem, at: itemIndex)
            }
        }
    }

    func deleteItemsInItemsArray(_ itemToDelete: Item) {
        DispatchQueue.main.async { [weak self] in
            if let itemIndex = self?.items.firstIndex(where: { $0.id == itemToDelete.id }) {
                self?.items.remove(at: itemIndex)
            }
        }
    }
}
