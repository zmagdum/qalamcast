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
    static let homeUrl = "https://www.qalamcampus.com"
    let urlRequest = URLRequest(url: URL(string: homeUrl)!)
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        self.view = webView
        
        webView.load(urlRequest)
        webView.allowsBackForwardNavigationGestures = true
        //ViewControllerUtils().showActivityIndicator(self.view)
    }
 
//    override func viewWillAppear(_ animated: Bool) {
//        DispatchQueue.main.async {
//            self.webView.load(self.urlRequest)
//        }
//    }
//
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

         let url = navigationAction.request.url

        if url?.description.lowercased() != RamadanViewController.homeUrl {
             decisionHandler(.cancel)
             UIApplication.shared.openURL(url!)
         } else {
             decisionHandler(.allow)
         }

     }

    
}
