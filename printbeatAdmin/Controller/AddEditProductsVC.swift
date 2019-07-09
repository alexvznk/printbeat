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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var selectedCategory: Category!
    var productToEdit: Product?

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        productImg.isUserInteractionEnabled = true
        productImg.addGestureRecognizer(tap)
        
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
    
    @objc func imageTapped() {
        launchImgPicker()
    }
    
    @IBAction func addBtnClicked(_ sender: Any) {
        activityIndicator.startAnimating()
        uploadImageThenDocument()
    }
    
    func uploadImageThenDocument() {
        guard let image = productImg.image,
        let name = productNameTxt.text, !name.isEmpty,
        let price = productPriceTxt.text, !price.isEmpty,
        let priceDouble = Double(price),
        let desc = productDescTxt.text, !desc.isEmpty else {
                simpleAlert(title: "Error", message: "You must fill all fields correctly")
                activityIndicator.stopAnimating()
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
                return
            }
            imageRef.downloadURL(completion: { (url, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    self.simpleAlert(title: "Error", message: "Unable to upload the image")
                    self.activityIndicator.stopAnimating()
                    return
                }
                guard let url = url else { return }
                self.uploadDocument(url: url.absoluteString)
            })
        }
        
    }
    
    func uploadDocument(url: String) {
        var docRef: DocumentReference!
        var product = Product.init(name: productNameTxt.text!, id: "", categoryId: selectedCategory.id, price: (productPriceTxt.text! as NSString).doubleValue, productDescription: productDescTxt.text!, imgUrl: url, timeStamp: Timestamp(), stock: 1)
        
        if let newProduct = productToEdit {
            docRef = Firestore.firestore().collection("products").document(newProduct.id)
            product.id = newProduct.id
        } else {
            docRef = Firestore.firestore().collection("products").document()
            product.id = docRef.documentID
        }
        
        let data = Product.modelToData(product: product)
        docRef.setData(data, merge: true) { (error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "Error", message: "Unable to create a product")
                self.activityIndicator.stopAnimating()
                return
            }
            self.activityIndicator.stopAnimating()
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
}

extension AddEditProductsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func launchImgPicker(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
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
