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
    var customerId: String
    var customerEmail: String
    var customerName: String
    var addrLine1: String
    var addrLine2: String
    var postalCode: String
    var city: String
    var state: String
    var country: String
    var shippingCost: Double
    var shippingMethod: String
    var total: Double
    var processingFees: Double


    init(id: String,
         timeStamp: Timestamp,
         customerId: String,
         customerEmail: String,
         customerName: String,
         addrLine1: String,
         addrLine2: String,
         postalCode: String,
         city: String,
         state: String,
         country: String,
         shippingCost: Double,
         shippingMethod: String,
         total: Double,
         processingFees: Double) {
        self.id = id
        self.timeStamp = timeStamp
        self.customerId = customerId
        self.customerEmail = customerEmail
        self.customerName = customerName
        self.addrLine1 = addrLine1
        self.addrLine2 = addrLine2
        self.postalCode = postalCode
        self.city = city
        self.state = state
        self.country = country
        self.shippingCost = shippingCost
        self.shippingMethod = shippingMethod
        self.total = total
        self.processingFees = processingFees
    }
    
    init(data: [String: Any]) {
        self.id = data["id"] as? String ?? ""
        self.timeStamp = data["timeStamp"] as? Timestamp ?? Timestamp()
        self.customerId = data["customerId"] as? String ?? ""
        self.customerEmail = data["customerEmail"] as? String ?? ""
        self.customerName = data["customerName"] as? String ?? ""
        self.addrLine1 = data["addrLine1"] as? String ?? ""
        self.addrLine2 = data["addrLine2"] as? String ?? ""
        self.postalCode = data["postalCode"] as? String ?? ""
        self.city = data["city"] as? String ?? ""
        self.state = data["state"] as? String ?? ""
        self.country = data["country"] as? String ?? ""
        self.shippingCost = data["shippingCost"] as? Double ?? 0.0
        self.shippingMethod = data["shippingMethod"] as? String ?? ""
        self.total = data["total"] as? Double ?? 0.0
        self.processingFees = data["processingFees"] as? Double ?? 0.0
        
    }
    
    
    static func modelToData(purchase: Purchase) -> [String: Any] {
        let data : [String: Any] = [
            "id" : purchase.id,
            "timeStamp" : purchase.timeStamp,
            "customerId" : purchase.customerId,
            "customerEmail" : purchase.customerEmail,
            "customerName" : purchase.customerName,
            "addrLine1" : purchase.addrLine1,
            "addrLine2" : purchase.addrLine2,
            "postalCode" : purchase.postalCode,
            "city" : purchase.city,
            "state" : purchase.state,
            "country" : purchase.country,
            "shippingCost" : purchase.shippingCost,
            "shippingMethod" : purchase.shippingMethod,
            "total" : purchase.total,
            "processingFees" : purchase.processingFees
        ]

        return data
    }
}
