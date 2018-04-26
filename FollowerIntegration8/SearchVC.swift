//
//  SearchVC.swift
//  FollowerIntegration8
//
//  Created by appzorro on 06/04/18.
//  Copyright © 2018 appzorro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import SDWebImage
import SVProgressHUD

class SearchVC: UIViewController {
    
    
    @IBOutlet weak var SearchView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    lazy  var searchBar:UISearchBar = UISearchBar(frame: CGRect(x:0, y:0, width:200,height: 20))
    var userDictArr = [UserDetailsModel]()
    var userDict:[String:AnyObject] = [:]
    var searchController : UISearchController!
    var fillData:[[String:AnyObject]]=[]
    var loggin_userId:String!
    
    var followersArr:[String] = []
    var followersUniqueArr:[String] = []
    
    var searchActive : Bool = false
    
    var message:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.SearchView.layer.cornerRadius = 5
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
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
            for user in userData {
                if var myChildValue = user.value as? [String:Any]
                {
                    let followingID = myChildValue["userId"] as! String
                    if self.followersArr.contains(followingID) {
                        myChildValue["isFollow"] = true
                    }else{
                        myChildValue["isFollow"] = false
                    }
                    
                    //Check whether user is same as logged in user or not
                    if(followingID != self.loggin_userId)
                    {
                        let auc = UserDetailsModel(userDetails: myChildValue as NSDictionary!)
                        self.userDictArr.append(auc)
                    }
                }
            }
            self.tableView.reloadData()
        })
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
    
    @IBAction func SearchTextBtn(_ sender: UITextField) {
        print("hi")
    }
    
    
}

extension SearchVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive){
            return fillData.count
        }else{
            return self.userDictArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "usersCell") as! usersCell
        let cell = Bundle.main.loadNibNamed("UserVCCell", owner: self, options: nil)?.first as! UserVCCell
        cell.followerBtn.tag = indexPath.row
        
        cell.UserRank.text = String(indexPath.row + 1)
        
        let productImageUrl = self.userDictArr[indexPath.row].ProfilePic
        cell.ProfilePic.sd_setImage(with: URL(string: productImageUrl), placeholderImage: UIImage(named: "edit_dash"))
        
        if(searchActive){
            let item = self.fillData[indexPath.row]
            cell.userNameLbl.setTitle(item["username"] as? String, for: .normal)
        }else{
            cell.userNameLbl.setTitle(self.userDictArr[indexPath.row].username, for: .normal)
            if(self.userDictArr[indexPath.row].isFollow){
                cell.followerBtn.setBackgroundImage(UIImage(named:"following"), for: .normal)
            }else{
                cell.followerBtn.setBackgroundImage(UIImage(named:"follow"), for: .normal)
            }
            cell.followerBtn.addTarget(self, action: #selector(FollowUnfollowBtn), for:.touchUpInside)
        }
        return cell
    }
    
    
}
