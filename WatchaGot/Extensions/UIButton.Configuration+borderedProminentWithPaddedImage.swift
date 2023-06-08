//
//  UIButton.Configuration+borderedProminentWithPaddedImage.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/7/23.
//

import UIKit

extension UIButton.Configuration {
    static func borderedProminentWithPaddedImage() -> UIButton.Configuration {
        var configuration = UIButton.Configuration.borderedProminent()
        configuration.imagePadding = 10
        return configuration
    }
}
