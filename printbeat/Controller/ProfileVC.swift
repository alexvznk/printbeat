//
//  ProfileVC.swift
//  printbeat
//
//  Created by Alex on 10/23/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import MessageUI

class ProfileVC: UIViewController {
    @IBOutlet weak var welcomeLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var purchaseDateLbl: UILabel!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var totalPriceLbl: UILabel!
    @IBOutlet weak var openAllPurchasesBtn: UIButton!
    @IBOutlet weak var purchaseView: RoundedView!
    @IBOutlet weak var noPurchasesLbl: UILabel!
    @IBOutlet weak var emptyBoxImg: UIImageView!
    @IBOutlet weak var loginOutBtn: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var purchaseListener: ListenerRegistration? = nil
    var purchases = [Purchase]()
    let transition = Animation()
    
    
    override func viewDidLoad() {
        UserService.profileVC = self
        if !UserService.isGuest {
            setPurchasesListener()
        }
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(recentPurchaseTapped))
        purchaseView.addGestureRecognizer(tap)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        profileSetup()
    }
    
    func profileSetup() {
        if UserService.isGuest {
            purchaseView.isHidden = true
            openAllPurchasesBtn.isHidden = true
            noPurchasesLbl.isHidden = false
            emptyBoxImg.isHidden = false
            welcomeLbl.text = "Hello, Dear Guest!"
            emailLbl.text = "Please Login or Sign Up to use all the features!"
            loginOutBtn.setTitle("Login / Sign Up", for: .normal)
            
        } else {
            if UserService.userListener == nil {
                print("getting current user")
                UserService.getCurrentUser {
                    if self.purchaseListener == nil {
                        self.setPurchasesListener()
                    }
                }
            }
        }
    }
    
    func setPurchasesListener() {
        
        purchaseView.isHidden = true
        openAllPurchasesBtn.isHidden = true
        noPurchasesLbl.isHidden = true
        emptyBoxImg.isHidden = true
        welcomeLbl.text = "Hello, " + UserService.user.username + "!"
        emailLbl.text = UserService.user.email
        loginOutBtn.setTitle("Logout", for: .normal)
        
        purchaseListener =  Firestore.firestore().collection("purchases").whereField("customerId", isEqualTo: UserService.user.stripeId).order(by: "timeStamp").addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error)
                return
            }
            
            snap?.documentChanges.forEach({ (change) in
                if change.type == .added {
                    let data = change.document.data()
                    let purchase = Purchase.init(data: data)
                    self.purchases.append(purchase)
                }
            })
            self.displayRecentPurchaseData(purchase: self.purchases.last)
        })
    }
    
    
    func displayRecentPurchaseData(purchase: Purchase?) {
        if let purchase = purchase {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yy"
            let date = formatter.string(from: purchase.timeStamp.dateValue())
            
            purchaseDateLbl.text = "\(date)"
            cityLbl.text = "\(purchase.city), \(purchase.state)"
            let currencyFormatter = NumberFormatter()
            currencyFormatter.numberStyle = .currency
            if let price = currencyFormatter.string(from: purchase.total as NSNumber) {
                totalPriceLbl.text = price
            } else {
                totalPriceLbl.text = String(purchase.total)
            }

            self.purchaseView.center.x -= 300
            self.purchaseView.isHidden = false
            self.openAllPurchasesBtn.isHidden = false
            self.noPurchasesLbl.isHidden = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: [] , animations: {
                self.purchaseView.center.x += 300
            }, completion: nil)
    
        } else {
            purchaseView.isHidden = true
            openAllPurchasesBtn.isHidden = true
            noPurchasesLbl.isHidden = false
            emptyBoxImg.isHidden = false
        }
    }
    
    @objc func recentPurchaseTapped() {
        let vc = PurchaseDetailsVC()
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.purchase = purchases.last
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func contactSupportBtnClicked(_ sender: Any) {
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            simpleAlert(title: "Error", message: "Your mail services are not available. You can contact us directly: support@printbeat.io")
            return
        } else {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients(["support@printbeat.io"])
            composeVC.setSubject("Support request")
            composeVC.setMessageBody("", isHTML: false)
            self.present(composeVC, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func loginOutBtnClicked(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: Storyboard.LoginStoryboard, bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: StoryboardId.LoginVC) as! LoginVC
        loginVC.profileView = self
        
        if !UserService.isGuest {
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
                    self.present(loginVC, animated: true)
                    self.profileSetup()
                }
            } catch {
                debugPrint(error)
                self.handleFireAuthError(error: error)
            }
        } else {
            present(loginVC, animated: true)
        }
    }
    
    @IBAction func faqBtnClicked(_ sender: Any) {
        
    }
    
    @IBAction func aboutBtnClicked(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.ToUserPurchases {
            if let userPurchasesVC = segue.destination as? UserPurchasesVC {
                userPurchasesVC.purchases = self.purchases.reversed()
            }
        }
    }
    
    deinit {
        if purchaseListener != nil {
            purchaseListener?.remove()
            purchaseListener = nil
        }
    }
}

extension ProfileVC: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
}

extension ProfileVC: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}


