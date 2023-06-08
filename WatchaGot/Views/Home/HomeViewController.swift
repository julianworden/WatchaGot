//
//  HomeViewController.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/6/23.
//

import SwiftPlus
import UIKit

class HomeViewController: UIViewController {
    lazy private var buttonStack = UIStackView(arrangedSubviews: [receiveButton, shipButton])
    lazy private var receiveButton = UIButton(configuration: .borderedProminentWithPaddedImage())
    lazy private var shipButton = UIButton(configuration: .borderedProminentWithPaddedImage())

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        constrain()
    }

    func configure() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Watcha Got?"

        buttonStack.axis = .horizontal
        buttonStack.spacing = 10
        buttonStack.distribution = .fillEqually

        receiveButton.setTitle("Receive", for: .normal)
        receiveButton.setImage(UIImage(systemName: "tray.and.arrow.down"), for: .normal)
        receiveButton.addTarget(self, action: #selector(receiveButtonTapped), for: .touchUpInside)

        shipButton.setTitle("Ship", for: .normal)
        shipButton.setImage(UIImage(systemName: "tray.and.arrow.up"), for: .normal)
    }

    func constrain() {
        view.addConstrainedSubview(buttonStack)

        NSLayoutConstraint.activate([
            buttonStack.heightAnchor.constraint(equalToConstant: 50),
            buttonStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }

    @objc func receiveButtonTapped() {
        let addEditItemViewController = AddEditItemViewController()
        addEditItemViewController.viewModel = AddEditItemViewModel(itemToEdit: nil)
        let navigationController = UINavigationController(
            rootViewController: addEditItemViewController
        )
        present(navigationController, animated: true)
    }
}

#Preview {
    UINavigationController(rootViewController: HomeViewController())
}
