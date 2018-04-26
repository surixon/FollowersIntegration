//
//  ViewController.swift
//  FollowerIntegration
//
//  Created by Ashish on 26/03/18.
//  Copyright © 2018 Ashish. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

class ViewController: UIViewController,FBSDKLoginButtonDelegate {
    
    var userName:String = ""
    var usersEmail:String = ""
    var usersFacebookID:String = ""
    var userPic:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        //var rootVC : UIViewController?
        if UserDefaults.standard.value(forKey: "user_id") != nil {
            
            //            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserVC") as! UserVC
            //            let navigationController = UINavigationController(rootViewController: rootVC!)
            //            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            //            appDelegate.window?.rootViewController = navigationController
            let appDelegate = UIApplication.shared.delegate! as! AppDelegate
            let initialViewController = self.storyboard!.instantiateViewController(withIdentifier: "MyTabBarCotroller")
            appDelegate.window?.rootViewController = initialViewController
            appDelegate.window?.makeKeyAndVisible()
        }else{
           // rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
            // let navigationController = UINavigationController(rootViewController: rootVC!)
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            appDelegate.window?.rootViewController = rootVC
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController
//            self.navigationController?.pushViewController(vc, animated: true)
        }

        
//        let loginButton = FBSDKLoginButton()
//        view.addSubview(loginButton)
        
//        loginButton.frame = CGRect(x: 16, y: 50, width: view.frame.width-32, height: 50)
//        loginButton.delegate = self
//        loginButton.readPermissions = ["email","public_profile"]
        
        
        let customFBButton = UIButton(type:.system)
        
        customFBButton.backgroundColor = UIColor.blue
        customFBButton.frame = CGRect(x: 16, y: 116, width: view.frame.width-32, height: 50)
        customFBButton.setTitle("Facebook Login", for: .normal)
        
        customFBButton.setTitleColor(.white, for: .normal)
        
        view.addSubview(customFBButton)
        
        customFBButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
    }
    
    @objc func handleCustomFBLogin(){
        FBSDKLoginManager().logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil{
                print("FB login failed")
                return
            }
            self.FacebookLogin()
        }
    }
    
    var userId:String = ""
    func FacebookLogin(){
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil{
                print("Something went wrong with facebook")
                return
            }
            let ref = Database.database().reference()
            
            // guard for user id
            guard let uid = user?.uid else {
                return
            }
            self.userId = uid
            // create a child reference - uid will let us wrap each users data in a unique user id for later reference
            let usersReference = ref.child("users").child(uid)
            
            // performing the Facebook graph request to get the user data that just logged in so we can assign this stuff to our Firebase database:
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, picture"])
            graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                
                if ((error) != nil) {
                    // Process error
                    print("Error: \(String(describing: error))")
                } else {
                    print("fetched user: \(String(describing: result))")
                    
                    // Facebook users name:
                    var dict:[String:AnyObject] = [:]
                    dict = result as! [String : AnyObject]
                    let userName:String = dict["name"] as! String
                    self.userName = userName
                    if let userEmail = dict["email"]
                    {
                        self.usersEmail = userEmail as! String
                    }
                    
                    if let userPic = (dict["picture"]?["data"] as? NSDictionary)?.value(forKey: "url")
                    {
                        self.userPic = userPic as! String
                    }
                    
                    let userID:NSString =  dict["id"] as! String as NSString as NSString
                    self.usersFacebookID = userID as String
                    
                    let values = ["name": self.userName, "email": self.usersEmail, "facebookID": self.usersFacebookID,"followers":0,"userId":self.userId,"ProfilePic":self.userPic] as [String : Any]
                    
                    // update our databse by using the child database reference above called usersReference
                    usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                        // if there's an error in saving to our firebase database
                        if err != nil {
                            print(err ?? "Error")
                            return
                        }
                        
                        // no error, so it means we've saved the user into our firebase database successfully
                        print("Save the user successfully into Firebase database")
                        
                    })
                    UserDefaults.standard.set(self.userId, forKey: "user_id")
                    UserDefaults.standard.set(self.userName, forKey: "username")
                    self.navigateVC()
                }
            })
            print("Successfully logged in with facebook")
        }
    }
    func navigateVC(){
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        let initialViewController = self.storyboard!.instantiateViewController(withIdentifier: "MyTabBarCotroller")
        appDelegate.window?.rootViewController = initialViewController
        appDelegate.window?.makeKeyAndVisible()
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserVC") as! UserVC
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did logout of facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil{
            print(error)
            return
        }
        self.navigateVC()
        print("Succesfully login with facebook")
    }
}

