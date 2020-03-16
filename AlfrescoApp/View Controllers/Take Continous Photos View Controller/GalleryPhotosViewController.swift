/*******************************************************************************
* Copyright (C) 2005-2014 Alfresco Software Limited.
*
* This file is part of the Alfresco Mobile iOS App.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*  http://www.apache.org/licenses/LICENSE-2.0
*
*  Unless required by applicable law or agreed to in writing, software
*  distributed under the License is distributed on an "AS IS" BASIS,
*  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*  See the License for the specific language governing permissions and
*  limitations under the License.
******************************************************************************/

import UIKit
import AVFoundation

@objc protocol MultiplePhotosUploadDelegate: class {
    func finishUploadGallery(documents: [AlfrescoDocument])
}

@objc class GalleryPhotosViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameDefaultFilesLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    
    @IBOutlet weak var selectAllButton: UIButton!
    @IBOutlet weak var takeMorePhotosButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var collectionViewTraillingConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewLeadingConstraint: NSLayoutConstraint!
    
    @objc weak var delegate: MultiplePhotosUploadDelegate?
    @objc var model: GalleryPhotosModel!
    
    var distanceBetweenCells: CGFloat = 10.0
    var cellPerRow: CGFloat = 3.0
    
    var mbprogressHUD: MBProgressHUD!
    
    //MARK: - Cycle Life View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.delegate = self
        
        nameTextField.text = model.imagesName
        nameTextField.placeholder = model.defaultFilesPlaceholderNameText
        nameDefaultFilesLabel.text = model.defaultFilesNameText
  
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        self.title = "Upload photos"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: model.uploadButtonText , style: .done, target: self, action: #selector(uploadButtonTapped))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: model.cancelButtonText , style: .plain, target: self, action: #selector(cancelButtonTapped))
        
        selectAllButton.setTitle(model.selectAllButtonText, for: .normal)
        
        make(button: selectAllButton, enable: !model.isAllPhoto(selected: true))
        make(button: navigationItem.rightBarButtonItem, enable: !model.isAllPhoto(selected: false))
        make(button: navigationItem.leftBarButtonItem, enable: true)

    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - IBActions
    @IBAction func infoButtonTapped(_ sender: Any) {
        showAlertInfoNaming()
    }
    
    @objc func cancelButtonTapped() {
        if model.cameraPhotos.count == 0 {
            self.dismiss(animated: true, completion: nil)
        } else{
            showAlertCancelUpload()
        }
    }
    
     @objc func uploadButtonTapped() {
        if model.shouldShowAlertCellularUpload() {
            showAlertCellularUpload()
        } else {
            uploadPhotos()
        }
    }
    
    @IBAction func selectButtonTapped(_ sender: Any) {
        model.selectAllPhotos()
        collectionView.reloadData()
        make(button: selectAllButton, enable: false)
        make(button: navigationItem.rightBarButtonItem, enable: !model.isAllPhoto(selected: false))
    }
    
    @IBAction func takeMorePhotosButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "showCamera", sender: nil)
    }
    
    //MARK: - Utils
    
    func showAlertCancelUpload() {
        let alert = UIAlertController(title: model.unsavedContentTitleText, message: model.unsavedContentText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: model.dontUploadButtonText, style: .cancel, handler: { action in
            if self.model.retryMode == true {
                self.delegate?.finishUploadGallery(documents: self.model.documents)
            }
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: model.uploadButtonText, style: .default, handler: { action in
            self.uploadButtonTapped()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertCellularUpload() {
        let alert = UIAlertController(title: model.uploadCellularTitleText, message: model.uploadCellularDescriptionText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: model.dontUploadButtonText, style: .cancel, handler: { action in
        }))
        alert.addAction(UIAlertAction(title: model.uploadButtonText, style: .default, handler: { action in
            self.uploadPhotos()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertInfoNaming() {
        let alert = UIAlertController(title: "", message: model.infoNamingPhotosText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: model.okText, style: .default, handler: { action in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func make(button: UIButton, enable: Bool) {
        button.isUserInteractionEnabled = enable
        button.setTitleColor((enable) ? UIColor.blue : UIColor.gray, for: .normal)
    }
    
    func make(button: UIBarButtonItem?, enable: Bool) {
        button?.isEnabled = enable
    }
    
    func uploadPhotos() {
        self.view.isUserInteractionEnabled = false
        make(button: navigationItem.leftBarButtonItem, enable: false)
        mbprogressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        mbprogressHUD.mode = .annularDeterminate
        mbprogressHUD.label.text = model.photosRemainingToUploadText()
        model.uploadPhotosWithContentStream()
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCamera" {
            let cvc = segue.destination as! CameraViewController
            cvc.delegate = self
            cvc.model = model
        }
    }
}

//MARK: - CameraDelegate

extension GalleryPhotosViewController: CameraDelegate {
    func closeCamera(savePhotos: Bool, photos: [CameraPhoto], model: GalleryPhotosModel) {
        if savePhotos {
            model.cameraPhotos.append(contentsOf: photos)
            collectionView.reloadData()
        }
        make(button: navigationItem.rightBarButtonItem, enable: !model.isAllPhoto(selected: false))
        make(button: selectAllButton, enable: !model.isAllPhoto(selected: true))
    }
}

//MARK: - GalleryPhotos Delegate

extension GalleryPhotosViewController: GalleryPhotosDelegate {

    func uploading(photo: CameraPhoto, with progress: Float) {
        mbprogressHUD.progress = progress
    }
    
    func errorUploading(photo: CameraPhoto, error: NSError?) {
        mbprogressHUD.label.text = model.photosRemainingToUploadText()
    }
    
    func successUploading(photo: CameraPhoto) {
        mbprogressHUD.label.text = model.photosRemainingToUploadText()
        mbprogressHUD.progress = 1.0
    }
    
    func finishUploadPhotos() {
        self.delegate?.finishUploadGallery(documents: model.documents)
        self.dismiss(animated: true, completion: nil)
    }
    
    func retryMode() {
        mbprogressHUD.hide(animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: model.retryButtonText , style: .done, target: self, action: #selector(uploadButtonTapped))
        make(button: navigationItem.leftBarButtonItem, enable: true)
        collectionView.reloadData()
    }
}

//MARK: - UITextField Delegate

extension GalleryPhotosViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let name = textField.text {
            model.imagesName = name
        }
    }
}

//MARK: - UIColectionView Delegates

extension GalleryPhotosViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.cameraPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell",
                                                      for: indexPath) as! PhotoCollectionViewCell
        cell.photo.image = model.cameraPhotos[indexPath.row].getImage()
        cell.selectedView.isHidden = !model.cameraPhotos[indexPath.row].selected
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        model.cameraPhotos[indexPath.row].selected = !model.cameraPhotos[indexPath.row].selected
        collectionView.reloadItems(at: [indexPath])
        make(button: selectAllButton, enable: !model.isAllPhoto(selected: true))
        make(button: navigationItem.rightBarButtonItem, enable: !model.isAllPhoto(selected: false))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let margin = collectionViewLeadingConstraint.constant + collectionViewTraillingConstraint.constant
        let minSize = min(self.view.bounds.width, self.view.bounds.height) - margin
        let yourWidth = minSize / cellPerRow - distanceBetweenCells * cellPerRow - distanceBetweenCells
        let yourHeight = yourWidth

        return CGSize(width: yourWidth, height: yourHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return distanceBetweenCells
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return distanceBetweenCells
    }
}
