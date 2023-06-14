//
//  MainView.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/14/23.
//

import Foundation

protocol MainView {
    func subscribeToPublishers()
    func showError(_ error: Error)
}
