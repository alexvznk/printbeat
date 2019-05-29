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
    var category: String
    var price: Double
    var productDescription: String
    var imageUrl: String
    var timeStamp: Timestamp
    var stock: Int
    var favorite: Bool
}
