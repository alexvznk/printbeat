//
//  PurchasesVC.swift
//  printbeatAdmin
//
//  Created by Alex on 9/17/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import UIKit
import FirebaseFirestore

class PurchasesVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var purchases = [Purchase]()
    var listener: ListenerRegistration!
    var lastDocument: QueryDocumentSnapshot?
    let transition = Animation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "PurchaseCell", bundle: nil), forCellReuseIdentifier: Identifiers.PurchaseCell)
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .black
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        fetchRecentPurchases()
    }
    
    @objc func refreshData() {
        purchases.removeAll()
        tableView.reloadData()
        fetchRecentPurchases()
        tableView.refreshControl?.endRefreshing()
    }
    
    
    func fetchRecentPurchases() {
        Firestore.firestore().purchases.limit(to: 10).getDocuments { (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            for document in snap!.documents {
                let data = document.data()
                let purchase = Purchase.init(data: data)
                self.purchases.append(purchase)
            }
            self.lastDocument = snap?.documents.last
            self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
        }
    }
    
    func fetchMoreData() {

        if lastDocument != nil {

            Firestore.firestore().purchases.start(afterDocument: self.lastDocument!).getDocuments { (snap, error) in
                
                if let error = error {
                    debugPrint(error.localizedDescription)
                    return
                }
                
                for document in snap!.documents {
                    let data = document.data()
                    let purchase = Purchase.init(data: data)
                    self.purchases.append(purchase)
                }
                self.lastDocument = snap?.documents.last
                self.tableView.reloadData()
            }
            
        } else {
            return
        }
    }

}

extension PurchasesVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = PurchaseDetailsVC()
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.purchase = purchases[indexPath.row]
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purchases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.PurchaseCell, for: indexPath) as? PurchaseCell {
            cell.configureCell(purchase: purchases[indexPath.row])
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if ((targetContentOffset.pointee.y + scrollView.frame.height >= scrollView.contentSize.height) && scrollView.contentSize.height != 0) {
            fetchMoreData()
        }
    }
}

extension PurchasesVC: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
}
