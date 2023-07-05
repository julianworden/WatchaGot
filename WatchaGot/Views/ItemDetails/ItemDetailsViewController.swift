//
//  ItemDetailsViewController.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/15/23.
//

import Combine
import UIKit

class ItemDetailsViewController: UIViewController, MainViewController {
    lazy private var textStackView = UIStackView(
        arrangedSubviews: [itemNameLabel, itemPriceLabel, itemNotesLabel]
    )
    lazy private var itemNameLabel = UILabel()
    lazy private var itemPriceLabel = UILabel()
    lazy private var itemNotesLabel = UILabel()
    lazy private var shipButton = UIButton(configuration: .borderedProminent())
    lazy private var editButton = UIBarButtonItem(
        title: "Edit",
        style: .plain,
        target: self,
        action: #selector(editButtonTapped)
    )

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
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = editButton

        textStackView.axis = .vertical
        textStackView.spacing = 6

        itemNameLabel.text = viewModel.item.name
        itemNameLabel.font = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: UIFont.boldLargeTitle)
        itemNameLabel.adjustsFontForContentSizeCategory = true

        itemPriceLabel.text = viewModel.item.formattedPrice
        itemPriceLabel.font = .preferredFont(forTextStyle: .body)
        itemPriceLabel.textColor = .secondaryLabel
        itemPriceLabel.adjustsFontForContentSizeCategory = true

        itemNotesLabel.text = viewModel.item.notes
        itemNotesLabel.font = .preferredFont(forTextStyle: .body)
        itemNotesLabel.numberOfLines = 0
        itemNotesLabel.adjustsFontForContentSizeCategory = true

        shipButton.setTitle("Ship", for: .normal)
        // TODO: This button shouldn't show this alert if the item has no tag
        shipButton.addTarget(self, action: #selector(shipButtonTapped), for: .touchUpInside)
    }

    func constrain() {
        view.addConstrainedSubviews(textStackView, shipButton)

        itemNotesLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            textStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),

            shipButton.topAnchor.constraint(equalTo: textStackView.bottomAnchor, constant: 10),
            shipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
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

    @objc func editButtonTapped() {

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
