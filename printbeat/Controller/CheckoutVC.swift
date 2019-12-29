//
//  CheckoutVC.swift
//  printbeat
//
//  Created by Alex on 9/8/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import UIKit
import Stripe
import FirebaseFunctions
import FirebaseFirestore

class CheckoutVC: UIViewController, CartItemDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var paymentMethodBtn: UIButton!
    @IBOutlet weak var shippingMethodBtn: UIButton!
    @IBOutlet weak var subtotalLbl: UILabel!
    @IBOutlet weak var processingFeeLbl: UILabel!
    @IBOutlet weak var shippingCostLbl: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var creditCardImg: UIImageView!
    @IBOutlet weak var emptyCartLbl: UILabel!
    @IBOutlet weak var placeOrderBtn: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var paymentContext: STPPaymentContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 316, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CartItemCell", bundle: nil), forCellReuseIdentifier: Identifiers.CartItemCell)
        if UserService.isGuest {
            emptyCartLbl.text = "You have to be logged in to use the cart."
            emptyCartLbl.isHidden = false
            paymentMethodBtn.isEnabled = false
            shippingMethodBtn.isEnabled = false
        } else {
            setupPaymentInfo()
            setupStripeConfig()
            emptyCartLabelSetup()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.stopAnimating()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        StripeCart.shippingFees = 0
    }
    
    func emptyCartLabelSetup() {
        if StripeCart.cartItems.isEmpty {
            emptyCartLbl.isHidden = false
        }
    }
    
    func setupPaymentInfo() {
        subtotalLbl.text = StripeCart.subtotal.centsToFormattedCurrency()
        processingFeeLbl.text = StripeCart.processingFees.centsToFormattedCurrency()
        shippingCostLbl.text = StripeCart.shippingFees.centsToFormattedCurrency()
        totalLbl.text = StripeCart.total.centsToFormattedCurrency()
    }
    
    func setupStripeConfig() {
        let config = STPPaymentConfiguration.shared()
        config.requiredBillingAddressFields = .none
        config.requiredShippingAddressFields = [.postalAddress]
        
        let customerContext = STPCustomerContext(keyProvider: StripeAPI)
        paymentContext = STPPaymentContext(customerContext: customerContext, configuration: config, theme: .default())
        paymentContext.paymentAmount = StripeCart.total
        paymentContext.delegate = self
        paymentContext.hostViewController = self
    }
    
    @IBAction func placeOrderClicked(_ sender: Any) {
        if StripeCart.cartItems.isEmpty {
            simpleAlert(title: "Cart is empty", message: "Add some items to your cart before placing order")
            return
        }
        paymentContext.requestPayment()
        activityIndicator.startAnimating()
    }
    
    @IBAction func paymentMethodClicked(_ sender: Any) {
        paymentContext.pushPaymentOptionsViewController()
    }
    
    @IBAction func shippingMethodClicked(_ sender: Any) {
        paymentContext.pushShippingViewController()
    }
    
    func removeItem(product: Product) {
        guard let rowIndex = StripeCart.cartItems.firstIndex(of: product) else { return }
        StripeCart.removeItemFromCart(item: product)
        tableView.deleteRows(at: [IndexPath(row: rowIndex, section: 0)], with: .fade)
        setupPaymentInfo()
        paymentContext.paymentAmount = StripeCart.total
        emptyCartLabelSetup()
    }
}

extension CheckoutVC: STPPaymentContextDelegate {
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        if let paymentMethod = paymentContext.selectedPaymentOption {
            paymentMethodBtn.setTitle(paymentMethod.label, for: .normal)
            creditCardImg.image = paymentMethod.image
        } else {
            paymentMethodBtn.setTitle("Select Method", for: .normal)
            creditCardImg.image = nil
        }
        
        if let shippingMethod = paymentContext.selectedShippingMethod {
            shippingMethodBtn.setTitle(shippingMethod.label, for: .normal)
            StripeCart.shippingFees = Int(Double(truncating: shippingMethod.amount) * 100)
            setupPaymentInfo()
        } else {
            shippingMethodBtn.setTitle("Select Method", for: .normal)
        }
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        let retry = UIAlertAction(title: "Retry", style: .default) { (action) in
            self.paymentContext.retryLoading()
        }
        alertController.addAction(cancel)
        alertController.addAction(retry)
        present(alertController, animated: true)
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        
        let data: [String: Any] = [
            "purchases": StripeCart.cartItemIds,
            "shippingMethod": paymentContext.selectedShippingMethod!.label,
            "customerId": UserService.user.stripeId
        ]
        
        Functions.functions().httpsCallable("createPaymentIntent").call(data) { (result, error) in
            
            if let error = error {
                completion(.error, error)
                return
            }
            
            if let clientSecret = (result?.data as? [String: Any])?["clientSecret"] as? String {
                
                let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
                paymentIntentParams.paymentMethodId = paymentResult.paymentMethod?.stripeId
                
                STPPaymentHandler.shared().confirmPayment(withParams: paymentIntentParams, authenticationContext: paymentContext) { status, paymentIntent, error in
                    switch status {
                    case .succeeded:
                        StripeCart.clearCart()
                        self.tableView.reloadData()
                        self.setupPaymentInfo()
                        completion(.success, nil)
                    case .failed:
                        completion(.error, error) // Report error
                    case .canceled:
                        completion(.userCancellation, nil) // Customer cancelled
                    @unknown default:
                        completion(.error, nil)
                    }
                }
                
            } else {
                completion(.error, nil)
            }
            
        }
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        
        let title: String
        let message: String
        
        activityIndicator.stopAnimating()

        switch status {
        case .error:
            title = "Error"
            message = error?.localizedDescription ?? "Internal error"
        case .success:
            title = "Success"
            message = "Thank you for your purchase. Check your email for order confirmation."
        case .userCancellation:
            return
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        
        alertController.addAction(action)
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
        present(alertController, animated: true, completion: nil)
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didUpdateShippingAddress address: STPAddress, completion: @escaping STPShippingMethodsCompletionBlock) {
        
        let upsGround = PKShippingMethod()
        upsGround.amount = 0
        upsGround.label = "UPS Ground"
        upsGround.detail = "Arrives in 3-5 days"
        upsGround.identifier = "ups_ground"
        
        let fedEx = PKShippingMethod()
        fedEx.amount = 9.99
        fedEx.label = "FedEx"
        fedEx.detail = "Arrives tomorrow"
        fedEx.identifier = "fedex"
        
        
        if address.country == "US" {
            completion(.valid, nil, [upsGround, fedEx], fedEx)
        } else {
            completion(.invalid, nil, nil, nil)
        }
    }
    
}

extension CheckoutVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StripeCart.cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.CartItemCell, for: indexPath) as? CartItemCell {
            let product = StripeCart.cartItems[indexPath.row]
            cell.configureCell(product: product, delegate: self)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}
