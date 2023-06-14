//
//  UIAlertController+GenericError.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/14/23.
//

import UIKit

extension UIAlertController {
    static func genericError(_ error: Error) -> UIAlertController {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        return alertController
    }
}
