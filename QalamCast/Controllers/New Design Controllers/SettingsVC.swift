//
//  SettingsVC.swift
//  QalamCast
//
//  Created by apple on 10/08/21.
//  Copyright © 2021 Zakir Magdum. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    @IBOutlet weak var languageBtn: UIButton!
    @IBOutlet weak var notificationBtn: UIButton!
    @IBOutlet weak var volumeBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    //MARK: - Button Clicks
    
    @IBAction func languageBtnClick(_ sender: Any) {
    }
    @IBAction func notificationBtnClick(_ sender: Any) {
    }
    @IBAction func volumeBtnClick(_ sender: Any) {
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
