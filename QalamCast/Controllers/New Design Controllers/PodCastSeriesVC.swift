//
//  PodCastSeriesVC.swift
//  QalamCast
//
//  Created by apple on 10/08/21.
//  Copyright © 2021 Zakir Magdum. All rights reserved.
//

import UIKit
import FeedKit

class PodCastSeriesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchField: UITextField!
    
    @IBOutlet weak var podcastTableView: UITableView!
    

    var categories = [Category]()
    
    func fetchEpisodes() {
        do {
            try self.categories = DB.shared.getCategories()
            DispatchQueue.main.async {
                self.podcastTableView.reloadData()
            }
        } catch {
            print("Could not load categories")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        addLeftViewInSearch()
        
        fetchEpisodes()
        setupObservers()
    }
    
    //MARK:- Setup
    fileprivate func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleCatalogStart), name: .catalogStart, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleCatalogProgress), name: .catalogProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleCatalogComplete), name: .catalogComplete, object: nil)
    }

    @objc fileprivate func handleCatalogStart(notification: Notification) {
        
    }

    @objc fileprivate func handleCatalogProgress(notification: Notification) {
        
    }
    
    @objc fileprivate func handleCatalogComplete(notification: Notification) {
        fetchEpisodes()
    }
    
    //MARK: - Add left view in search field
    
    func addLeftViewInSearch() {
        
        searchField.leftViewMode = .always
        
        let leftViewNew = UIView(frame: CGRect(x: 0, y: 0, width: 55, height: 45))
        leftViewNew.backgroundColor = UIColor.clear
        
        let searchImg = UIImageView(frame: CGRect(x: 15, y: 10, width: 25, height: 25))
        searchImg.image = UIImage(named: "searchNew")
        
        leftViewNew.addSubview(searchImg)
        
        searchField.leftView = leftViewNew
        
    }
    
    //MARK: - TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let podcastSeriesCell = tableView.dequeueReusableCell(withIdentifier: "PodcastSeriesCell") as! PodcastSeriesCell
        
        let series = categories[indexPath.row]
        podcastSeriesCell.series = series
        
        return podcastSeriesCell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyBoardNew = UIStoryboard.init(name: "NewDesign", bundle: nil)
        
        let seriesListVC = storyBoardNew.instantiateViewController(withIdentifier: "SeriesListVC") as! SeriesListVC
        
        seriesListVC.series = self.categories[indexPath.row]
        
        self.navigationController?.pushViewController(seriesListVC, animated: true)
        
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
