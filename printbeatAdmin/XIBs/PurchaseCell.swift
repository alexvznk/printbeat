//
//  PurchaseCell.swift
//  printbeatAdmin
//
//  Created by Alex on 9/17/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import UIKit

class PurchaseCell: UITableViewCell {
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var userEmailLbl: UILabel!
    @IBOutlet weak var userLocationLbl: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configureCell(purchase: Purchase) {
        let formatter = DateFormatter()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        formatter.dateFormat = "MM/dd/yy"
        let date = formatter.string(from: purchase.timeStamp.dateValue())
        let time = timeFormatter.string(from: purchase.timeStamp.dateValue())
        
        dateLbl.text = "\(date), \(time)"
        userEmailLbl.text = purchase.userEmail
        userLocationLbl.text = "\(purchase.city), \(purchase.state)"
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        if let price = currencyFormatter.string(from: purchase.total as NSNumber) {
            totalLbl.text = price
        }
    }
    
}
