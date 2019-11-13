//
//  StripeAPI.swift
//  printbeat
//
//  Created by Alex on 9/9/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import Foundation
import Stripe
import FirebaseFunctions

let StripeAPI = _StripeAPI()

class _StripeAPI: NSObject, STPCustomerEphemeralKeyProvider {
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        
        let data = [
            "stripe_version" : apiVersion,
            "customer_id" : UserService.user.stripeId
        ]
        
        Functions.functions().httpsCallable("createEphemeralKey").call(data) { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                completion(nil, error)
                return
            }
            
            guard let key = result?.data as? [String: Any] else {
                completion(nil, nil)
                return
            }
            
            completion(key, nil)
        }
    }
    
}
