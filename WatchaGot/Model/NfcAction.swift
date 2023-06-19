//
//  NfcAction.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/18/23.
//

import Foundation

enum NfcAction {
    case read(item: Item)
    case write(item: Item)
}
