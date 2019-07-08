//
//  ViewController.swift
//  printbeatAdmin
//
//  Created by Alex on 5/26/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import UIKit

class AdminHomeVC: HomeVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem?.isEnabled = false
        let addCategoryBtn = UIBarButtonItem(title: "Add Category", style: .plain, target: self, action: #selector(addCategory))
        navigationItem.rightBarButtonItem = addCategoryBtn
    }
    
    @objc func addCategory() {
        //segue to category
        performSegue(withIdentifier: Segues.ToAddEditCategory, sender: self)
    }


}

