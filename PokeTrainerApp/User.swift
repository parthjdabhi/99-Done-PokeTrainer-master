//
//  User.swift
//  PokeTrainerApp
//
//  Created by super on 8/11/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
class User: NSObject {
    
    func setData(email: String, firstName: String, lastName: String, password: String) {
        let userData = NSMutableDictionary ()
        
        userData.setValue(firstName, forKey: "firstName")
        userData.setValue(lastName, forKey: "lastName")
        userData.setValue(password, forKey: "password")
        userData.setValue(email, forKey: "email")
        
        // Save Data
        
        NSUserDefaults.standardUserDefaults().setObject(userData, forKey: "userData")
    }
    
//    func setrQuestions("type_team", "type_play", "type_hunt")
}