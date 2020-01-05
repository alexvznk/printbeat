//
//  ViewController.swift
//  printbeatAdmin
//
//  Created by Alex on 5/26/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AdminHomeVC: HomeVC {

    var longPressGesture: UILongPressGestureRecognizer!
    var didReorder = false
    var isInitial = true
    var initialCategories = [Category]()
    
    override func viewDidLoad() {
        isAdminVC = true
        super.viewDidLoad()
        let addCategoryBtn = UIBarButtonItem(title: "Add Category", style: .plain, target: self, action: #selector(addCategory))
        navigationItem.rightBarButtonItem = addCategoryBtn
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture))
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser == nil {
           performSegue(withIdentifier: Segues.ToAdminLoginVC, sender: self)
        }
        didReorder = false
        isInitial = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        listener.remove()
        if (didReorder) {
            for index in 0..<initialCategories.count {
                if initialCategories[index].id != categories[index].id {
                    let docRef = Firestore.firestore().collection("categories").document(categories[index].id)
                    docRef.updateData(["timeStamp":initialCategories[index].timeStamp])
                }
            }
        }
        categories.removeAll()
        collectionView.reloadData()
    }
    
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else { break }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
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
        didReorder = false
        isInitial = true
        setCategoriesListener()
    }
}

extension AdminHomeVC {
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        didReorder = true
        
        if (isInitial) {
            initialCategories = categories
            isInitial = false
        }

        let categoryToInsert = categories.remove(at: sourceIndexPath.row)
        categories.insert(categoryToInsert, at: destinationIndexPath.row)

    }
}

