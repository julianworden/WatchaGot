//
//  AddEditItemTextFieldCell.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/8/23.
//

import UIKit

final class AddEditItemTextViewCell: UITableViewCell {
    static let reuseIdentifier = "AddEditItemTextViewCell"

    lazy var textView = UITextView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        constrain()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ textViewType: AddEditItemTextFieldType, withItem itemToEdit: Item?) {
        self.textView.layer.borderWidth = 0.75
        self.textView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.35).cgColor
        self.textView.layer.cornerRadius = 6
        self.textView.keyboardType = textViewType.keyboardType
        self.textView.tag = textViewType.tag

        if let itemToEdit {
            self.textView.textColor = .label
            self.textView.font = .preferredFont(forTextStyle: .body)
            self.textView.text = itemToEdit.notes
        } else {
            self.textView.textColor = .secondaryLabel.withAlphaComponent(0.3)
            self.textView.font = .preferredFont(forTextStyle: .body)
            self.textView.text = "Notes"
        }
    }

    func constrain() {
        contentView.addConstrainedSubview(textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
}

#Preview("With Example Item") {
    let cell = AddEditItemTextViewCell()
    cell.configure(.notes, withItem: Item.example)
    return cell
}

#Preview("Without Example Item") {
    let cell = AddEditItemTextViewCell()
    cell.configure(.notes, withItem: nil)
    return cell
}
