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

    func fetchItems() {
        DatabaseService.shared.getData(get: Item.self, at: Constants.apiItemsUrl) { [weak self] items, error in
            guard error == nil,
                  let items else {
                print("ERROR: \(error!)")
                // TODO: Handle Error
                return
            }

            DispatchQueue.main.async {
                self?.items = items
            }
        }
    }
}
