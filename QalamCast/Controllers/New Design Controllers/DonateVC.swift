//
//  DonateVC.swift
//  QalamCast
//
//  Created by apple on 10/08/21.
//  Copyright © 2021 Zakir Magdum. All rights reserved.
//

import UIKit
import WebKit

class DonateVC: UIViewController {

    @IBOutlet weak var donateWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let url = URL(string: "https://www.qalam.institute/support-us")
        let urlRequest = URLRequest(url: url!)
        donateWebView.load(urlRequest)
        
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
