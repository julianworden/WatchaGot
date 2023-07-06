//
//  ItemDetailsViewModel.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/15/23.
//

import Combine

final class ItemDetailsViewModel: MainViewModel {
    @Published var error: Error?

    var item: Item
    var cancellables = Set<AnyCancellable>()

    init(item: Item) {
        self.item = item
    }

    func beginNfcScanning() {
        do {
            try NfcService.shared.startScanning(withAction: .delete(item: item))
        } catch {
            self.error = error
        }
    }

    func deleteItemFromDatabase(_ item: Item, completion: @escaping () -> Void) {
        do {
            DatabaseService.shared.deleteData(at: try Constants.getApiUrl(for: item)) { [weak self] error in
                guard error == nil else {
                    self?.error = error
                    return
                }

                completion()
            }
        } catch {
            self.error = error
        }
    }
}
