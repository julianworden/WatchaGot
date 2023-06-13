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

    static let example = Item(name: "Couch", price: 499.99)

    internal init(id: UUID? = nil, name: String, price: Double) {
        self.id = id
        self.name = name
        self.price = price
    }
}
