//
//  Item.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/7/23.
//

import Foundation

struct Item: Codable, Hashable {
    let id: UUID?
    let name: String
    let price: Double
    var hasTag: Bool
    let notes: String?

    var formattedPrice: String {
        return price.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
    }

    mutating func addTag() {
        hasTag = true
    }

    mutating func removeTag() {
        hasTag = false
    }

    static let example = Item(
        name: "Couch",
        price: 499.99,
        hasTag: true,
        notes: "This couch is such a great couch! It will absolutely fix all of your problems, even the ones you didn’t know you had."
    )

    internal init(
        id: UUID? = nil,
        name: String,
        price: Double,
        hasTag: Bool = false,
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.hasTag = hasTag
        self.notes = notes
    }
}
