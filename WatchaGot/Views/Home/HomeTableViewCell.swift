//
//  HomeTableViewCell.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/12/23.
//

import UIKit

class HomeTableViewCell: UITableViewCell {
    static let reuseIdentifier = "HomeTableViewCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
