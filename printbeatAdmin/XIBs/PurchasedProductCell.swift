//
//  PurchasedProductCell.swift
//  printbeatAdmin
//
//  Created by Alex on 9/20/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import UIKit
import Kingfisher

class PurchasedProductCell: UITableViewCell {
    @IBOutlet weak var productImg: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(product: Product) {
        
        if let url = URL(string: product.imgUrl) {
            let options: KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.1))]
            productImg.kf.indicatorType = .activity
            productImg.kf.setImage(with: url, options: options)
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let price = formatter.string(from: product.price as NSNumber) {
            productPrice.text = price
        } else {
            productPrice.text = String(product.price)
        }
        
        productName.text = product.name
    }

}
