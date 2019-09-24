//
//  Firebase+Utils.swift
//  printbeat
//
//  Created by Alex on 6/1/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import Foundation
import FirebaseFirestore

extension Firestore {
    var categories: Query {
        return collection("categories").order(by: "timeStamp", descending: true)
    }
    var products: Query {
        return collection("products").order(by: "timeStamp", descending: true)
    }
    
    var purchases: Query {
        return collection("purchases").order(by: "timeStamp", descending: true)
    }
}
