//
//  RegisterVC.swift
//  printbeat
//
//  Created by Alex on 5/27/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import UIKit
import Firebase

class RegisterVC: UIViewController {
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var confirmPassTxt: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var passCheckImg: UIImageView!
    @IBOutlet weak var confirmPassCheckImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTxt.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        confirmPassTxt.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)

        // Do any additional setup after loading the view.
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
    
        if textField == passwordTxt {
            if passwordTxt.text == "" {
                passCheckImg.isHidden = true
                confirmPassCheckImg.isHidden = true
                confirmPassTxt.text = ""
                return
            }
            passCheckImg.isHidden = false
            if passwordTxt.text!.count > 7 {
                passCheckImg.image = UIImage(named: AppImages.BlackCheck)
            } else {
                passCheckImg.image = UIImage(named: AppImages.BlackError)
            }
        } else {
            if confirmPassTxt.text == "" {
                confirmPassCheckImg.isHidden = true
                return
            }
            confirmPassCheckImg.isHidden = false
            if confirmPassTxt.text == passwordTxt.text && confirmPassTxt.text!.count > 7 {
               confirmPassCheckImg.image = UIImage(named: AppImages.BlackCheck)
            } else {
                confirmPassCheckImg.image = UIImage(named: AppImages.BlackError)
            }
        }
        
    }
    
    @IBAction func cancelBtnClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func registerBtnClicked(_ sender: Any) {
        guard let email = emailTxt.text, !email.isEmpty,
            let username = usernameTxt.text, !username.isEmpty,
            let password = passwordTxt.text, !password.isEmpty else {
                simpleAlert(title: "Error", message: "Please fill out all fields.")
                return
        }
        guard let confirmPass = confirmPassTxt.text, confirmPass == password else {
            simpleAlert(title: "Error", message: "Passwords do not match.")
            return
        }
        
        activityIndicator.startAnimating()
        
        guard let authUser = Auth.auth().currentUser else { return }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)

        authUser.linkAndRetrieveData(with: credential) { (result, error) in
            if let error = error {
                debugPrint(error)
                self.handleFireAuthError(error: error)
                return
            }
            guard let fireUser = result?.user else { return }
            let user = User.init(id: fireUser.uid, email: email, username: username, stripeId: "")
            self.createFirestoreUser(user: user)
        }
        
    }
    
    func createFirestoreUser(user: User) {
        print("CREATING FIRESTORE USER")
        let newUserRef = Firestore.firestore().collection("users").document(user.id)
        let data = User.modelToData(user: user)
        newUserRef.setData(data) { (error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "Error", message: "Can't create a user")
                
            } else {
                self.view.endEditing(true)
                if let loginVC = self.presentingViewController as? LoginVC {
                    loginVC.homeView?.loginOutBtn.title = "Logout"
                    loginVC.profileView?.profileSetup()
                }
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            self.activityIndicator.stopAnimating()
        }
        
    }
    
    

}
