//
//  AddViewController.swift
//  OpenMarket
//
//  Created by Kyo, LJ on 2022/11/24.
//

import UIKit
import PhotosUI

final class AddViewController: ProductViewController {
    private let picker = UIImagePickerController()
    private let maxImageNumber = 5
    private var uploadProductView = UploadProductView()
    
    override var showView: UploadProductView {
        return uploadProductView
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar(title: "상품등록")
        self.view = showView
        showView.collectionView.delegate = self
        showView.collectionView.dataSource = self
        picker.delegate = self
    }
}

// MARK: - Override doneButtonTapped
extension AddViewController {
    override func doneButtonTapped() {
        let result = setupData()
        switch result {
        case .success(let data):
            guard let postURL = NetworkRequest.postData.requestURL else { return }
            networkManager.postData(to: postURL,
                                    newData: (productData: data, images: cellImages)) { result in
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        self.showAlert(alertText: Constant.uploadSuccessText.rawValue,
                                       alertMessage: Constant.uploadSuccessMessage.rawValue) {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.showAlert(alertText: error.description,
                                       alertMessage: Constant.failureMessage.rawValue,
                                       completion: nil)
                    }
                }
            }
        case .failure(let error):
            self.showAlert(alertText: error.description,
                           alertMessage: Constant.confirmMessage.rawValue,
                           completion: nil)
        }
    }
}

// MARK: - ImageCollectionViewCellDelegate
extension AddViewController: ImageCollectionViewCellDelegate {
    func imageCollectionViewCell(_ isShowPicker: Bool) {
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        
        let alert = UIAlertController(title: "사진선택",
                                      message: "업로드할 사진을 선택해주세요.",
                                      preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let leftAction = UIAlertAction(title: "원본사진", style: .default) { _ in
            self.picker.allowsEditing = false
            self.present(self.picker, animated: true, completion: nil)
        }
        
        let rightAction = UIAlertAction(title: "편집사진", style: .default) { _ in
            self.picker.allowsEditing = true
            self.present(self.picker, animated: true, completion: nil)
        }
        
        alert.addAction(leftAction)
        alert.addAction(rightAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Extension UIImagePickerController
extension AddViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.editedImage] as? UIImage {
            cellImages.append(image)
        } else {
            if let image = info[.originalImage] as? UIImage {
                cellImages.append(image)
            }
        }
        
        self.showView.collectionView.reloadData()
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Extension UICollectionView
extension AddViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return cellImages.count < maxImageNumber ? cellImages.count + 1 : maxImageNumber
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AddProductCollectionViewCell.reuseIdentifier,
            for: indexPath) as? AddProductCollectionViewCell
        else {
            self.showAlert(alertText: NetworkError.data.description,
                           alertMessage: "오류가 발생했습니다.",
                           completion: nil)
            let errorCell = UICollectionViewCell()
            return errorCell
        }
        cell.buttonDelegate = self
        
        if indexPath.item == cellImages.count {
            let view = cell.createButton()
            cell.stackView.addArrangedSubview(view)
        } else {
            let view = cell.createImageView()
            view.image = cellImages[indexPath.item]
            cell.stackView.addArrangedSubview(view)
        }

        return cell
    }
}
