//
//  SettingVC.swift
//  FollowerIntegration8
//
//  Created by appzorro on 06/04/18.
//  Copyright © 2018 appzorro. All rights reserved.
//

import UIKit

class SettingVC: UIViewController {

    @IBOutlet weak var ProfileView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.ProfileView.layer.cornerRadius  = 30.0
        self.ProfileView.layer.masksToBounds = true
    }

    @IBAction func LogoutBtn(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "user_id")
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        let initialViewController = self.storyboard!.instantiateViewController(withIdentifier: "LoginVC")
        appDelegate.window?.rootViewController = initialViewController
        appDelegate.window?.makeKeyAndVisible()
    }
}
