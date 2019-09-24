//
//  PurchaseDetailsVC.swift
//  printbeatAdmin
//
//  Created by Alex on 9/19/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import UIKit
import FirebaseFirestore

class PurchaseDetailsVC: UIViewController {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dashedView: UIView!
    @IBOutlet weak var shippingCostLbl: UILabel!
    @IBOutlet weak var processingFeesLbl: UILabel!
    
    var purchase: Purchase!
    var products = [Product]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissPurchase))
        tap.numberOfTapsRequired = 1
        bgView.addGestureRecognizer(tap)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "PurchasedProductCell", bundle: nil), forCellReuseIdentifier: Identifiers.PurchasedProductCell)
        getProducts()
        var yourViewBorder = CAShapeLayer()
        yourViewBorder.strokeColor = #colorLiteral(red: 0.8121692558, green: 0.8179601329, blue: 0.8353327641, alpha: 1)
        yourViewBorder.lineDashPattern = [5, 5]
        yourViewBorder.frame = dashedView.bounds
        yourViewBorder.fillColor = nil
        yourViewBorder.path = UIBezierPath(roundedRect: dashedView.bounds, cornerRadius: 10).cgPath
        dashedView.layer.addSublayer(yourViewBorder)
        configureView()
    }
    
    func configureView() {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        if let shippingCost = currencyFormatter.string(from: purchase.shippingCost as NSNumber),
            let processingFees = currencyFormatter.string(from: purchase.processingFees as NSNumber) {
            shippingCostLbl.text = shippingCost
            processingFeesLbl.text = processingFees
        } else {
            shippingCostLbl.text = ""
            processingFeesLbl.text = ""
        }
    }
    
    func getProducts() {
        Firestore.firestore().collection("purchases").document(purchase.id).collection("products").getDocuments { (snap, error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            for document in snap!.documents {
                let data = document.data()
                let product = Product.init(data: data)
                self.products.append(product)
            }
            
            self.tableView.reloadData()
        }
    }
    
    @objc func dismissPurchase() {
        dismiss(animated: true, completion: nil)
    }

}

extension PurchaseDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.PurchasedProductCell, for: indexPath) as? PurchasedProductCell {
            let product = products[indexPath.row]
            cell.configureCell(product: product)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }


    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    
}
