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

    lazy private var buttonStackView = UIStackView(
        arrangedSubviews: [shipButton, addTagButton]
    )
    lazy private var shipButton = UIButton(configuration: .borderedProminentWithPaddedImage())
    lazy private var addTagButton = UIButton(configuration: .borderedProminentWithPaddedImage())

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

        buttonStackView.axis = .vertical
        buttonStackView.spacing = 6
        buttonStackView.distribution = .fillEqually

        shipButton.setTitle("Ship", for: .normal)
        shipButton.setImage(UIImage(systemName: "box.truck"), for: .normal)
        // TODO: This button shouldn't show this alert if the item has no tag
        shipButton.addTarget(self, action: #selector(shipButtonTapped), for: .touchUpInside)

        addTagButton.setTitle("Add Tag", for: .normal)
        addTagButton.setImage(UIImage(systemName: "tag"), for: .normal)
        addTagButton.isHidden = viewModel.item.hasTag ? true : false
        addTagButton.addTarget(self, action: #selector(addTagButtonTapped), for: .touchUpInside)
    }

    func constrain() {
        view.addConstrainedSubviews(textStackView, buttonStackView)

        NSLayoutConstraint.activate([
            textStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            textStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),

            buttonStackView.topAnchor.constraint(equalTo: textStackView.bottomAnchor, constant: 10),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }

    func subscribeToPublishers() {
        viewModel.$error
            .sink { [weak self] error in
                guard let error else { return }

                self?.showError(error)
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .itemUpdated)
            .sink { [weak self] notification in
                if let updatedItem = notification.userInfo?[Constants.updatedItem] as? Item {
                    self?.viewModel.item = updatedItem
                    self?.itemNameLabel.text = updatedItem.name
                    self?.itemPriceLabel.text = updatedItem.formattedPrice
                    self?.itemNotesLabel.text = updatedItem.notes
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .nfcSessionFinished)
            .sink { [weak self] notification in
                if let nfcAction = notification.userInfo?[Constants.nfcAction] as? NfcAction {
                    switch nfcAction {
                    case .delete(let item):
                        self?.viewModel.deleteItemFromDatabase(item) {
                            self?.dismissView()
                        }
                    case .write(_):
                        self?.dismissView()
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
        if viewModel.item.hasTag {
            presentTagDetectedAlert()
        } else {
            presentShipConfirmationAlert()
        }
    }

    @objc func addTagButtonTapped() {
        viewModel.beginNfcScanningForAddingTagToItem()
    }

    @objc func editButtonTapped() {
        let addEditItemViewController = AddEditItemViewController()
        let addEditItemViewModel = AddEditItemViewModel(itemToEdit: viewModel.item)
        addEditItemViewController.viewModel = addEditItemViewModel
        
        let addEditItemNavigationController = UINavigationController(rootViewController: addEditItemViewController)
        present(addEditItemNavigationController, animated: true)
    }

    func presentTagDetectedAlert() {
        let alert = UIAlertController(
            title: "NFC Tag Detected",
            message: "It looks like this item's data has been saved to an NFC tag. Before shipping this item, you'll need to remove the data from that tag.",
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let startScanningAction = UIAlertAction(title: "Start Scanning", style: .default, handler: startScanningForExistingNfcTagConfirmed)
        alert.addAction(cancelAction)
        alert.addAction(startScanningAction)

        present(alert, animated: true)
    }

    func presentShipConfirmationAlert() {
        let alert = UIAlertController(
            title: "Are You Sure?",
            message: "Shipping this item will delete it from the database. This is not reversable.",
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let yesAction = UIAlertAction(title: "Yes", style: .destructive, handler: shipItemConfirmed)
        alert.addAction(cancelAction)
        alert.addAction(yesAction)

        present(alert, animated: true)
    }
    
    /// Used for beginning an `NFCNDEFSession` to scan for `viewModel.item`'s tag.
    /// - Parameter action: Satisfies UIAlertAction initializer requirement.
    func startScanningForExistingNfcTagConfirmed(_ action: UIAlertAction) {
        viewModel.beginNfcScanningForShipment()
    }
    
    /// Used for deleting an item from the database that does not have an NFC tag.
    /// - Parameter action: Satisfies UIAlertAction initializer requirement.
    func shipItemConfirmed(_ action: UIAlertAction) {
        viewModel.deleteItemFromDatabase(viewModel.item) { [weak self] in
            self?.dismissView()
        }
    }
}

#Preview("Item Has Tag") {
    let itemDetailsViewController = ItemDetailsViewController()
    let itemDetailsViewModel = ItemDetailsViewModel(item: Item.example)
    itemDetailsViewController.viewModel = itemDetailsViewModel
    return UINavigationController(rootViewController: itemDetailsViewController)
}

#Preview("Item Has No Tag") {
    let itemDetailsViewController = ItemDetailsViewController()
    var itemExampleCopy = Item.example
    itemExampleCopy.hasTag = false
    let itemDetailsViewModel = ItemDetailsViewModel(item: itemExampleCopy)
    itemDetailsViewController.viewModel = itemDetailsViewModel
    return UINavigationController(rootViewController: itemDetailsViewController)
}

