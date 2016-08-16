//
//  CityChatViewController.swift
//  PokeTrainerApp
//
//  Created by iParth on 8/8/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase

class CityChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tblCities: UITableView!
    
    var navigationBar = UINavigationBar()
    var Cities = ["Portland","San Jose","Los Angeles","Irvine","San Diego","Phoenix","San Antonio","Austin","Houston","Dallas","Las Vegas","Miami","Atlanta","Chicago","Denver","Seattle","New York","Boston","Oklahoma City","Cleveland","Memphis","Philadelphia","Pittsburgh","Washington D.C.","Baltimore","St. Louis","Charlotte","Tampa"]
    var unSortedCities = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        // Create the navigation bar
        navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, 64)) // Offset by 20 pixels vertically to take the status bar into account
        navigationBar.frame.size.width = UIScreen.mainScreen().bounds.size.width
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationBar.tintColor = UIColor.whiteColor()
        navigationBar.barTintColor = AppState.sharedInstance.appBlueColor
        navigationBar.translucent = false
        
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = "Select City"
        let leftButton =  UIBarButtonItem(title: "Back", style:   UIBarButtonItemStyle.Plain, target: self, action: #selector(self.ActionGoBack(_:)))
        navigationItem.leftBarButtonItem = leftButton
        navigationBar.items = [navigationItem]
        self.view.addSubview(navigationBar)
        
        Cities.sortInPlace()
    }

    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //Go Back to Previous screen
    @IBAction func ActionGoBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Cities.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell:UserTableViewCell = tableView.dequeueReusableCellWithIdentifier("UserTableViewCell", forIndexPath: indexPath) as! UserTableViewCell
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell?
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        }
        
        cell!.textLabel?.text = self.Cities[indexPath.row]
        cell!.accessoryType = .DisclosureIndicator
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var cityId = self.Cities[indexPath.row]
        cityId = cityId.stringByReplacingOccurrencesOfString(" ", withString: "")
        cityId = cityId.stringByReplacingOccurrencesOfString(".", withString: "")
        
        //Check is user is blocked ??
        CommonUtils.sharedUtils.showProgress(self.view, label: "Please wait..")
        
        let firebase: FIRDatabaseReference = FIRDatabase.database().referenceWithPath("Chat_\(cityId)_blockedUser")
//        let query: FIRDatabaseQuery = firebase.queryOrderedByChild((FIRAuth.auth()?.currentUser?.uid)!).queryEqualToValue("1")
//        query.observeSingleEventOfType(.Value, withBlock: {(snapshot: FIRDataSnapshot) -> Void in
//            CommonUtils.sharedUtils.hideProgress()
//            if snapshot.exists() {
//                print(snapshot.childrenCount) // I got the expected number of items
//                let enumerator = snapshot.children
//                while let rest = enumerator.nextObject() as? FIRDataSnapshot {
//                    print(rest.key)
//                    print("founds block entry with key : \(rest.key)")
//                }
//                CommonUtils.sharedUtils.showAlert(self, title: "Alert", message: "Opps, sorry you are blocked for this group!")
//            } else {
//                let chatVc = self.storyboard?.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController!
//                chatVc.city = cityId
//                chatVc.senderId = FIRAuth.auth()?.currentUser?.uid
//                chatVc.senderDisplayName = AppState.sharedInstance.displayName ?? ""
////                self.navigationController?.pushViewController(chatVc, animated: true)
//            }
//        })
        
        firebase.observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
            var isBlockedUser = false
            
            CommonUtils.sharedUtils.hideProgress()
            
            if snapshot.exists() {
                print(snapshot.childrenCount)
                if let blockedUsers = snapshot.value as? [String: String]{
                    for (key,value) in blockedUsers {
                        if key == (FIRAuth.auth()?.currentUser?.uid)!
                            && value == "1"
                        {
                            isBlockedUser = true
                            print("isBlockedUser : true")
                        }
                    }
                }
            }
            if isBlockedUser == true {
                CommonUtils.sharedUtils.showAlert(self, title: "Alert", message: "Opps, sorry you are blocked for this group!")
            } else {
                let chatVc = self.storyboard?.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController!
                chatVc.city = cityId
                chatVc.senderId = FIRAuth.auth()?.currentUser?.uid
                chatVc.senderDisplayName = AppState.sharedInstance.displayName ?? ""
                self.navigationController?.pushViewController(chatVc, animated: true)
            }
        }
        
    }
}
