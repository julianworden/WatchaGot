//
//  UIFont+boldLargeTitle.swift
//  WatchaGot
//
//  Created by Julian Worden on 7/5/23.
//

import UIKit

extension UIFont {
    static var boldLargeTitle: UIFont {
        UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize)
    }
}
