//
//  SettingsView.swift
//  QalamCast
//
//  Created by Zakir Magdum on 8/1/19.
//  Copyright © 2019 Zakir Magdum. All rights reserved.
//

import Foundation
import UIKit

class SettingsView: UIView {

    @IBAction func resetDataClicked(_ sender: Any) {
        try! DB.shared.resetDatabase()
        DB.shared.fetchEpisodesFromSeries()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("SettingsView", owner: self, options: nil)
        //addSubview(contentView)
        
    }
}
