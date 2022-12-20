//
//  UIComponent+Extension.swift
//  OpenMarket
//
//  Created by Kyo on 2022/12/20.
//

import UIKit

extension UILabel {
    convenience init(font: UIFont, numberOfLines: Int = 1, textColor: UIColor = .black) {
        self.init(frame: .zero)
        self.font = font
        self.numberOfLines = numberOfLines
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension UITextField {
    convenience init(placeholder: String,
                     borderStyle: BorderStyle,
                     returnKeyType: UIReturnKeyType = .done,
                     keyboardType: UIKeyboardType = .default) {
        self.init(frame: .zero)
        self.placeholder = placeholder
        self.borderStyle = borderStyle
        self.keyboardType = keyboardType
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
