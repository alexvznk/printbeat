//
//  UserService.swift
//  printbeat
//
//  Created by Alex on 7/17/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import Foundation
import Firebase

let UserService = _UserService()

final class _UserService {
    var user = User()
    var favorites = [Product]()
    let auth = Auth.auth()
    let db = Firestore.firestore()
    var userListener: ListenerRegistration? = nil
    var purchaseListener: ListenerRegistration? = nil
    var profileVC: ProfileVC? = nil
    var isGuest: Bool {
        guard let authUser = auth.currentUser else {
            return true
        }
        if authUser.isAnonymous {
            return true
        } else {
            return false
        }
    }
    
    func getCurrentUser(updateUI: (()->())? = nil) {
        guard let authUser = auth.currentUser else { return }
        
        let userRef = db.collection("users").document(authUser.uid)
        userListener = userRef.addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            guard let data = snap?.data() else { return }
            self.user = User.init(data: data)
            updateUI?()
        })
        
        let favsRef = userRef.collection("favorites")
        favsRef.getDocuments { (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }

            snap?.documents.forEach({ (document) in
                let favorite = Product.init(data: document.data())
                self.favorites.append(favorite)
            })
        }
    }
    
    func favoriteSelected(product: Product) {
        let favsRef = db.collection("users").document(user.id).collection("favorites")
        if favorites.contains(product) {
            favorites.removeAll{$0 == product}
            favsRef.document(product.id).delete()
        } else {
            favorites.append(product)
            let data = Product.modelToData(product: product)
            favsRef.document(product.id).setData(data)
        }
    }
    
    func logoutUser() {
        userListener?.remove()
        profileVC?.purchaseListener?.remove()
        profileVC?.purchaseListener = nil
        userListener = nil
        user = User()
        favorites.removeAll()
        profileVC?.purchases.removeAll()
    }    
}
