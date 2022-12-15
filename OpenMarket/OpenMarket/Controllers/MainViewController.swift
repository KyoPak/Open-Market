//
//  OpenMarket - ViewController.swift
//  Created by yagom.
//  Copyright © yagom. All rights reserved.
//

import UIKit

final class MainViewController: UIViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Product>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Product>
    
    private let networkManager = NetworkManager()
    private let mainView = MainView()
    
    private lazy var dataSource = makeDataSource()
    private var productData: [Product] = []
    private var pageCount = Constant.pageNumberUnit.rawValue
    private var scrollState = ScrollState.idle
    
    enum Section {
        case main
    }
    
    private enum Constant: Int {
        case pageNumberUnit = 1
        case itemsPerPage = 15
    }
    
    private enum ScrollState {
        case idle
        case isLoading
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        clearAll()
        setupData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = mainView
        setupNavigationBar()
        setupSegmentedControlTarget()
        mainView.collectionView.delegate = self
        applySnapshot()
    }
    
    private func clearAll() {
        productData.removeAll()
        pageCount = Constant.pageNumberUnit.rawValue
        scrollState = ScrollState.idle
    }
    
    private func setupData() {
        defer {
            pageCount += Constant.pageNumberUnit.rawValue
            self.scrollState = .idle
        }
        
        guard scrollState == .idle else { return }
        scrollState = .isLoading
        
        let itemsPerPage = Constant.itemsPerPage.rawValue
        guard let productListURL = NetworkRequest.productList(pageNo: pageCount,
            itemsPerPage: itemsPerPage).requestURL else { return }
        
        networkManager.fetchData(to: productListURL, dataType: ProductPage.self) { result in
            switch result {
            case .success(let data):
                self.productData += data.pages
                DispatchQueue.main.async {
                    self.applySnapshot()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    if error == .last {
                        self.showAlert(alertText: error.description,
                                       alertMessage: "마지막 상품입니다.",
                                       completion: nil)
                    }
                    self.showAlert(alertText: error.description,
                                   alertMessage: "오류가 발생했습니다.",
                                   completion: nil)
                }
            }
        }
    }
}

// MARK: - DiffableDataSource and Snapshot
extension MainViewController {
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: mainView.collectionView) { collectionView, indexPath, product in
            
            var cell: MainCollectionViewCell
            
            switch self.mainView.layoutStatus {
            case .list:
                guard let listCell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCollectionViewCell.reuseIdentifier,
                                                                        for: indexPath) as? ListCollectionViewCell else {
                    self.showAlert(alertText: NetworkError.data.description,
                                   alertMessage: "오류가 발생했습니다.",
                                   completion: nil)
                    let errorCell = UICollectionViewCell()
                    return errorCell
                }
                cell = listCell
            case .grid:
                guard let gridCell = collectionView.dequeueReusableCell(withReuseIdentifier: GridCollectionViewCell.reuseIdentifier,
                                                                        for: indexPath) as?
                GridCollectionViewCell else {
                    self.showAlert(alertText: NetworkError.data.description,
                                   alertMessage: "오류가 발생했습니다.",
                                   completion: nil)
                    let errorCell = UICollectionViewCell()
                    return errorCell
                }
                cell = gridCell
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
    
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(productData)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences, completion: nil)
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
        } else {
            mainView.layoutStatus = .grid
        }
    }
}

// MARK: - Extension UICollectionView
extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let data = dataSource.itemIdentifier(for: indexPath) else { return }
        let detailViewController = DetailViewController(id: data.id,
                                                        data: data)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let collectionViewContentSizeY = scrollView.contentSize.height
        let contentOffsetY = scrollView.contentOffset.y
        let heightRemainBottomHeight = collectionViewContentSizeY - contentOffsetY
        let frameHeight = scrollView.frame.size.height
        
        if heightRemainBottomHeight < frameHeight {
            self.setupData()
        }
    }
}
