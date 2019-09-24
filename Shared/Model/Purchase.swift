//
//  Purchase.swift
//  printbeat
//
//  Created by Alex on 9/16/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Purchase {
    var id: String
    var timeStamp: Timestamp
    var userId: String
    var userEmail: String
    var userName: String
    var street: String
    var apt: String
    var zip: String
    var city: String
    var state: String
    var country: String
    var shippingCost: Double
    var shippingCompany: String
    var total: Double
    var processingFees: Double


    init(id: String,
         timeStamp: Timestamp,
         userId: String,
         userEmail: String,
         userName: String,
         street: String,
         apt: String,
         zip: String,
         city: String,
         state: String,
         country: String,
         shippingCost: Double,
         shippingCompany: String,
         total: Double,
         processingFees: Double) {
        self.id = id
        self.timeStamp = timeStamp
        self.userId = userId
        self.userEmail = userEmail
        self.userName = userName
        self.street = street
        self.apt = apt
        self.zip = zip
        self.city = city
        self.state = state
        self.country = country
        self.shippingCost = shippingCost
        self.shippingCompany = shippingCompany
        self.total = total
        self.processingFees = processingFees
    }
    
    init(data: [String: Any]) {
        self.id = data["id"] as? String ?? ""
        self.timeStamp = data["timeStamp"] as? Timestamp ?? Timestamp()
        self.userId = data["userId"] as? String ?? ""
        self.userEmail = data["userEmail"] as? String ?? ""
        self.userName = data["userName"] as? String ?? ""
        self.street = data["street"] as? String ?? ""
        self.apt = data["apt"] as? String ?? ""
        self.zip = data["zip"] as? String ?? ""
        self.city = data["city"] as? String ?? ""
        self.state = data["state"] as? String ?? ""
        self.country = data["country"] as? String ?? ""
        self.shippingCost = data["shippingCost"] as? Double ?? 0.0
        self.shippingCompany = data["shippingCompany"] as? String ?? ""
        self.total = data["total"] as? Double ?? 0.0
        self.processingFees = data["processingFees"] as? Double ?? 0.0
        
    }
    
    
    static func modelToData(purchase: Purchase) -> [String: Any] {
        let data : [String: Any] = [
            "id" : purchase.id,
            "timeStamp" : purchase.timeStamp,
            "userId" : purchase.userId,
            "userEmail" : purchase.userEmail,
            "userName" : purchase.userName,
            "street" : purchase.street,
            "apt" : purchase.apt,
            "zip" : purchase.zip,
            "city" : purchase.city,
            "state" : purchase.state,
            "country" : purchase.country,
            "shippingCost" : purchase.shippingCost,
            "shippingCompany" : purchase.shippingCompany,
            "total" : purchase.total,
            "processingFees" : purchase.processingFees
        ]

        return data
    }
}
