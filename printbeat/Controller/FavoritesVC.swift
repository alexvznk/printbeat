//
//  FavoritesVC.swift
//  printbeat
//
//  Created by Alex on 7/17/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import UIKit

class FavoritesVC: ProductsVC {

    override func viewDidLoad() {
        super.viewDidLoad()
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
                    self.tableView.reloadData()
                case .modified:
                    self.onDocumentModified(change: change, product: product)
                case .removed:
                    self.onDocumentRemoved(change: change)
                }
                
            })
            
        })
    }

}
