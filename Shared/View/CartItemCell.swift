//
//  CartItemCell.swift
//  printbeat
//
//  Created by Alex on 9/8/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import UIKit

protocol CartItemDelegate: class {
    func removeItem(product: Product)
}

class CartItemCell: UITableViewCell {

    @IBOutlet weak var productImg: RoundedImageView!
    @IBOutlet weak var productTitleLbl: UILabel!
    @IBOutlet weak var removeItemBtn: UIButton!
    @IBOutlet weak var productPriceLbl: UILabel!
    
  
    private var item: Product!
    weak var delegate: CartItemDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(product: Product, delegate: CartItemDelegate) {
        self.delegate = delegate
        self.item = product
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        
        if let price = formatter.string(from: product.price as NSNumber) {
            productPriceLbl.text = price
        }
        
        productTitleLbl.text = product.name
        
        if let url = URL(string: product.imgUrl) {
            productImg.kf.setImage(with: url)
        }
    }
    
    @IBAction func removeBtnClicked(_ sender: Any) {
        delegate?.removeItem(product: item)
    }
    
    
}
