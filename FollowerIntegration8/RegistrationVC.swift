//
//  RegistrationVC.swift
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

class RegistrationVC: UIViewController,UITextFieldDelegate {

    enum Register:Error {
        case CheckEmail
        case CheckUserName
        case InvalidEmail
        case InvalidPassword
        case PasswordMismatch
    }
    
    @IBOutlet weak var UsernameView: UIView!
    @IBOutlet weak var EmailView: UIView!
    
    @IBOutlet weak var PasswordView: UIView!
    @IBOutlet weak var CpasswordView: UIView!
    
    @IBOutlet weak var RegsterOutlet: UIButton!
    
    @IBOutlet weak var ProfilePic: UIImageView!
    @IBOutlet weak var cpassword: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var username: UITextField!
    
    var UserID:String?
    var UserName:String?
    var EmailId:String?
    
    //MARK:- View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.setUI()
    }
    
    //MARK:- Go Back
    @IBAction func BackBtn(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    
    //MARK:- Register Button
    @IBAction func RegisterBtn(_ sender: UIButton) {
       
        do {
            try RegisterCheck()
        }catch Register.CheckUserName {
            self.alertResponse(message: "Please enter username")
        }catch Register.CheckEmail{
            self.alertResponse(message: "Please enter Email-ID")
        }catch Register.InvalidEmail{
            self.alertResponse(message: "Please enter valid Email-ID")
        }catch Register.InvalidPassword{
            self.alertResponse(message: "Password must be greater than  6 digit")
        }catch Register.PasswordMismatch{
            self.alertResponse(message: "Password Mismatch")
        }catch {
            self.alertResponse(message: "Error")
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension RegistrationVC{
    
    //MARK:- Navigation to root view
    func navigateVC(){
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        let initialViewController = self.storyboard!.instantiateViewController(withIdentifier: "MyTabBarCotroller")
        appDelegate.window?.rootViewController = initialViewController
        appDelegate.window?.makeKeyAndVisible()
    }
    
    //MARK:- Registration validation
    func RegisterCheck() throws {
        if(!username.hasText)
        {
            throw Register.CheckUserName
        }
        if(!email.hasText)
        {
            throw Register.CheckEmail
        }
        if !isValidEmail(testStr: self.email.text!)
        {
            throw Register.InvalidEmail
        }
        if((self.password.text?.characters.count)! < 6)
        {
            throw Register.InvalidPassword
        }
        if(self.password.text != cpassword.text)
        {
            throw Register.PasswordMismatch
        }
        //Register user
        self.RegisterUser()
    }
    
    //MARK:- Register User
    func RegisterUser(){
        self.UserName = self.username.text!
        self.EmailId = self.email.text!
        SVProgressHUD.show()
        Auth.auth().createUser(withEmail: self.EmailId!, password: self.password.text!, completion: { (user, err) in
            SVProgressHUD.dismiss()
            if err != nil {
                self.alertResponse(message: err.unsafelyUnwrapped.localizedDescription)
                
            } else {
                
                self.UserID = (user?.uid)!
                let ref = Database.database().reference()
                let usersReference = ref.child("users").child(self.UserID!)
                
                let values = ["name": self.UserName!, "email": self.EmailId!,"followers":0,"userId":self.UserID!,"ProfilePic":"","password":self.password.text!] as [String : Any]
                
                // update our databse by using the child database reference above called usersReference
                usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                    // if there's an error in saving to our firebase database
                    if err != nil {
                        print(err ?? "Error")
                        return
                    }
                    UserDefaults.standard.set(self.UserID, forKey: "user_id")
                    UserDefaults.standard.set(self.UserName, forKey: "username")
                    UserDefaults.standard.set(self.EmailId, forKey: "email")
                    self.navigateVC()
                })
            }
        })
    }
    
    //MARK:- Set UI
    func setUI(){
        ProfilePic.layer.borderWidth = 8
        
        ProfilePic.layer.borderColor = UIColor.init(red:249/255.0, green:40/255.0, blue:78/255.0, alpha: 1.0).cgColor
        ProfilePic.layer.cornerRadius = (self.view.frame.size.width * 0.3)/2
        ProfilePic.layer.masksToBounds = true
        
        UsernameView.layer.cornerRadius = 20
        UsernameView.clipsToBounds = true
        
        EmailView.layer.cornerRadius = 20
        EmailView.clipsToBounds = true
        
        PasswordView.layer.cornerRadius = 20
        PasswordView.clipsToBounds = true
        
        CpasswordView.layer.cornerRadius = 20
        CpasswordView.clipsToBounds = true
        
        RegsterOutlet.layer.cornerRadius = 22
        RegsterOutlet.clipsToBounds = true
    }
}
