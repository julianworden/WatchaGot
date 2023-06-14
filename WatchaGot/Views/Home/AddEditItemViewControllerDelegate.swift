//
//  AddEditItemViewControllerDelegate.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/13/23.
//

import Foundation

protocol AddEditItemViewControllerDelegate: AnyObject {
    func addEditItemViewController(didCreateItem item: Item)
}
