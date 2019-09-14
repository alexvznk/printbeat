//
//  ProductDetailVC.swift
//  printbeat
//
//  Created by Alex on 6/2/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import UIKit

class ProductDetailVC: UIViewController {

    @IBOutlet weak var productImg: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet weak var bgView: UIVisualEffectView!
    
    var product: Product!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        productTitle.text = product.name
        productDescription.text = product.productDescription
        if let url = URL(string: product.imgUrl) {
            productImg.kf.setImage(with: url)
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let price = formatter.string(from: product.price as NSNumber) {
            productPrice.text = price
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissProduct))
        tap.numberOfTapsRequired = 1
        bgView.addGestureRecognizer(tap)
    }
    
    @objc func dismissProduct() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func addToCartClicked(_ sender: Any) {
        StripeCart.addItemToCart(item: product)
        let alert = UIAlertController(title: "", message: "Added to cart ✔️", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        let when = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @IBAction func keepShoppingClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
