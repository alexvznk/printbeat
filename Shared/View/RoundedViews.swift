//
//  RoundedViews.swift
//  printbeat
//
//  Created by Alex on 5/27/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import Foundation
import UIKit

class RoundedButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5
    }
}

class RoundedImageView: UIImageView {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5
    }
}

class RoundedView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowOffset = CGSize.zero
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 10
    }
}

