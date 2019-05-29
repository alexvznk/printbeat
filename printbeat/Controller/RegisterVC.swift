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
                passCheckImg.image = UIImage(named: AppImages.GreenCheck)
            } else {
                passCheckImg.image = UIImage(named: AppImages.RedCheck)
            }
        } else {
            if confirmPassTxt.text == "" {
                confirmPassCheckImg.isHidden = true
                return
            }
            confirmPassCheckImg.isHidden = false
            if confirmPassTxt.text == passwordTxt.text && confirmPassTxt.text!.count > 7 {
               confirmPassCheckImg.image = UIImage(named: AppImages.GreenCheck)
            } else {
                confirmPassCheckImg.image = UIImage(named: AppImages.RedCheck)
            }
        }
        
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
            self.activityIndicator.stopAnimating()
            print("Registered new user")
            self.view.endEditing(true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
