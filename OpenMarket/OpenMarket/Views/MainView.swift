//
//  MainView.swift
//  OpenMarket
//
//  Created by Kyo, LJ on 2022/11/21.
//

import UIKit

enum CollectionStatus: Int {
    case list
    case grid
}

final class MainView: UIView {
    var layoutStatus: CollectionStatus = .list {
        didSet {
            collectionView.collectionViewLayout = changeCompositionalLayout(layoutStatus: layoutStatus)
            scrollViewTop()
            collectionView.reloadData()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        setupUI()
        registerCell()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["LIST", "GRID"])
        control.selectedSegmentIndex = 0
        control.layer.borderWidth = 1
        control.layer.borderColor = UIColor.systemBlue.cgColor
        control.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemBlue],
                                       for: UIControl.State.normal)
        control.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white],
                                       for: UIControl.State.selected)
        control.selectedSegmentTintColor = .systemBlue
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: changeCompositionalLayout(layoutStatus: .list))
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private func changeCompositionalLayout(layoutStatus: CollectionStatus) -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        switch layoutStatus {
        case .list:
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalHeight(1 / 11))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            let layout = UICollectionViewCompositionalLayout(section: section)

            return layout
        case .grid:
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalHeight(1 / 3))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                           subitem: item,
                                                           count: 2)
            let spacing = CGFloat(10)
            group.interItemSpacing = .fixed(spacing)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 10
            
            let layout = UICollectionViewCompositionalLayout(section: section)
            return layout
        }
    }
    
    private func registerCell() {
        collectionView.register(ListCollectionViewCell.self,
                                forCellWithReuseIdentifier: ListCollectionViewCell.reuseIdentifier)
        collectionView.register(GridCollectionViewCell.self,
                                forCellWithReuseIdentifier: GridCollectionViewCell.reuseIdentifier)
    }
    
    private func scrollViewTop(){
        self.layoutIfNeeded()
        collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
}

// MARK: - UI Constraint
extension MainView {
    private func setupUI() {
        self.addSubview(segmentedControl)
        self.addSubview(collectionView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor,
                                                    constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor,
                                                     constant: -10)
        ])
    }
}
