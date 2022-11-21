//
//  CollectionViewCell.swift
//  OpenMarket
//
//  Created by Kyo, LJ on 2022/11/21.
//

import UIKit

class GridCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let productNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let productPriceLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let productSalePriceLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let productStockLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let productStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()    
}

// MARK: - Constraints
extension GridCollectionViewCell {
    
    func setupUI() {
        setupStackView()
        setupPriceLabel()
    }
    
    func setupStackView() {
        productStackView.addSubview(productImageView)
        productStackView.addSubview(productNameLabel)
        contentView.addSubview(productStackView)
        setupStackViweConstraints()
    }
    
    func setupPriceLabel(){
        // 만약 할인아닐 경우
        contentView.addSubview(productPriceLabel)
        setupBottomLabelConstraints()
        // 해당하는 setupConstraints() 호출필요
        // 할인한다면
        //        contentView.addSubview(productSalePriceLabel)
        // 해당하는 setupConstraints() 호출필요
    }
    
    func setupStackViweConstraints() {
        NSLayoutConstraint.activate([
            productStackView.topAnchor.constraint(
                equalTo: contentView.topAnchor, constant: 10),
            productStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 10),
            productStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -10),
        ])
    }
    
    
    func setupBottomLabelConstraints() {
        NSLayoutConstraint.activate([
            productPriceLabel.topAnchor.constraint(equalTo: productStackView.bottomAnchor, constant: 15),
            productPriceLabel.bottomAnchor.constraint(equalTo: productStockLabel.topAnchor, constant: 15),
            productStockLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    
}

extension GridCollectionViewCell: ReuseIdentifierProtocol {
    
}


extension UIImageView {
    func loadImage(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
        }
    }
}
