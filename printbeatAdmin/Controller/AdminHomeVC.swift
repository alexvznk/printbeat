//
//  ViewController.swift
//  printbeatAdmin
//
//  Created by Alex on 5/26/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import UIKit
import FirebaseAuth
class AdminHomeVC: HomeVC {

    override func viewDidLoad() {
        isAdminVC = true
        super.viewDidLoad()
        let addCategoryBtn = UIBarButtonItem(title: "Add Category", style: .plain, target: self, action: #selector(addCategory))
        navigationItem.rightBarButtonItem = addCategoryBtn
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser == nil {
           performSegue(withIdentifier: Segues.ToAdminLoginVC, sender: self)
        }
    }
    
    override func loginOutClicked(_ sender: Any) {
        guard let _ = Auth.auth().currentUser else { return }
        
        do {
            activityIndicator.startAnimating()
            try Auth.auth().signOut()
            activityIndicator.stopAnimating()
            listener.remove()
            categories.removeAll()
            loginOutBtn.title = "Login"
            collectionView.reloadData()
            performSegue(withIdentifier: Segues.ToAdminLoginVC, sender: self)
            
        } catch {
            debugPrint(error)
            self.handleFireAuthError(error: error)
        }
        
    }
    
    @objc func addCategory() {
        performSegue(withIdentifier: Segues.ToAddEditCategory, sender: self)
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Segues.ToAdminLoginVC {
            segue.destination.presentationController?.delegate = self;
        }
        
        if segue.identifier == Segues.ToProducts {
            if let destination = segue.destination as? ProductsVC {
                destination.category = selectedCategory
            }
        }
        
        if segue.identifier == Segues.ToShoppingCart {
            if let destination = segue.destination as? CheckoutVC {
                destination.hidesBottomBarWhenPushed = true
            }
        }
    
    }

    
}

extension AdminHomeVC: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        loginOutBtn.title = "Logout"
        setCategoriesListener()
    }
}

