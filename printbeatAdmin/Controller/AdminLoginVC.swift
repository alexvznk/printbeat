//
//  AdminLoginVC.swift
//  printbeatAdmin
//
//  Created by Alex on 12/29/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import UIKit
import Firebase

class AdminLoginVC: UIViewController {
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
    }

    @IBAction func loginBtnClicked(_ sender: Any) {
        guard let email = emailTxt.text, !email.isEmpty,
            let pass = passwordTxt.text, !pass.isEmpty else {
                simpleAlert(title: "Error", message: "Please fill out all fields.")
                return
        }
        
        activityIndicator.startAnimating()
        
        Firestore.firestore().collection("administrators").document(email).getDocument { (snap, err) in
            if let err = err {
                self.simpleAlert(title: "Error", message: err.localizedDescription)
                self.activityIndicator.stopAnimating()
                return
            }
            if let snap = snap, snap.exists {
                Auth.auth().signIn(withEmail: email, password: pass) { (result, error) in
                    if let error = error {
                        debugPrint(error)
                        self.handleFireAuthError(error: error)
                        self.activityIndicator.stopAnimating()
                        return
                    }
                    self.activityIndicator.stopAnimating()
                    self.dismiss(animated: true, completion: nil)
                    self.presentationController?.delegate?.presentationControllerDidDismiss?(self.presentationController!)
                    
                }
            } else {
                self.simpleAlert(title: "Error", message: "User with this email doesn't have administrator rights.")
                self.activityIndicator.stopAnimating()
            }
        }
    }
}
