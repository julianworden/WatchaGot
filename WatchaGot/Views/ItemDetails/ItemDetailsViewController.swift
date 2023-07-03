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
        #warning("This button shouldn't show this alert if the item has no tag")
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

        NotificationCenter.default.publisher(for: .nfcSessionFinished)
            .sink { [weak self] notification in
                guard let userInfo = notification.userInfo else {
                    self?.dismissView()
                    return
                }

                if let nfcAction = userInfo[Constants.nfcAction] as? NfcAction {
                    switch nfcAction {
                    case .delete(let item):
                        self?.viewModel.deleteItemFromDatabase(item) {
                            self?.dismissView()
                        }
                    default:
                        break
                    }
                }
            }
            .store(in: &cancellables)
    }

    func showError(_ error: Error) {
        present(UIAlertController.genericError(error), animated: true)
    }

    func dismissView() {
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }

    @objc func shipButtonTapped() {
        let alert = UIAlertController(
            title: "NFC Tag Detected",
            message: "It looks like this item's data has been saved to an NFC tag. Before shipping this item, you'll need to remove the data from that tag.",
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let startScanningAction = UIAlertAction(title: "Start Scanning", style: .default, handler: shipAlertConfirmed)
        alert.addAction(cancelAction)
        alert.addAction(startScanningAction)

        present(alert, animated: true)
    }

    func shipAlertConfirmed(_ action: UIAlertAction) {
        viewModel.beginNfcScanning()
    }
}

#Preview {
    let itemDetailsViewController = ItemDetailsViewController()
    let itemDetailsViewModel = ItemDetailsViewModel(item: Item.example)
    itemDetailsViewController.viewModel = itemDetailsViewModel
    return UINavigationController(rootViewController: itemDetailsViewController)
}
