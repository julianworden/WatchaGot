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

    func configure(_ textViewType: AddEditItemTextFieldType) {
        self.textView.layer.borderWidth = 0.75
        self.textView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.35).cgColor
        self.textView.layer.cornerRadius = 6
        self.textView.font = .systemFont(ofSize: 16)

        self.textView.keyboardType = textViewType.keyboardType
        self.textView.tag = textViewType.tag
    }

    func constrain() {
        contentView.addConstrainedSubview(textView)

        NSLayoutConstraint.activate([
            textView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            textView.heightAnchor.constraint(equalToConstant: 85)
        ])
    }
}

#Preview {
    let cell = AddEditItemTextViewCell()
    cell.configure(.notes)
    return cell
}
