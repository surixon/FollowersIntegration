//
//  UserVCCell.swift
//  FollowerIntegration8
//
//  Created by appzorro on 05/04/18.
//  Copyright © 2018 appzorro. All rights reserved.
//

import UIKit

class UserVCCell: UITableViewCell {
    
    @IBOutlet weak var ProfilePic: UIImageView!
    @IBOutlet weak var TotalScore: UILabel!
    @IBOutlet weak var UserRank: UILabel!
    @IBOutlet weak var followerBtn: UIButton!
    @IBOutlet weak var userNameLbl: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ProfilePic.layer.borderWidth = 2
        ProfilePic.layer.masksToBounds = false
        ProfilePic.layer.borderColor = UIColor.init(red:218/255.0, green:218/255.0, blue:218/255.0, alpha: 1.0).cgColor
        //ProfilePic.layer.borderColor = UIColor.lightGray.cgColor
        ProfilePic.layer.cornerRadius = 25.0
        ProfilePic.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
