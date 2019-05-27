//
//  ViewController.swift
//  printbeat
//
//  Created by Alex on 5/26/19.
//  Copyright © 2019 Alex Vozniuk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let storyboard = UIStoryboard(name: Storyboard.LoginStoryboard, bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: StoryboardId.LoginVC)
        present(loginVC, animated: true, completion: nil)
    }


}

