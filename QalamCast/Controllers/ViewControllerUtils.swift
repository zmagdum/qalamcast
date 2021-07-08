//
//  ViewControllerUtils.swift
//  QalamCast
//
//  Created by Zakir Magdum on 4/25/20.
//  Copyright © 2020 Zakir Magdum. All rights reserved.
//

import Foundation
import UIKit

class ViewControllerUtils {
    
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    /*
        Show customized activity indicator,
        actually add activity indicator to passing view
    
        @param uiView - add activity indicator to this view
    */
    func showActivityIndicator(_ uiView: UIView) {
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColorFromHex(rgbValue: 0xffffff, alpha: 0.3)
    
        loadingView.frame = CGRect(0, 0, 80, 80)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColorFromHex(rgbValue: 0x444444, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
    
        activityIndicator.frame = CGRect(0.0, 0.0, 40.0, 40.0);
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        activityIndicator.center = CGPoint(loadingView.frame.size.width / 2, loadingView.frame.size.height / 2);

        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        activityIndicator.startAnimating()
    }

    /*
        Hide activity indicator
        Actually remove activity indicator from its super view
    
        @param uiView - remove activity indicator from this view
    */
    func hideActivityIndicator(_ uiView: UIView) {
        activityIndicator.stopAnimating()
        container.removeFromSuperview()
    }

    /*
        Define UIColor from hex value
        
        @param rgbValue - hex color value
        @param alpha - transparency level
    */
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
}

extension CGRect{
    init(_ x:CGFloat,_ y:CGFloat,_ width:CGFloat,_ height:CGFloat) {
        self.init(x:x,y:y,width:width,height:height)
    }

}
extension CGSize{
    init(_ width:CGFloat,_ height:CGFloat) {
        self.init(width:width,height:height)
    }
}
extension CGPoint{
    init(_ x:CGFloat,_ y:CGFloat) {
        self.init(x:x,y:y)
    }
}

//// In order to show the activity indicator, call the function from your view controller
//// ViewControllerUtils().showActivityIndicator(self.view)
//// In order to hide the activity indicator, call the function from your view controller
//// ViewControllerUtils().hideActivityIndicator(self.view)
