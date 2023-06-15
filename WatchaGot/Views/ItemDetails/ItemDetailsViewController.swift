//
//  ItemDetailsViewController.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/15/23.
//

import Combine
import UIKit

class ItemDetailsViewController: UIViewController, MainViewController {
    lazy private var itemNameLabel = UILabel()

    var viewModel: ItemDetailsViewModel!
    var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        constrain()
        subscribeToPublishers()
    }

    func configure() {
        view.backgroundColor = .systemBackground

        itemNameLabel.text = viewModel.item.name
    }

    func constrain() {
        view.addConstrainedSubview(itemNameLabel)

        NSLayoutConstraint.activate([
            itemNameLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            itemNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    func subscribeToPublishers() {
        viewModel.$error
            .sink { [weak self] error in
                guard let error else { return }

                self?.showError(error)
            }
            .store(in: &cancellables)
    }

    func showError(_ error: Error) {
        present(UIAlertController.genericError(error), animated: true)
    }
}
