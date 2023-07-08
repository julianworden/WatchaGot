//
//  AddEditItemViewController.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/7/23.
//

import Combine
import CoreNFC
import UIKit

class AddEditItemViewController: UIViewController, MainViewController {
    var viewModel: AddEditItemViewModel!
    var cancellables = Set<AnyCancellable>()

    lazy private var tableView = UITableView()
    lazy private var saveButton = UIBarButtonItem(
        barButtonSystemItem: .save,
        target: self,
        action: #selector(saveButtonTapped)
    )
    lazy var cancelButton = UIBarButtonItem(
        barButtonSystemItem: .cancel,
        target: self,
        action: #selector(cancelButtonTapped)
    )

    weak var delegate: AddEditItemViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        constrain()
        subscribeToPublishers()
    }

    func configure() {
        title = viewModel.navigationTitle
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AddEditItemTextFieldCell.self, forCellReuseIdentifier: AddEditItemTextFieldCell.reuseIdentifier)
        tableView.register(AddEditItemTextViewCell.self, forCellReuseIdentifier: AddEditItemTextViewCell.reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = 75
    }

    func constrain() {
        view.addConstrainedSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func subscribeToPublishers() {
        // New value published when user successfully creates new item
        viewModel.$newItem
            .sink { [weak self] newItem in
                guard let newItem else { return }

                self?.delegate?.addEditItemViewController(didCreateItem: newItem)
                self?.presentScanningAlert()
            }
            .store(in: &cancellables)

        viewModel.$updatedItem
            .sink { [weak self] updatedItem in
                guard let updatedItem else { return }

                if updatedItem.hasTag {
                    self?.presentEditedItemHasTagAlert()
                } else {
                    self?.dismissView()
                }
            }
            .store(in: &cancellables)

        viewModel.$error
            .sink { [weak self] error in
                if let error {
                    self?.showError(error)
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .nfcSessionFinished)
            .sink { [weak self] notification in
                if let nfcAction = notification.userInfo?[Constants.nfcAction] as? NfcAction {
                    switch nfcAction {
                    case .write(let item):
                        self?.delegate?.addEditItemViewController(didUpdateItem: item)
                    default:
                        break
                    }
                }

                self?.dismissView()
            }
            .store(in: &cancellables)
    }

    func showError(_ error: Error) {
        present(UIAlertController.genericError(error), animated: true)
    }
    
    /// Presents an alert that asks the user if they are going to use an NFC tag to store their new Item's data.
    func presentScanningAlert() {
        let alert = UIAlertController(
            title: "Are You Using an NFC Tag?",
            message: "Watcha Got can write item data to empty NFC tags. If you have an NFC tag, tap \"Yes\" to use it to receive and ship items faster.",
            preferredStyle: .alert
        )
        let noAction = UIAlertAction(title: "No", style: .default, handler: userIsNotUsingNfcTagConfirmed)
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: userIsUsingNfcTagConfirmed)
        alert.addAction(noAction)
        alert.addAction(yesAction)

        present(alert, animated: true)
    }

    func presentEditedItemHasTagAlert() {
        let alert = UIAlertController(
            title: "NFC Tag Detected",
            message: "You just edited this item's data, which means its NFC tag's data is no longer up to date. Tap \"Update Data\" to start scanning for the item's NFC tag.",
            preferredStyle: .alert
        )
        let startScanningAction = UIAlertAction(title: "Start Scanning", style: .default, handler: startScanningToUpdateItemNfcTagConfirmed)
        alert.addAction(startScanningAction)

        present(alert, animated: true)
    }

    /// Called when a user expresses they do not have an NFC tag to use.
    func userIsNotUsingNfcTagConfirmed(_ action: UIAlertAction) {
        dismissView()
    }
    
    /// Called when a user expresses they do have an NFC tag to use.
    func userIsUsingNfcTagConfirmed(_ action: UIAlertAction) {
        viewModel.beginNfcScanningForItemCreation()
    }

    func startScanningToUpdateItemNfcTagConfirmed(_ action: UIAlertAction) {
        viewModel.beginNfcScanningForItemUpdate()
    }

    func dismissView() {
        DispatchQueue.main.async { [weak self] in
            self?.dismiss(animated: true)
        }
    }

    @objc func saveButtonTapped() {
        viewModel.saveButtonTapped()
    }

    @objc func cancelButtonTapped() {
        dismissView()
    }
}

extension AddEditItemViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AddEditItemTextFieldType.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row

        if index <= 1 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: AddEditItemTextFieldCell.reuseIdentifier,
                for: indexPath
            ) as! AddEditItemTextFieldCell
            
            let textFieldType = AddEditItemTextFieldType.getType(withTag: index)
            cell.textField.delegate = self
            cell.configure(textFieldType, forItem: viewModel.itemToEdit)
            return cell
        } else if index == 2 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: AddEditItemTextViewCell.reuseIdentifier,
                for: indexPath
            ) as! AddEditItemTextViewCell

            let textFieldType = AddEditItemTextFieldType.getType(withTag: index)
            cell.textView.delegate = self
            cell.configure(textFieldType, withItem: viewModel.itemToEdit)
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

extension AddEditItemViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
    }

    @objc func textFieldValueChanged(_ textField: UITextField) {
        switch textField.tag {
        case AddEditItemTextFieldType.name.tag:
            viewModel.itemName = textField.text ?? ""
        case AddEditItemTextFieldType.price.tag:
            viewModel.itemPrice = Double(textField.text ?? "") ?? 0.0
        default:
            break
        }
    }
}

extension AddEditItemViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        switch textView.tag {
        case AddEditItemTextFieldType.notes.tag:
            viewModel.itemNotes = textView.text ?? ""
        default:
            break
        }
    }

    // Clear placeholder if it exists.
    func textViewDidBeginEditing(_ textView: UITextView) {
        if viewModel.itemToEdit?.notes == nil &&
            viewModel.itemNotes.isReallyEmpty {
            textView.text.removeAll()
            textView.textColor = .label
            textView.font = .preferredFont(forTextStyle: .body)
        }
    }
}

#Preview("Create Item") {
    let addEditItemViewController = AddEditItemViewController()
    addEditItemViewController.viewModel = AddEditItemViewModel()
    let navigationController = UINavigationController(rootViewController: addEditItemViewController)
    return navigationController
}

#Preview("Edit Item") {
    let addEditItemViewController = AddEditItemViewController()
    addEditItemViewController.viewModel = AddEditItemViewModel(itemToEdit: Item.example)
    let navigationController = UINavigationController(rootViewController: addEditItemViewController)
    return navigationController
}
