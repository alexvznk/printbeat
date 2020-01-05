//
//  ViewController.swift
//  printbeat
//
//  Created by Alex on 5/26/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class HomeVC: UIViewController {

    @IBOutlet weak var loginOutBtn: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var categories = [Category]()
    var selectedCategory: Category!
    var db: Firestore!
    var listener: ListenerRegistration!
    var isAdminVC = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        setupCollectionView()
        setupNavigationBar()
        if !isAdminVC {
            setupInitialAnonymousUser()
        }
    }
    
    func setupNavigationBar() {
        loginOutBtn.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "AvenirNext-Medium", size: 17)!], for: UIControl.State.normal)
        loginOutBtn.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "AvenirNext-Medium", size: 17)!], for: UIControl.State.selected)
        let logoContainer = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "logo_printbeat")
        imageView.image = image
        logoContainer.addSubview(imageView)
        navigationItem.titleView = logoContainer
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: Identifiers.CategoryCell)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
    
    func setupInitialAnonymousUser() {
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { (result, error) in
                if let error = error {
                    debugPrint(error)
                    self.handleFireAuthError(error: error)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Auth.auth().currentUser != nil {
            setCategoriesListener()
        }
        if let user = Auth.auth().currentUser, !user.isAnonymous {
            loginOutBtn.title = "Logout"
            if UserService.userListener == nil, !isAdminVC {
                UserService.getCurrentUser()
            }
        } else {
            loginOutBtn.title = "Login"
        }
        
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listener.remove()
        categories.removeAll()
        collectionView.reloadData()
    }
    
    func setCategoriesListener() {
        listener = db.categories.addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            snap?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                let category = Category.init(data: data)
                
                switch change.type {
                case .added:
                    self.onDocumentAdded(change: change, category: category)
                case .modified:
                    self.onDocumentModified(change: change, category: category)
                case .removed:
                    self.onDocumentRemoved(change: change)
                }
            })
            
        })
    }

    
    @IBAction func favoritesClicked(_ sender: Any) {
        if UserService.isGuest {
            simpleAlert(title: "Hello Friend!", message: "Please register/login to use favorites.")
        } else {
            performSegue(withIdentifier: Segues.ToFavorites, sender: self)
        }
    }
    
    
    @IBAction func loginOutClicked(_ sender: Any) {
        guard let user = Auth.auth().currentUser else { return }
        if user.isAnonymous {
            presentLoginVC()
        } else {
            do {
                activityIndicator.startAnimating()
                try Auth.auth().signOut()
                UserService.logoutUser()
                Auth.auth().signInAnonymously { (result, error) in
                    if let error = error {
                        debugPrint(error)
                        self.activityIndicator.stopAnimating()
                        self.handleFireAuthError(error: error)
                    }
                    self.activityIndicator.stopAnimating()
                    StripeCart.clearCart()
                    self.presentLoginVC()
                }
            } catch {
               debugPrint(error)
                self.handleFireAuthError(error: error)
            }
        }
    }
    
    func presentLoginVC() {
        let storyboard = UIStoryboard(name: Storyboard.LoginStoryboard, bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: StoryboardId.LoginVC) as! LoginVC
        loginVC.homeView = self
        present(loginVC, animated: true) {
            self.loginOutBtn.title = "Login"
        }
    }


}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func onDocumentAdded(change: DocumentChange, category: Category) {
        let newIndex = Int(change.newIndex)
        collectionView.numberOfItems(inSection: 0)
        categories.insert(category, at: newIndex)
        collectionView.insertItems(at: [IndexPath(item: newIndex, section: 0)])
    }
    
    func onDocumentModified(change: DocumentChange, category: Category) {
        if change.newIndex == change.oldIndex {
            let index = Int(change.newIndex)
            categories[index] = category
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        } else {
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            categories.remove(at: oldIndex)
            categories.insert(category, at: newIndex)
            collectionView.moveItem(at: IndexPath(item: oldIndex, section: 0), to: IndexPath(item: newIndex, section: 0))
        }
    }
    
    func onDocumentRemoved(change: DocumentChange) {
        let oldIndex = Int(change.oldIndex)
        categories.remove(at: oldIndex)
        collectionView.deleteItems(at: [IndexPath(item: oldIndex, section: 0)])
    }
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.CategoryCell, for: indexPath) as? CategoryCell {
            cell.configureCell(category: categories[indexPath.item])
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let cellWidth = (width - 60) / 2
        let cellHeight = cellWidth * 1.2
        
        return CGSize(width: cellWidth, height: cellHeight)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCategory = categories[indexPath.item]
        performSegue(withIdentifier: Segues.ToProducts, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
