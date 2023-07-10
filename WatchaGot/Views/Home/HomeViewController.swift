//
//  HomeViewController.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/6/23.
//

import Combine
import SwiftPlus
import UIKit

class HomeViewController: UIViewController, MainViewController {
    lazy private var receiveButton = UIButton(configuration: .borderedProminentWithPaddedImage())
    lazy private var itemsTableView = UITableView()

    private var dataSource: UITableViewDiffableDataSource<HomeTableViewSection, Item>!

    var viewModel: HomeViewModel!
    var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        createDiffableDataSource()
        configure()
        makeAccessible()
        constrain()
        subscribeToPublishers()
    }

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)

        viewModel.fetchItems()
    }

    func configure() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .always
        
        title = "Watcha Got?"

        receiveButton.setTitle("Receive New Item", for: .normal)
        receiveButton.setImage(UIImage(systemName: "tray.and.arrow.down"), for: .normal)
        receiveButton.addTarget(self, action: #selector(receiveButtonTapped), for: .touchUpInside)

        itemsTableView.delegate = self
        itemsTableView.dataSource = dataSource
        itemsTableView.register(HomeTableViewCell.self, forCellReuseIdentifier: Constants.homeTableViewCellReuseIdentifier)
    }

    func constrain() {
        view.addConstrainedSubviews(receiveButton, itemsTableView)

        NSLayoutConstraint.activate([
            receiveButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            receiveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            receiveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),

            itemsTableView.topAnchor.constraint(equalTo: receiveButton.bottomAnchor, constant: 10),
            itemsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            itemsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            itemsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func makeAccessible() {
        
    }

    func subscribeToPublishers() {
        viewModel.$items
            .sink { [weak self] items in

                // Sort is needed here because sometimes items array updates before it's sorted.
                let sortedItems = items.sorted { $0.name < $1.name }
                self?.updateDiffableDataSource(with: sortedItems)
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

    @objc func receiveButtonTapped() {
        let addEditItemViewController = AddEditItemViewController()
        addEditItemViewController.viewModel = AddEditItemViewModel(itemToEdit: nil)
        addEditItemViewController.delegate = self
        let navigationController = UINavigationController(
            rootViewController: addEditItemViewController
        )
        present(navigationController, animated: true)
    }
}

extension HomeViewController: UITableViewDelegate {
    private func createDiffableDataSource() {
        dataSource = UITableViewDiffableDataSource<HomeTableViewSection, Item>(tableView: itemsTableView) { tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.homeTableViewCellReuseIdentifier) else {
                return UITableViewCell()
            }

            var contentConfiguration = UIListContentConfiguration.accompaniedSidebarSubtitleCell()
            contentConfiguration.text = item.name
            contentConfiguration.secondaryText = item.formattedPrice
            cell.contentConfiguration = contentConfiguration
            cell.accessibilityLabel = "\(item.name), Price: \(item.formattedPrice)"
            if item.hasTag {
                let tagImageConfiguration = UIImage.SymbolConfiguration(textStyle: .body)
                let tagImage = UIImage(systemName: "tag", withConfiguration: tagImageConfiguration)
                let tagImageView = UIImageView(image: tagImage)
                tagImageView.tintColor = .systemGreen
                tagImageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
                cell.accessoryView = tagImageView
            }
            return cell
        }
    }

    private func updateDiffableDataSource(with items: [Item]) {
        var snapshot = NSDiffableDataSourceSnapshot<HomeTableViewSection, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedItem = viewModel.items[indexPath.row]
        let itemDetailsViewController = ItemDetailsViewController()
        itemDetailsViewController.viewModel = ItemDetailsViewModel(item: selectedItem)

        navigationController?.pushViewController(itemDetailsViewController, animated: true)
    }
}

// Necessary because viewWillAppear doesn't get called after AddEditItemViewController's sheet dismissal
extension HomeViewController: AddEditItemViewControllerDelegate {
    func addEditItemViewController(didCreateItem item: Item) {
        viewModel.addItemToItemsArray(item)
    }

    func addEditItemViewController(didUpdateItem item: Item) {
        viewModel.updateItemInItemsArray(item)
    }
}

#Preview {
    let homeViewController = HomeViewController()
    let homeViewModel = HomeViewModel()
    homeViewController.viewModel = homeViewModel
    let navigationController = UINavigationController(rootViewController: homeViewController)
    navigationController.navigationBar.prefersLargeTitles = true
    return navigationController
}
