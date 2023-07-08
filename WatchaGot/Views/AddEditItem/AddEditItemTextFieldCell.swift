//
//  AddEditItemTextFieldCell.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/8/23.
//

import UIKit

final class AddEditItemTextFieldCell: UITableViewCell {
    static let reuseIdentifier = "AddEditItemTextFieldCell"

    lazy var textField = UITextField()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        constrain()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ textFieldType: AddEditItemTextFieldType, forItem itemToEdit: Item?) {
        self.textField.adjustsFontForContentSizeCategory = true
        self.textField.font = .preferredFont(forTextStyle: .body)
        self.textField.borderStyle = .roundedRect
        self.textField.placeholder = textFieldType.placeholder
        self.textField.keyboardType = textFieldType.keyboardType
        self.textField.tag = textFieldType.tag

        if let itemToEdit {
            switch textFieldType {
            case .name:
                self.textField.text = itemToEdit.name
            case .price:
                self.textField.text = String(itemToEdit.price)
            default:
                break
            }
        }
    }

    func constrain() {
        contentView.addConstrainedSubview(textField)

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
        ])
    }
}

#Preview {
    let cell = AddEditItemTextFieldCell()
    cell.configure(.name, forItem: Item.example)
    return cell
}
