//
//  ProfileVC.swift
//  FollowerIntegration8
//
//  Created by appzorro on 06/04/18.
//  Copyright © 2018 appzorro. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {

    @IBOutlet weak var UserName: UILabel!
    @IBOutlet weak var FollowBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
        FollowBtn.layer.cornerRadius = 18
        if let uname = UserDefaults.standard.value(forKey: "username")
        {
            self.UserName.text = uname as? String
        }
    }

}
