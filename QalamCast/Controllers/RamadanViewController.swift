//
//  RamadanViewController.swift
//  QalamCast
//
//  Created by Zakir Magdum on 4/25/20.
//  Copyright © 2020 Zakir Magdum. All rights reserved.
//

import WebKit

class RamadanViewController : UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        self.view = webView
        
        let url = URL(string: "https://www.qalam.institute/ramadan-resources")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        //ViewControllerUtils().showActivityIndicator(self.view)
    }
    
    
}
