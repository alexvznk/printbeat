//
//  ForgotPasswordVC.swift
//  printbeat
//
//  Created by Alex on 5/27/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import UIKit
import Firebase

class ForgotPasswordVC: UIViewController {

    @IBOutlet weak var emailTxt: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
    }
    
    @IBAction func cancelBtnClicked(_ sender: Any) {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
        
    }
    @IBAction func resetBtnClicked(_ sender: Any) {
        guard let email = emailTxt.text, !email.isEmpty else {
            simpleAlert(title: "Error", message: "Please enter your email.")
            return
        }
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                debugPrint(error)
                self.handleFireAuthError(error: error)
                return
            }
            self.view.endEditing(true)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
