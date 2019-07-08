//
//  ProductsVC.swift
//  printbeat
//
//  Created by Alex on 5/28/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ProductsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var products = [Product]()
    var category: Category!
    var db: Firestore!
    var listener: ListenerRegistration!

    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ProductCell", bundle: nil), forCellReuseIdentifier: Identifiers.ProductCell)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setProductsListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener.remove()
        products.removeAll()
    }
    
    func setProductsListener() {
        listener = db.products.whereField("categoryId", isEqualTo: category.id).addSnapshotListener({ (snap, error) in
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

    func onDocumentAdded(change: DocumentChange, product: Product) {
        let newIndex = Int(change.newIndex)
        products.insert(product, at: newIndex)
//        tableView.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .fade)
    }
    
    func onDocumentModified(change: DocumentChange, product: Product) {
        let newIndex = Int(change.newIndex)
        let oldIndex = Int(change.oldIndex)
        if newIndex == oldIndex {
            products[newIndex] = product
            tableView.reloadRows(at: [IndexPath(row: newIndex, section: 0)], with: .automatic)
        } else {
            products.remove(at: oldIndex)
            products.insert(product, at: newIndex)
            tableView.moveRow(at: IndexPath(row: oldIndex, section: 0), to: IndexPath(row: newIndex, section: 0))
        }
    }
    
    func onDocumentRemoved(change: DocumentChange) {
        let oldIndex = Int(change.oldIndex)
        products.remove(at: oldIndex)
        tableView.deleteRows(at: [IndexPath(row: oldIndex, section: 0)], with: .automatic)
    }
}


extension ProductsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.ProductCell, for: indexPath) as? ProductCell {
            cell.configureCell(product: products[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ProductDetailVC()
        let selectedProduct = products[indexPath.row]
        vc.product = selectedProduct
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overCurrentContext
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
        present(vc, animated: true, completion: nil)
    }
    
}



//        let product1 = Product.init(name: "Landscape", id: "hgdjhgwf2", category: "Nature", price: 24.99, productDescription: "What a great landscape", imgUrl: "https://images.unsplash.com/photo-1501785888041-af3ef285b470?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=900&q=60", timeStamp: Timestamp(), stock: 0)
//        let product2 = Product.init(name: "City", id: "hgdjhgwf2", category: "Nature", price: 24.99, productDescription: "What a great landscape", imgUrl: "https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=900&q=60", timeStamp: Timestamp(), stock: 0)
//        products.append(product1)
//        products.append(product2)

