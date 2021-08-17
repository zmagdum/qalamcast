//
//  MainTabVC.swift
//  QalamCast
//
//  Created by apple on 10/08/21.
//  Copyright © 2021 Zakir Magdum. All rights reserved.
//

import UIKit

class MainTabVC: UITabBarController {

    @IBOutlet weak var tabBarNew: UITabBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tabbarAddShadow()
    }
    
    //MARK: - Tabbar shadow
    
    func tabbarAddShadow() {
        
        tabBarNew.layer.cornerRadius = 15.0
        tabBarNew.layer.shadowColor = UIColor(hexaRGB: "#F4F4F4")?.cgColor
        tabBarNew.layer.shadowOpacity = 1.0
        tabBarNew.layer.shadowOffset = CGSize(width: 3, height: -3)
        tabBarNew.layer.masksToBounds = false
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
