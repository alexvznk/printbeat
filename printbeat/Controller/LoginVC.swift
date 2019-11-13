//
//  LoginVC.swift
//  printbeat
//
//  Created by Alex on 5/27/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {

    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var homeView: HomeVC?
    var profileView: ProfileVC?
    
    @IBAction func forgotPassClicked(_ sender: Any) {
        let forgotPasswordVC = ForgotPasswordVC(nibName: "ForgotPasswordVC", bundle: nil)
        forgotPasswordVC.modalPresentationStyle = .overCurrentContext
        forgotPasswordVC.modalTransitionStyle = .crossDissolve

        present(forgotPasswordVC, animated: true, completion: nil)
    }
    
    @IBAction func loginClicked(_ sender: Any) {
        guard let email = emailTxt.text, !email.isEmpty,
            let pass = passwordTxt.text, !pass.isEmpty else {
                simpleAlert(title: "Error", message: "Please fill out all fields.")
                return
        }
        
        activityIndicator.startAnimating()
        Auth.auth().signIn(withEmail: email, password: pass) { (result, error) in
            if let error = error {
                debugPrint(error)
                self.handleFireAuthError(error: error)
                self.activityIndicator.stopAnimating()
                return
            }
            self.activityIndicator.stopAnimating()
            print("Login Successful")
            self.view.endEditing(true)
            self.homeView?.loginOutBtn.title = "Logout"
            self.profileView?.profileSetup()
            self.dismiss(animated: true, completion: nil)
            
        }
        
        
        
    }
    
    @IBAction func guestClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
