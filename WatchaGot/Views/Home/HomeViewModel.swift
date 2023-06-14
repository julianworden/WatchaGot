//
//  HomeViewModel.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/12/23.
//

import Combine
import Foundation

final class HomeViewModel {
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
                self?.items = items
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
}
