//
//  ItemDetailsViewModel.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/15/23.
//

import Foundation

final class ItemDetailsViewModel: MainViewModel {
    @Published var error: Error?

    let item: Item

    init(item: Item) {
        self.item = item
    }
}
