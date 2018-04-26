//
//  UserVC.swift
//  FollowerIntegration
//
//  Created by Ashish on 26/03/18.
//  Copyright © 2018 Ashish. All rights reserved.
//

import UIKit
import  Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import SDWebImage
import SVProgressHUD

class UserVC: UIViewController {
    
    @IBOutlet weak var SecondWinnerPic: UIImageView!
    @IBOutlet weak var SecondWinnerName: UILabel!
    
    @IBOutlet weak var FirstWinnerPic: UIImageView!
    @IBOutlet weak var FirstWinnerName: UILabel!
    
    @IBOutlet weak var ThirdWinnerPic: UIImageView!
    @IBOutlet weak var ThirdWinnerName: UILabel!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var userDictArr = [UserDetailsModel]()
    var userTopperDictArr = [UserTopperDetailsModel]()
    
    var userDict:[String:AnyObject] = [:]
    var fillData:[[String:AnyObject]]=[]
    var loggin_userId:String!
    
    var followersArr:[String] = []
    var followersUniqueArr:[String] = []
    
    var message:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = true
        
        RoundProfilePic()
        
        loggin_userId = UserDefaults.standard.value(forKey: "user_id") as! String
        
        //Fetch Followers Info
        self.FetchFollowers()
        
        //Fetch User Info
        self.FetchUserInfo()
        
    }
    
    //MARK:- Fetch User List
    func FetchUserInfo() {
        SVProgressHUD.show()
        let ref = Database.database().reference(withPath: "users")
        ref.observe(.value, with: {  snapshot in
            SVProgressHUD.dismiss()
            if !snapshot.exists() { return }
            
            let userData = snapshot.value as! [String:AnyObject]// Its print all values including Snap (User)
            self.userDictArr.removeAll()
            var i:Int = 0
            for user in userData {
                
                    if var myChildValue = user.value as? [String:Any]
                    {
                        let followingID = myChildValue["userId"] as! String
                        //Check for whether user has follower or not
                        if self.followersArr.contains(followingID) {
                            myChildValue["isFollow"] = true
                        }else{
                            myChildValue["isFollow"] = false
                        }
                    
                        //Check whether user is same as logged in user or not
//                        if(followingID != self.loggin_userId)
//                        {
                            if(i > 2)
                            {
                                //Result for other followers
                                let auc = UserDetailsModel(userDetails: myChildValue as NSDictionary!)
                                self.userDictArr.append(auc)
                            }else{
                                //Result for top 3 followers
                                let auc = UserTopperDetailsModel(userTopperDetails: myChildValue as NSDictionary!)
                                self.userTopperDictArr.append(auc)
                            }
//                        }
                    }
                i += 1
            }
            //Set Result for top 3 followers
            self.TopViewer()
            //Reload Data
            self.tableView.reloadData()
        })
    }
    
    //MARK:- TopViewer
    func TopViewer(){
        //Winner Data
        let topper_count = self.userTopperDictArr.count
        if topper_count >= 1
        {
            let WinnerImage = self.userTopperDictArr[0].ProfilePic
            self.FirstWinnerPic.sd_setImage(with: URL(string: WinnerImage), placeholderImage: UIImage(named: "edit_dash"))
            self.FirstWinnerName.text = self.userTopperDictArr[0].username
        }
        //Runner Data
        if topper_count >= 2
        {
            let RunnerUpImage = self.userTopperDictArr[1].ProfilePic
            self.SecondWinnerPic.sd_setImage(with: URL(string: RunnerUpImage), placeholderImage: UIImage(named: "edit_dash"))
            self.SecondWinnerName.text = self.userTopperDictArr[1].username
        }
        
        //2nd RunnerUp Data
        if topper_count >= 3
        {
            let SecondRunnerUpImage = self.userTopperDictArr[2].ProfilePic
            self.ThirdWinnerPic.sd_setImage(with: URL(string: SecondRunnerUpImage), placeholderImage: UIImage(named: "edit_dash"))
            self.ThirdWinnerName.text = self.userTopperDictArr[2].username
        }
    }
    
    //MARK:- Fetch Follower List
    func FetchFollowers(){
        
        let ref = Database.database().reference(withPath: "followers").child(self.loggin_userId)
        ref.observe(.value, with: {  snapshot in
            if !snapshot.exists() { return }
    
            let followersData = snapshot.value as! [String:AnyObject]
            
           //Fetech follower data
            self.followersArr.removeAll()
            for follower in followersData {
                if let following_id = follower.value as? String {
                    self.followersArr.append(following_id)
                }
            }
            print(self.followersArr)
            
        })
    }
    
    
    
    func FollowUnfollowBtn(sender:UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let cell = self.tableView.cellForRow(at: indexPath) as! UserVCCell
        
        let item = self.userDictArr[sender.tag]
        
        if(!item.isFollow)
        {
             message = "Are you sure you want to follow?"
        }else{
             message = "Are you sure you want to unfollow?"
        }
        let alert = UIAlertController(title: "Alert",
                                              message: message,
                                              preferredStyle: UIAlertControllerStyle.alert)
        let okAction =  UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            if(!item.isFollow)
            {
                item.isFollow = !item.isFollow
                cell.followerBtn.setBackgroundImage(UIImage(named:"follow"), for: .normal)
                
                //update follower status
                let ref = Database.database().reference(withPath: "followers").child(self.loggin_userId)
                ref.updateChildValues([item.userId:item.userId])
            
                //Update user follower count
                let total_followers = item.followers + 1
                
                let ref_user = Database.database().reference(withPath: "users")
                ref_user.child(item.userId).updateChildValues(["followers":total_followers])
            }else{
                item.isFollow = !item.isFollow
                cell.followerBtn.setBackgroundImage(UIImage(named:"following"), for: .normal)
                
                //Unfollow user
                let ref = Database.database().reference(withPath: "followers").child(self.loggin_userId).child(item.userId)
                ref.removeValue()
                
                //Update follower status
                let total_followers = item.followers - 1
                
                let ref_user = Database.database().reference(withPath: "users")
                ref_user.child(item.userId).updateChildValues(["followers":total_followers])
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func RoundProfilePic() {
        FirstWinnerPic.layer.borderWidth = 3
        FirstWinnerPic.layer.masksToBounds = false
        FirstWinnerPic.layer.borderColor = UIColor.init(red:218/255.0, green:111/255.0, blue:176/255.0, alpha: 1.0).cgColor
        FirstWinnerPic.layer.cornerRadius = 45.0
        FirstWinnerPic.clipsToBounds = true
        
        SecondWinnerPic.layer.borderWidth = 3
        SecondWinnerPic.layer.masksToBounds = false
        SecondWinnerPic.layer.borderColor = UIColor.init(red:218/255.0, green:111/255.0, blue:176/255.0, alpha: 1.0).cgColor
        SecondWinnerPic.layer.cornerRadius = 40.0
        SecondWinnerPic.clipsToBounds = true
        
        ThirdWinnerPic.layer.borderWidth = 3
        ThirdWinnerPic.layer.masksToBounds = false
        ThirdWinnerPic.layer.borderColor = UIColor.init(red:218/255.0, green:111/255.0, blue:176/255.0, alpha: 1.0).cgColor
        ThirdWinnerPic.layer.cornerRadius = 40.0
        ThirdWinnerPic.clipsToBounds = true
    }
    

}

extension UserVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userDictArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "usersCell") as! usersCell
        
        let cell = Bundle.main.loadNibNamed("UserVCCell", owner: self, options: nil)?.first as! UserVCCell
        
        cell.followerBtn.tag = indexPath.row
        
        let productImageUrl = self.userDictArr[indexPath.row].ProfilePic
        cell.ProfilePic.sd_setImage(with: URL(string: productImageUrl), placeholderImage: UIImage(named: "edit_dash"))
        
        cell.UserRank.text = String(indexPath.row + 4)
        
        cell.userNameLbl.setTitle(self.userDictArr[indexPath.row].username, for: .normal)
        if(self.userDictArr[indexPath.row].isFollow){
            cell.followerBtn.setBackgroundImage(UIImage(named:"following"), for: .normal)
        }else{
                
            cell.followerBtn.setBackgroundImage(UIImage(named:"follow"), for: .normal)
        }
        cell.followerBtn.addTarget(self, action: #selector(FollowUnfollowBtn), for:.touchUpInside)
        return cell
    }
}
