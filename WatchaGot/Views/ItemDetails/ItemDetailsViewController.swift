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
    lazy private var shipButton = UIButton(configuration: .bordered())

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
        title = "Item Details"

        itemNameLabel.text = viewModel.item.name

        shipButton.setTitle("Ship", for: .normal)
        shipButton.addTarget(self, action: #selector(shipButtonTapped), for: .touchUpInside)
    }

    func constrain() {
        view.addConstrainedSubviews(itemNameLabel, shipButton)

        NSLayoutConstraint.activate([
            itemNameLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            itemNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            shipButton.topAnchor.constraint(equalTo: itemNameLabel.bottomAnchor)
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

    @objc func shipButtonTapped() {
        viewModel.beginNfcScanning()
    }
}

#Preview {
    let itemDetailsViewController = ItemDetailsViewController()
    let itemDetailsViewModel = ItemDetailsViewModel(item: Item.example)
    itemDetailsViewController.viewModel = itemDetailsViewModel
    return UINavigationController(rootViewController: itemDetailsViewController)
}
