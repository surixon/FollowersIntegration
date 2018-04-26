//
//  LoginVC.swift
//  FollowerIntegration
//
//  Created by appzorro on 11/04/18.
//  Copyright © 2018 appzorro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import SVProgressHUD

class LoginVC: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var UsernameView: UIView!
    @IBOutlet weak var PasswordView: UIView!
    @IBOutlet weak var LoginOutlet: UIButton!
    
    
    @IBOutlet weak var EmailText: UITextField!
    @IBOutlet weak var PasswordText: UITextField!
    
    //MARK:- Enumeration
    enum Login:Error {
        case CheckEmail
        case InvalidEmail
        case InvalidPassword
    }
    
    var UserID:String?
    var Password:String?
    var EmailId:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //MARK:- Loggin Button
    @IBAction func LoginBtn(_ sender: UIButton) {
        do {
            //Check validations
            try LoginCheck()
        }catch Login.CheckEmail{
            self.alertResponse(message: "Please enter Email-ID")
        }catch Login.InvalidEmail{
            self.alertResponse(message: "Please enter valid Email-ID")
        }catch Login.InvalidPassword{
            self.alertResponse(message: "Password must be greater than  6 digit")
        }catch {
            self.alertResponse(message: "Error")
        }
    }
    
    //MARK:- Create Account
    @IBAction func CreateAccount(_ sender: UIButton) {
        let vc  = self.storyboard?.instantiateViewController(withIdentifier: "RegistrationVC") as? RegistrationVC
        self.navigationController?.pushViewController(vc!, animated: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}




extension LoginVC {
    //MARK:- Login Validations
    func LoginCheck() throws {
        if(!EmailText.hasText)
        {
            throw Login.CheckEmail
        }
        if !isValidEmail(testStr: self.EmailText.text!)
        {
            throw Login.InvalidEmail
        }
        if((self.PasswordText.text?.characters.count)! < 6)
        {
            throw Login.InvalidPassword
        }
        
        //Login success
        self.LoginUser()
    }
    
    //MARK:- Login User
    func LoginUser(){
        self.Password = self.PasswordText.text!
        self.EmailId = self.EmailText.text!
        SVProgressHUD.show()
        Auth.auth().signIn(withEmail: self.EmailId!, password: self.Password!) { (user, error) in
            SVProgressHUD.dismiss()
            if error == nil {
                self.UserID = (user?.uid)!
                UserDefaults.standard.set(self.UserID, forKey: "user_id")
                //UserDefaults.standard.set(self.UserName, forKey: "username")
                UserDefaults.standard.set(self.EmailId, forKey: "email")
                self.navigateVC()
                
            } else {
                self.alertResponse(message: error.unsafelyUnwrapped.localizedDescription)
            }
        }
    }
    
    //MARK:- Navigate to root view controller
    func navigateVC(){
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        let initialViewController = self.storyboard!.instantiateViewController(withIdentifier: "MyTabBarCotroller")
        appDelegate.window?.rootViewController = initialViewController
        appDelegate.window?.makeKeyAndVisible()
    }
    
    //MARK:- Set UI
    func setUI(){
        UsernameView.layer.cornerRadius = 20
        UsernameView.clipsToBounds = true
        
        PasswordView.layer.cornerRadius = 20
        PasswordView.clipsToBounds = true
        
        LoginOutlet.layer.cornerRadius = 22
        LoginOutlet.clipsToBounds = true
    }

}
