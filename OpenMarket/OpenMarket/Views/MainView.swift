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
            collectionView.reloadData()
            changeLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        setupUI()
        registerCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["LIST", "GRID"])
        control.selectedSegmentIndex = 1
        control.layer.borderWidth = 1
        control.layer.borderColor = UIColor.blue.cgColor
        control.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.blue],
                                       for: UIControl.State.normal)
        control.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white],
                                       for: UIControl.State.selected)
        control.selectedSegmentTintColor = .blue
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    let listLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        let collectionCellWidth = UIScreen.main.bounds.width
        layout.itemSize  = CGSize(width: collectionCellWidth, height: collectionCellWidth)
        return layout
    }()
    
    let gridLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        let collectionCellWidth = UIScreen.main.bounds.width / 2 - 20
        layout.itemSize  = CGSize(width: collectionCellWidth, height: collectionCellWidth)
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: gridLayout)
        return collectionView
    }()
    
    
    private func registerCell() {
        collectionView.register(ListCollectionViewCell.self,
                                forCellWithReuseIdentifier: ListCollectionViewCell.reuseIdentifier)
        collectionView.register(GridCollectionViewCell.self,
                                forCellWithReuseIdentifier: GridCollectionViewCell.reuseIdentifier)
    }
    
    private func changeLayout() {
        switch layoutStatus {
        case .list:
            collectionView.collectionViewLayout = listLayout
        case .grid:
            collectionView.collectionViewLayout = gridLayout
        }
    }
}

// MARK: - UI Constraint
extension MainView {
    private func setupUI() {
        self.addSubview(segmentedControl)
        self.addSubview(collectionView)
    }
}
