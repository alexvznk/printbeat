//
//  FavoritesVC.swift
//  printbeat
//
//  Created by Alex on 7/17/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import UIKit
import FirebaseFirestore

class FavoritesVC: ProductsVC {
    
    @IBOutlet weak var noFavsLbl: UILabel!
    
    
    var favoritesListener: ListenerRegistration!

    override func viewDidLoad() {
        super.viewDidLoad()
        noFavsLbl.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setFavoritesListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        favoritesListener.remove()
    }
    
    func setFavoritesListener() {
        favoritesListener = db.collection("products").addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            snap?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                let product = Product.init(data: data)
                
                switch change.type {
                case .added:
                    return
                case .modified:
                self.db.collection("users").document(UserService.user.id).collection("favorites").document(product.id).setData(data)
                    
                case .removed:
                self.db.collection("users").document(UserService.user.id).collection("favorites").document(product.id).delete()
                    UserService.favorites.removeAll{$0 == product}

                }
            })
        })
    }
    
    override func setProductsListener() {
        listener = db.collection("users").document(UserService.user.id).collection("favorites").addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            snap?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                let product = Product.init(data: data)
                
                switch change.type {
                case .added:
                    self.onDocumentAdded(change: change, product: product)
                    self.noFavsLbl.isHidden = true
                    self.tableView.reloadData()
                case .modified:
                    self.onDocumentModified(change: change, product: product)
                case .removed:
                    self.onDocumentRemoved(change: change)
                    if UserService.favorites.isEmpty {
                        self.noFavsLbl.isHidden = false
                    }
                }
                
            })
            
        })
    }

}
