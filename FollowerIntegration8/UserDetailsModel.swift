//
//  File.swift
//  FollowerIntegration8
//
//  Created by appzorro on 04/04/18.
//  Copyright © 2018 appzorro. All rights reserved.
//

import Foundation

class UserDetailsModel{
    var email:String = "",
    username:String = "",
    userId:String = "",
    isFollow:Bool = true,
    followers:Int = 0,
    ProfilePic:String = ""
    
    init(userDetails:NSDictionary) {
        self.email = userDetails["email"] as! String
        self.username = userDetails["name"] as! String
        self.userId = userDetails["userId"] as! String
        self.isFollow = userDetails["isFollow"] as! Bool
        self.followers = userDetails["followers"] as! Int
        self.ProfilePic = userDetails["ProfilePic"] as! String
    }
    
}

class UserTopperDetailsModel {
    var email:String = "",
    username:String = "",
    userId:String = "",
    isFollow:Bool = true,
    followers:Int = 0,
    ProfilePic:String = ""
    
    init(userTopperDetails:NSDictionary) {
        self.email = userTopperDetails["email"] as! String
        self.username = userTopperDetails["name"] as! String
        self.userId = userTopperDetails["userId"] as! String
        self.isFollow = userTopperDetails["isFollow"] as! Bool
        self.followers = userTopperDetails["followers"] as! Int
        self.ProfilePic = userTopperDetails["ProfilePic"] as! String
    }
}

