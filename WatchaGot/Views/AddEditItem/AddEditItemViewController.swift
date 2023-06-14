//
//  AddEditItemViewController.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/7/23.
//

import Combine
import UIKit

class AddEditItemViewController: UIViewController, MainView {
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
        tableView.register(AddEditItemCell.self, forCellReuseIdentifier: AddEditItemCell.reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
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
        viewModel.$updatedItem
            .sink { [weak self] updatedItem in
                guard let updatedItem else { return }
                
                self?.delegate?.addEditItemViewController(didCreateItem: updatedItem)
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)

        viewModel.$error
            .sink { [weak self] error in
                if let error {
                    self?.showError(error)
                }
            }
            .store(in: &cancellables)
    }

    func showError(_ error: Error) {
        present(UIAlertController.genericError(error), animated: true)
    }

    @objc func saveButtonTapped() {
        viewModel.saveButtonTapped()
    }

    @objc func cancelButtonTapped() {
        dismiss(animated: true)
    }
}

extension AddEditItemViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AddEditItemTextFieldType.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row

        if index <= 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: AddEditItemCell.reuseIdentifier, for: indexPath) as! AddEditItemCell
            let textFieldType = AddEditItemTextFieldType.getType(withTag: index)
            cell.textField.delegate = self
            cell.configure(textFieldType)
            return cell
        } else {
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
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
