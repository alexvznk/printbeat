//
//  AddEditCategoryVC.swift
//  printbeatAdmin
//
//  Created by Alex on 7/7/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import UIKit
import Firebase

class AddEditCategoryVC: UIViewController {
    
    var categoryToEdit: Category?
    var products: [Product]?

    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var categoryImg: RoundedImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var removeCancelBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        tap.numberOfTapsRequired = 1
        categoryImg.isUserInteractionEnabled = true
        categoryImg.addGestureRecognizer(tap)
        
        if let category = categoryToEdit {
            navigationItem.title = "Edit category"
            nameTxt.text = category.name
            addBtn.setTitle("Save Changes", for: .normal)
            removeCancelBtn.setTitle("Remove Category", for: .normal)
            if let url = URL(string: category.imgUrl) {
                categoryImg.contentMode = .scaleAspectFill
                categoryImg.kf.setImage(with: url)
            }
        } else {
            navigationItem.title = "Add category"
            addBtn.setTitle("Create Category", for: .normal)
            removeCancelBtn.setTitle("Cancel", for: .normal)
        }
    }
    
    @objc func imageTapped(_ tap: UITapGestureRecognizer) {
        launchImgPicker()    
    }
    
    @IBAction func removeCancelBtnClicked(_ sender: Any) {
        if categoryToEdit != nil {
        
            if products!.isEmpty {
                
                let refreshAlert = UIAlertController(title: "Removing Category", message: "Are you sure you want to remove the category?", preferredStyle: .alert)
                
                refreshAlert.addAction(UIAlertAction(title: "Remove", style: .default, handler: { (action: UIAlertAction!) in
                    self.activityIndicator.startAnimating()
                    self.removeCategory()
                }))
                
                refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                    self.dismiss(animated: true, completion: nil)
                }))
                
                present(refreshAlert, animated: true, completion: nil)
                
            } else {
                simpleAlert(title: "Error. Category is not empty", message: "You must remove all the products before removing a category. If you want to delete everything in once, use the Firebase Console.")
            }
            
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func addSaveBtnClicked(_ sender: Any) {
        activityIndicator.startAnimating()
        addBtn.isEnabled = false
        uploadImageThenDocument()
    }
    
    func removeCategory() {
        Firestore.firestore().collection("categories").document(categoryToEdit!.id).delete { (err) in
            if let err = err {
                self.activityIndicator.stopAnimating()
                self.simpleAlert(title: "Error", message: err.localizedDescription)
            } else {
                self.activityIndicator.stopAnimating()
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func uploadImageThenDocument() {
        guard let image = categoryImg.image,
            let categoryName = nameTxt.text, !categoryName.isEmpty else {
                simpleAlert(title: "Error", message: "You must add category image and name")
                activityIndicator.stopAnimating()
                addBtn.isEnabled = true
                return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.2) else { return }
        let imageRef = Storage.storage().reference().child("/categoryImages/\(categoryName ).jpg")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        imageRef.putData(imageData, metadata: metaData) { (metaData, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "Error", message: "Unable to upload the image")
                self.activityIndicator.stopAnimating()
                self.addBtn.isEnabled = true
                return
            }
            imageRef.downloadURL(completion: { (url, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    self.simpleAlert(title: "Error", message: "Unable to upload the image")
                    self.activityIndicator.stopAnimating()
                    self.addBtn.isEnabled = true
                    return
                }
                
                guard let url = url else { return }
                self.uploadDocument(url: url.absoluteString)
                
            })
        }
        
    }
    
    func uploadDocument(url: String) {
        var docRef: DocumentReference!
        var category: Category
        
        if let newCategory = categoryToEdit {
            docRef = Firestore.firestore().collection("categories").document(newCategory.id)
            category = Category.init(name: nameTxt.text!, id: "", imgUrl: url, timeStamp: categoryToEdit!.timeStamp)
            category.id = newCategory.id
        } else {
            docRef = Firestore.firestore().collection("categories").document()
            category = Category.init(name: nameTxt.text!, id: "", imgUrl: url, timeStamp: Timestamp())
            category.id = docRef.documentID
        }
        
        let data = Category.modelToData(category: category)
        docRef.setData(data, merge: true) { (error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "Error", message: "Unable to create a category")
                self.activityIndicator.stopAnimating()
                self.addBtn.isEnabled = true
                return
            }
            self.activityIndicator.stopAnimating()
            self.addBtn.isEnabled = true
            self.navigationController?.popViewController(animated: true)
            
        }
    }
    
}

extension AddEditCategoryVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func launchImgPicker(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
  
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        categoryImg.contentMode = .scaleAspectFill
        categoryImg.image = image
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
