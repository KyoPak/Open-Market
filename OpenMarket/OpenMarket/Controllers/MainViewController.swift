//
//  OpenMarket - ViewController.swift
//  Created by yagom.
//  Copyright © yagom. All rights reserved.
//

import UIKit

final class MainViewController: UIViewController {
    enum Section {
        case main
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Product>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Product>
    
    private lazy var dataSource = makeDataSource()
    
    let networkManager = NetworkManager()
    let mainView = MainView()
    var productData: [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = mainView
        setupNavigationBar()
        setupSegmentedControlTarget()
        setupData()
    }
    
    private func setupData() {
        guard let productListURL = NetworkRequest.productList.requestURL else {
            return
        }
        
        networkManager.fetchData(to: productListURL, dataType: ProductPage.self) { result in
            switch result {
            case .success(let data):
                self.productData = data.pages
                DispatchQueue.main.async {
                    self.applySnapshot(animatingDifferences: false)
                    //self.mainView.collectionView.reloadData()
                }
            case .failure(let error):
                print(error.description)
            }
        }
    }
}

// MARK: - Diffable DataSource, Snapshot
extension MainViewController {

    private func makeDataSource() -> DataSource {
        setupData()
        
        switch mainView.layoutStatus {
        case .list:
            let dataSource = DataSource(
                collectionView: mainView.collectionView) { collectionView, indexPath, product in
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: ListCollectionViewCell.reuseIdentifier,
                        for: indexPath) as? ListCollectionViewCell else {
                        let errorCell = UICollectionViewCell()
                        return errorCell
                    }
                    
                    cell.indicatorView.startAnimating()
                    cell.setupData(with: product)
                    
                    let cacheKey = NSString(string: product.thumbnail)
                    if let cachedImage = ImageCacheManager.shared.object(forKey: cacheKey) {
                        cell.uploadImage(cachedImage)
                        return cell
                    }
                    
                    self.networkManager.fetchImage(with: product.thumbnail) { image in
                        DispatchQueue.main.async {
                            if indexPath == collectionView.indexPath(for: cell) {
                                ImageCacheManager.shared.setObject(image, forKey: cacheKey)
                                cell.uploadImage(image)
                            }
                        }
                    }
                    return cell
                }
            return dataSource

        case .grid:
            let dataSource = DataSource(
                collectionView: mainView.collectionView) { collectionView, indexPath, product in
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: GridCollectionViewCell.reuseIdentifier,
                        for: indexPath) as? GridCollectionViewCell else {
                        let errorCell = UICollectionViewCell()
                        return errorCell
                    }
                    
                    cell.indicatorView.startAnimating()
                    cell.setupData(with: product)
                    
                    let cacheKey = NSString(string: product.thumbnail)
                    if let cachedImage = ImageCacheManager.shared.object(forKey: cacheKey) {
                        cell.uploadImage(cachedImage)
                        return cell
                    }
                    
                    self.networkManager.fetchImage(with: product.thumbnail) { image in
                        DispatchQueue.main.async {
                            if indexPath == collectionView.indexPath(for: cell) {
                                ImageCacheManager.shared.setObject(image, forKey: cacheKey)
                                cell.uploadImage(image)
                            }
                        }
                    }
                    return cell
                }
            return dataSource
        }
    }

    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(productData)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

// MARK: - UI & UIAction
extension MainViewController {
    private func setupNavigationBar() {
        self.navigationItem.titleView = mainView.segmentedControl
        let appearance = UINavigationBarAppearance()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        let addBarButtonItem = UIBarButtonItem(title: "+",
                                               style: .plain,
                                               target: self,
                                               action: #selector(addProduct))
        self.navigationItem.rightBarButtonItem = addBarButtonItem
    }
    
    @objc func addProduct() {
        let addViewController = AddViewController()
        addViewController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(addViewController, animated: true)
    }
    
    private func setupSegmentedControlTarget() {
        mainView.segmentedControl.addTarget(self,
                                            action: #selector(segmentedControlValueChanged),
                                            for: .valueChanged)
    }
    
    @objc func segmentedControlValueChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            
            mainView.layoutStatus = .list
            self.dataSource = makeDataSource()
        } else {
            
            mainView.layoutStatus = .grid
            self.dataSource = makeDataSource()
        }
    }
}
