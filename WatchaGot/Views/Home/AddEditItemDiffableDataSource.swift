//
//  AddEditItemDiffableDataSource.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/14/23.
//

import UIKit

final class AddEditItemDiffableDataSource: UITableViewDiffableDataSource<HomeTableViewSection, Item> {
    weak var delegate: AddEditItemDiffableDataSourceDelegate?

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        delegate?.addEditItemDiffableDataSource(didDeleteItemAt: indexPath)
    }
}

protocol AddEditItemDiffableDataSourceDelegate: AnyObject {
    func addEditItemDiffableDataSource(didDeleteItemAt indexPath: IndexPath)
}
