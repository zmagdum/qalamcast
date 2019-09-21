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
        tableContents = [
            Section(title: "Options", rows: [
                SwitchRow(text: "Sort Latest -> Oldest", switchValue: APIService.shared.getEpisodesSortOrderPref(), action: didToggleSwitch()),
                SwitchRow(text: "Show Played", switchValue: APIService.shared.getShowPlayedPref(), action: { [weak self] in self?.preferenceChanged($0) })
                ]),
            
            Section(title: "Reset Data", rows: [
                TapActionRow(text: "Reset Database", action: { [weak self] in self?.resetDatabase($0) })
                ]),
            Section(title: "Info", rows: [
                NavigationRow(text: "Version v\(Bundle.main.versionNumber).\(Bundle.main.buildNumber)", detailText: .subtitle("Copyright © 2019 Qalam Institute. All rights reserved"))
                ]),
        ]
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
