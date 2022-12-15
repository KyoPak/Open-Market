//
//  CollectionViewCell.swift
//  OpenMarket
//
//  Created by Kyo, LJ on 2022/11/21.
//

import UIKit

final class GridCollectionViewCell: MainCollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupUIComponent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var labelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [productPriceLabel,
                                                       productSalePriceLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var productStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [productNameLabel,
                                                       labelStackView,
                                                       productStockLabel])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private func setupUIComponent() {
        productImageView.contentMode = .scaleAspectFill
        
        productNameLabel.textAlignment = .center
        productNameLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        
        productPriceLabel.font = UIFont.preferredFont(forTextStyle: .body)
        productSalePriceLabel.font = UIFont.preferredFont(forTextStyle: .body)
        productStockLabel.font = UIFont.preferredFont(forTextStyle: .body)
    }
}

// MARK: - Constraints
extension GridCollectionViewCell {
    private func setupUI() {
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 10
        contentView.layer.borderColor = UIColor.gray.cgColor
        setupView()
    }
    
    private func setupView() {
        contentView.addSubview(productImageView)
        contentView.addSubview(productStackView)
        contentView.addSubview(indicatorView)
        setupStackViewConstraints()
        setupIndicatorConstraints()
    }

    private func setupStackViewConstraints() {
        NSLayoutConstraint.activate([
            productImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor,
                                                    multiplier: 0.4),
            productImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor,
                                                     multiplier: 0.4),
            
            productNameLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor,
                                                    multiplier: 0.9),
            
            productImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            productImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            productImageView.bottomAnchor.constraint(equalTo: productStackView.topAnchor,
                                                     constant: -10),
            
            productStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                     constant: -10),
            productStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    private func setupIndicatorConstraints() {
        NSLayoutConstraint.activate([
            indicatorView.topAnchor.constraint(equalTo: productImageView.topAnchor),
            indicatorView.bottomAnchor.constraint(equalTo: productImageView.bottomAnchor),
            indicatorView.leadingAnchor.constraint(equalTo: productImageView.leadingAnchor),
            indicatorView.trailingAnchor.constraint(equalTo: productImageView.trailingAnchor)
        ])
    }
}

extension GridCollectionViewCell: ReuseIdentifierProtocol {
    
}
