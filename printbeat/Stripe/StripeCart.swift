//
//  StripeCart.swift
//  printbeat
//
//  Created by Alex on 9/8/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import Foundation

let StripeCart = _StripeCart()

final class _StripeCart {
    var cartItems = [Product]()
    private let stripeCreditCardCut = 0.029
    private let flatFeeCents = 30
    var shippingFees = 0
    
    var subtotal: Int {
        var amount = 0
        for item in cartItems {
            let priceCents = Int(item.price * 100)
            amount += priceCents
        }
        return amount
    }
    
    var processingFees: Int {
        if subtotal == 0 {
            return 0
        }
        let sub = Double(subtotal)
        let feesAndSub = Int(sub * stripeCreditCardCut) + flatFeeCents
        return feesAndSub
    }
    
    var total: Int {
        return subtotal + processingFees + shippingFees
    }
    
    func addItemToCart(item: Product) {
        cartItems.append(item)
    }
    
    func removeItemFromCart(item: Product) {
        if let index = cartItems.firstIndex(of: item) {
            cartItems.remove(at: index)
        }
        
        if cartItems.isEmpty {
            shippingFees = 0
        }
    }
    
    func clearCart() {
        cartItems.removeAll()
        shippingFees = 0
    }
   
}
