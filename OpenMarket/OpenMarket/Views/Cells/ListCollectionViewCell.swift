//
//  ListCollectionViewCell.swift
//  OpenMarket
//
//  Created by Kyo, LJ on 2022/11/21.
//

import UIKit

final class ListCollectionViewCell: MainCollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let detailButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.init(systemName: "chevron.right"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    private lazy var priceLabelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [productPriceLabel,
                                                       productSalePriceLabel])
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var stockButtonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [productStockLabel,
                                                       detailButton])
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var topLabelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [productNameLabel,
                                                       stockButtonStackView])
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
}

// MARK: - Constraints
extension ListCollectionViewCell {
    private func setupUI() {
        contentView.layer.applyCustomBorder([.top], color: .gray, width: 1)
        setupView()
    }
    
    private func setupView() {
        contentView.addSubview(indicatorView)
        contentView.addSubview(productImageView)
        contentView.addSubview(topLabelStackView)
        contentView.addSubview(priceLabelStackView)
        
        setupConstraints()
        setupIndicatorViewConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            productImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor,
                                                    multiplier: 0.2),
            productImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            productImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                     constant: -5),
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                      constant: 10),
            
            topLabelStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor,
                                                       constant: -10),
            topLabelStackView.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor,
                                                       constant: 10),
            topLabelStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                        constant: -10),
            
            priceLabelStackView.topAnchor.constraint(equalTo: topLabelStackView.bottomAnchor,
                                                     constant: 2),
            priceLabelStackView.leadingAnchor.constraint(equalTo: topLabelStackView.leadingAnchor)
        ])
    }
    
    private func setupIndicatorViewConstraints() {
        NSLayoutConstraint.activate([
            indicatorView.topAnchor.constraint(equalTo: productImageView.topAnchor),
            indicatorView.leadingAnchor.constraint(equalTo: productImageView.leadingAnchor),
            indicatorView.trailingAnchor.constraint(equalTo: productImageView.trailingAnchor),
            indicatorView.bottomAnchor.constraint(equalTo: productImageView.bottomAnchor)
        ])
    }
}

extension ListCollectionViewCell: ReuseIdentifierProtocol {
    
}
