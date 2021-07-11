//
//  SettingsController.swift
//  QalamCast
//
//  Created by Zakir Magdum on 4/20/19.
//  Copyright © 2019 Zakir Magdum. All rights reserved.
//

import UIKit
import QuickTableViewController

class SettingsController : QuickTableViewController {
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    let build = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

    override func viewDidLoad() {
        super.viewDidLoad()
        let currentEpisode = DB.shared.getCurrentEpisode()
        tableContents = [
            
            Section(title: "Options", rows: [
                SwitchRow(text: "Sort Latest -> Oldest", switchValue: APIService.shared.getEpisodesSortOrderPref(), action: didToggleSwitch()),
                SwitchRow(text: "Show Played", switchValue: APIService.shared.getShowPlayedPref(), action: didToggleSwitch()),
                SwitchRow(text: "Auto play at application start", switchValue: APIService.shared.getAutoStartPlay(), action: didToggleSwitch())
                ]),
            
            Section(title: "Reset Data", rows: [
                TapActionRow(text: "Reset Database", action: { [weak self] in self?.resetDatabase($0) })
                ]),
            Section(title: "Info", rows: [
                NavigationRow(text: "Version v\(Bundle.main.versionNumber).\(Bundle.main.buildNumber)", detailText: .subtitle("Copyright © 2019 Qalam Institute. All rights reserved"))
                ]),
            Section(title: "Currently Playing", rows: [
                NavigationRow(text: currentEpisode?.title ?? "", detailText: .subtitle("\(currentEpisode?.played ?? 0)"))
                ]),
         
            
//            Section(title: "Crashlitics Check", rows: [
//                TapActionRow(text: "Crashlitics Check", action: { [weak self] in self?.CrashliticsCheck($0) })
//                ]),
            
        ]
    }
    
//    // MARK: - Actions
//    private func DonateBtnClick(_ sender: Row) {
//        
//        if let url = URL(string: "https://www.qalam.institute/support-us"), UIApplication.shared.canOpenURL(url) {
//            UIApplication.shared.openURL(url)
//        }
//    }
    
    // MARK: - Actions
    private func CrashliticsCheck(_ sender: Row) {
       fatalError()
    }
    
    // MARK: - Actions
    private func resetDatabase(_ sender: Row) {
        // ...
        try! DB.shared.resetDatabase()
        DB.shared.fetchEpisodesFromSeries()
        //DB.shared.fetchEpisodesFromMainUrl();
    }
    
    private func didToggleSwitch() -> (Row) -> Void {
        return { [weak self] in
            if let row = $0 as? SwitchRowCompatible {
                let state = "\(row.text) = \(row.switchValue)"
                if row.text.starts(with: "Sort") {
                    UserDefaults.standard.set(row.switchValue, forKey: "sort_preference")
                } else if row.text.starts(with: "Show") {
                    UserDefaults.standard.set(row.switchValue, forKey: "show_played_preference")
                } else if row.text.starts(with: "Auto") {
                    UserDefaults.standard.set(row.switchValue, forKey: "auto_start_play_preference")
                }
                print ("Changed \(state)")
            }
        }
    }

    private func preferenceChanged(_ sender: Row) {
        //UserDefaults.standard.set(sender.text, forKey: "show_played_preference")
        print("Preference changed \(sender)")
    }
    
    private func didToggleSelection() -> (Row) -> Void {
        return { [weak self] row in
            // ...
        }
    }
}
