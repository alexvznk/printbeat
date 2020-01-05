//
//  AddEditProductsVC.swift
//  printbeatAdmin
//
//  Created by Alex on 7/8/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import UIKit
import Firebase

class AddEditProductsVC: UIViewController {
    
    @IBOutlet weak var productNameTxt: UITextField!
    @IBOutlet weak var productPriceTxt: UITextField!
    @IBOutlet weak var productDescTxt: UITextView!
    @IBOutlet weak var productImg: RoundedImageView!
    @IBOutlet weak var addBtn: RoundedButton!
    @IBOutlet weak var RemoveCancelBtn: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var selectedCategory: Category!
    var productToEdit: Product?

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        productImg.isUserInteractionEnabled = true
        productImg.addGestureRecognizer(tap)
        setNavTitleAndButtons()
        productDescTxt.layer.cornerRadius = 15
        productDescTxt.textContainerInset = UIEdgeInsets(top: 8,left: 8, bottom: 8,right: 8)
        if let product = productToEdit {
            productNameTxt.text = product.name
            productPriceTxt.text = String(product.price)
            productDescTxt.text = product.productDescription
            if let url = URL(string: product.imgUrl) {
                productImg.contentMode = .scaleAspectFill
                productImg.kf.setImage(with: url)
            }
            addBtn.setTitle("Save Changes", for: .normal)
        }
    }
    
    
    func setNavTitleAndButtons() {
        if productToEdit != nil {
            navigationItem.title = "Edit product"
            RemoveCancelBtn.setTitle("Remove Product", for: .normal)
        } else {
            navigationItem.title = "Add product"
            RemoveCancelBtn.setTitle("Cancel", for: .normal)
        }
    }
    
    @objc func imageTapped() {
        launchImgPicker()
    }
    
    @IBAction func removeCancelBtnClicked(_ sender: Any) {
        if productToEdit != nil {
            let refreshAlert = UIAlertController(title: "Removing Product", message: "Are you sure you want to remove the product?", preferredStyle: .alert)

            refreshAlert.addAction(UIAlertAction(title: "Remove", style: .default, handler: { (action: UIAlertAction!) in
                self.activityIndicator.startAnimating()
                self.removeDocument()
            }))

            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                self.dismiss(animated: true, completion: nil)
            }))

            present(refreshAlert, animated: true, completion: nil)

        } else {
            navigationController?.popViewController(animated: true)
        }
            
    }
    
    
    @IBAction func addBtnClicked(_ sender: Any) {
        activityIndicator.startAnimating()
        uploadImageThenDocument()
        addBtn.isEnabled = false
    }
    
    func removeDocument() {
        Firestore.firestore().collection("products").document(productToEdit!.id).delete { (err) in
            if let err = err {
                self.simpleAlert(title: "Error", message: err.localizedDescription)
                self.activityIndicator.stopAnimating()
            } else {
                self.activityIndicator.stopAnimating()
                let i = self.navigationController?.viewControllers.firstIndex(of: self)
                let previousViewController = self.navigationController?.viewControllers[i!-1]
                if let previous = previousViewController as? AdminProductsVC {
                    previous.tableView.reloadData()
                }
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func uploadImageThenDocument() {
        guard let image = productImg.image,
        let name = productNameTxt.text, !name.isEmpty,
        let price = productPriceTxt.text, !price.isEmpty,
        let desc = productDescTxt.text, !desc.isEmpty else {
                simpleAlert(title: "Error", message: "You must fill all fields correctly")
                activityIndicator.stopAnimating()
                addBtn.isEnabled = true
                return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.2) else { return }
        let imageRef = Storage.storage().reference().child("/productImages/\(name).jpg")
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
        var product: Product
        
        if let newProduct = productToEdit {
            docRef = Firestore.firestore().collection("products").document(newProduct.id)
            product = Product.init(name: productNameTxt.text!, id: "", categoryId: selectedCategory.id, price: (productPriceTxt.text! as NSString).doubleValue, productDescription: productDescTxt.text!, imgUrl: url, timeStamp: productToEdit!.timeStamp, stock: 1)
            product.id = newProduct.id
        } else {
            docRef = Firestore.firestore().collection("products").document()
            product = Product.init(name: productNameTxt.text!, id: "", categoryId: selectedCategory.id, price: (productPriceTxt.text! as NSString).doubleValue, productDescription: productDescTxt.text!, imgUrl: url, timeStamp: Timestamp(), stock: 1)
            product.id = docRef.documentID
        }
        
        let data = Product.modelToData(product: product)
        docRef.setData(data, merge: true) { (error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "Error", message: "Unable to create a product")
                self.activityIndicator.stopAnimating()
                self.addBtn.isEnabled = true
                return
            }
            self.activityIndicator.stopAnimating()
            self.navigationController?.popViewController(animated: true)
            self.addBtn.isEnabled = true
        }
        
    }
    
}

extension AddEditProductsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func launchImgPicker(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
        view.endEditing(true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        productImg.contentMode = .scaleAspectFill
        productImg.image = image
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
