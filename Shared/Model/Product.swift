//
//  Product.swift
//  printbeat
//
//  Created by Alex on 5/28/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Product {
    var name: String
    var id: String
    var categoryId: String
    var price: Double
    var productDescription: String
    var imgUrl: String
    var timeStamp: Timestamp
    var stock: Int
    
    init(name: String, id: String, categoryId: String, price: Double, productDescription: String, imgUrl: String, timeStamp: Timestamp, stock: Int) {
        self.name = name
        self.id = id
        self.categoryId = categoryId
        self.price = price
        self.productDescription = productDescription
        self.imgUrl = imgUrl
        self.timeStamp = timeStamp
        self.stock = stock
    }
    
    init(data: [String: Any]) {
        self.name = data["name"] as? String ?? ""
        self.id = data["id"] as? String ?? ""
        self.categoryId = data["categoryId"] as? String ?? ""
        self.price = data["price"] as? Double ?? 0.0
        self.productDescription = data["productDescription"] as? String ?? ""
        self.imgUrl = data["imgUrl"] as? String ?? ""
        self.timeStamp = data["timeStamp"] as? Timestamp ?? Timestamp()
        self.stock = data["stock"] as? Int ?? 0
    }
    
    static func modelToData(product: Product) -> [String: Any] {
        let data: [String : Any] = ["name" : product.name,
                                    "id" : product.id,
                                    "categoryId" : product.categoryId,
                                    "price" : product.price,
                                    "productDescription" : product.productDescription,
                                    "imgUrl" : product.imgUrl,
                                    "timeStamp" : product.timeStamp,
                                    "stock" : product.stock]
        return data
    }
}
