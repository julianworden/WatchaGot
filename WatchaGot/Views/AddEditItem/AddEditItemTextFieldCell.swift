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
        self.textField.borderStyle = .roundedRect
        self.textField.placeholder = textField.placeholder
        self.textField.keyboardType = textField.keyboardType
        self.textField.tag = textField.tag
        
        if let itemToEdit {
            switch textFieldType {
            case .name:
                textField.text = itemToEdit.name
            case .price:
                textField.text = String(itemToEdit.price)
            default:
                break
            }
        }
    }

    func constrain() {
        contentView.addConstrainedSubview(textField)

        NSLayoutConstraint.activate([
            textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            textField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

#Preview {
    let cell = AddEditItemTextFieldCell()
    cell.configure(.name, forItem: Item.example)
    return cell
}
