//
//  ViewController.swift
//  What2Watch
//
//  Created by Dustin Allen on 7/15/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import SDWebImage

class MainScreenViewController: UIViewController, PDGlobalTimerDelegate, PDLocationServiceDelegate {
 
    @IBOutlet var profileInfo: UILabel!
    @IBOutlet var profilePicture: UIImageView!
    var ref:FIRDatabaseReference!
    var user: FIRUser!
    @IBOutlet var welcomeLabel: UILabel!

    @IBOutlet weak var timerLabel: UILabel?
    @IBOutlet weak var caloriesLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicture.layer.borderWidth = 1
        profilePicture.layer.masksToBounds = false
        profilePicture.layer.borderColor = UIColor.whiteColor().CGColor
        profilePicture.layer.cornerRadius = profilePicture.frame.height/2
        //print("profilePicture.frame.height : \(profilePicture.frame.height/2)")
        profilePicture.clipsToBounds = true
        
        //Remove back Button 
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        ref = FIRDatabase.database().reference()
        user = FIRAuth.auth()?.currentUser
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        ref.child("users").child(userID!).child("profileData").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            AppState.sharedInstance.currentUser = snapshot
            if let base64String = snapshot.value!["userPhoto"] as? String {
                // decode image
                self.profilePicture.image = CommonUtils.sharedUtils.decodeImage(base64String)
                AppState.sharedInstance.currentUserImage = CommonUtils.sharedUtils.decodeImage(base64String)
            } else {
                if let facebookData = snapshot.value!["facebookData"] as? [String : String] {
                    if let image_url = facebookData["profilePhotoURL"]  {
                        print(image_url)
                        let image_url_string = image_url
                        let url = NSURL(string: "\(image_url_string)")
                        self.profilePicture.sd_setImageWithURL(url, completed: { (image, error, sdImageCacheType, url) in
                            if error == nil && image != nil {
                                AppState.sharedInstance.currentUserImage = image
                            }
                        })
                    }
                }
            }})
        
            self.ref.child("users").child(userID!).child("userInfo").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                AppState.sharedInstance.currentUser = snapshot
                self.profileInfo.text = "  Welcome,  "
                let userFirstName = AppState.sharedInstance.currentUser?.value?["userFirstName"] as? String ?? ""
                let userLastName = AppState.sharedInstance.currentUser?.value?["userLastName"] as? String ?? ""
                self.profileInfo.text = "  Welcome, \(userFirstName) \(userLastName)!  "
                AppState.sharedInstance.displayName = "\(userFirstName) \(userLastName)"
                
                let userInfo = snapshot.valueInExportFormat() as? NSMutableDictionary ?? NSMutableDictionary()
                userInfo["deviceToken"] = NSUserDefaults.standardUserDefaults().objectForKey("deviceToken") as? String ?? ""
                self.ref.child("users").child(userID!).child("userInfo").updateChildValues(userInfo as [NSObject : AnyObject])
                
            }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        PDGlobalTimer.sharedInstance().delegate = self
        PDLocationService.sharedInstance.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        profilePicture.layer.cornerRadius = profilePicture.frame.height/2
        //print("profilePicture.frame.height : \(profilePicture.frame.height/2)")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        PDGlobalTimer.sharedInstance().delegate = nil
        PDLocationService.sharedInstance.delegate = nil
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func timePassinHours(strTime: String) {
        timerLabel?.text = strTime
    }
    
    func caloriesBurned(strCalories: String) {
        caloriesLabel?.text = strCalories
    }
    
    @IBAction func logoutButton(sender: AnyObject) {
//        let SettingQuesVC = self.storyboard?.instantiateViewControllerWithIdentifier("SettingQuesViewController") as! SettingQuesViewController!
//        self.navigationController?.pushViewController(SettingQuesVC, animated: true)
//        let PhotoVC = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoViewController") as! PhotoViewController!
//        self.navigationController?.pushViewController(PhotoVC, animated: true)
        
        let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SettingsViewController") as! SettingsViewController!
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    @IBAction func pokeTrainer(sender: AnyObject) {
        let timerViewController = self.storyboard?.instantiateViewControllerWithIdentifier("TimerViewController") as! TimerViewController!
        self.navigationController?.pushViewController(timerViewController, animated: true)
    }
    
    //Friend Request Listing
    @IBAction func ActionMyFriendRequest(sender: AnyObject) {
        let friendReqViewController = self.storyboard?.instantiateViewControllerWithIdentifier("FriendReqViewController") as! FriendReqViewController!
        self.navigationController?.pushViewController(friendReqViewController, animated: true)
    }
    
    //Chat With all users
    @IBAction func ActionChatAllUsers(sender: AnyObject)
    {
        let cityVc = self.storyboard?.instantiateViewControllerWithIdentifier("CityChatViewController") as! CityChatViewController!
        self.navigationController?.pushViewController(cityVc, animated: true)
        
//        let chatVc = self.storyboard?.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController!
//        chatVc.senderId = FIRAuth.auth()?.currentUser?.uid
//        chatVc.senderDisplayName = "User"
//        self.navigationController?.pushViewController(chatVc, animated: true)
    }
    
    //Friend Request Listing
    @IBAction func ActionMyFriends(sender: AnyObject)
    {        
        let friendListViewController = self.storyboard?.instantiateViewControllerWithIdentifier("FriendListViewController") as! FriendListViewController!
        self.navigationController?.pushViewController(friendListViewController, animated: true)
    }
    
    //Recent Chat
    @IBAction func ActionRecentChat(sender: AnyObject)
    {
        let recentChatViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RecentChatViewController") as! RecentChatViewController!
        self.navigationController?.pushViewController(recentChatViewController, animated: true)
    }
}

