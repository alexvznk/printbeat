//
//  Extensions.swift
//  printbeat
//
//  Created by Alex on 5/27/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import UIKit
import Firebase

extension UIViewController {
    func handleFireAuthError(error: Error) {
        if let errorCode = AuthErrorCode(rawValue: error._code) {
            let alert = UIAlertController(title: "Error", message: errorCode.errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func simpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
}

extension AuthErrorCode {
    var errorMessage: String {
        switch self {
        case .emailAlreadyInUse:
            return "The email is already in use with another account."
        case .userNotFound:
            return "Account not found for the specified user. Please check and try again"
        case .userDisabled:
            return "Your account has been disabled. Please contact support."
        case .invalidEmail, .invalidSender, .invalidRecipientEmail:
            return "Please enter a valid email"
        case .networkError:
            return "Network error. Please try again."
        case .wrongPassword:
            return "Your password or email is incorrect."
        
        default:
            return "Sorry, something went wrong."
        }
    }
}

extension Int {
    func centsToFormattedCurrency() -> String {
        let dollars = Double(self) / 100
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let dollarStr = formatter.string(from: dollars as NSNumber){
            return dollarStr
        }
        return "$0.00"
    }
}

extension UITextField {
    func setPadding() {
        
    }
    open override func awakeFromNib() {
        layer.borderWidth = 0
        layer.cornerRadius = 10
        layer.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let paddingView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10, height: self.frame.height))
        leftView = paddingView
        leftViewMode = .always
        
    }
    
}
