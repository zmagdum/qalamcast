//
//  SettingsController.swift
//  QalamCast
//
//  Created by Zakir Magdum on 4/20/19.
//  Copyright © 2019 Zakir Magdum. All rights reserved.
//

import UIKit

class SettingsController : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        registerSettingsBundle()
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsController.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        defaultsChanged()
    }
    func registerSettingsBundle(){
        let appDefaults = [String:AnyObject]()
        UserDefaults.standard.register(defaults: appDefaults)
    }
    @objc func defaultsChanged(){
        if UserDefaults.standard.bool(forKey: "RedThemeKey") {
            self.view.backgroundColor = UIColor.red
            
        }
        else {
            self.view.backgroundColor = UIColor.green
        }
    }
    
    deinit { //Not needed for iOS9 and above. ARC deals with the observer in higher versions.
        NotificationCenter.default.removeObserver(self)
    }
}
