//
//  Home.swift
//  QalamCast
//
//  Created by apple on 10/08/21.
//  Copyright © 2021 Zakir Magdum. All rights reserved.
//

import UIKit

class Home: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var homeScrollView: UIScrollView!
    @IBOutlet weak var scrollSubView: UIView!
    @IBOutlet weak var episodeOfTheWeekView: UIView!
    @IBOutlet weak var shadowView: UIView!
    
    @IBOutlet weak var episodeOfTheWeekTitle: UILabel!
    @IBOutlet weak var episodeOfTheWeekDetails: UILabel!
    
    @IBOutlet weak var favPodcastCollection: UICollectionView!
    @IBOutlet weak var collectionHeightConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //favPodcastCollection.contentSize = CGSize(width: 932, height: 180)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        layoutEpisodeOfTheWeekView()
        addLeftViewInSearch()
        
    }
    
    //MARK: - Layout episod view
    
    func layoutEpisodeOfTheWeekView () {
        
        episodeOfTheWeekView.layer.cornerRadius = 15.0
        episodeOfTheWeekView.layer.shadowColor = UIColor(hexaRGB: "#F4F4F4")?.cgColor
        episodeOfTheWeekView.layer.shadowOpacity = 1.0
        episodeOfTheWeekView.layer.shadowOffset = CGSize(width: -3, height: 3)
        episodeOfTheWeekView.layer.masksToBounds = false
        
        shadowView.layer.cornerRadius = 15.0
        shadowView.layer.shadowColor = UIColor(hexaRGB: "#F4F4F4")?.cgColor
        shadowView.layer.shadowOpacity = 1.0
        shadowView.layer.shadowOffset = CGSize(width: 3, height: -3)
        shadowView.layer.masksToBounds = false
        
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

    //MARK: - UICollectionView Methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize (width: 128, height: 180)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 12
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let podFavCell = collectionView.dequeueReusableCell(withReuseIdentifier: "favPodcastHomeCell", for: indexPath) as! favPodcastHomeCell
         
        //favPodcastCollection.contentSize = CGSize(width: 932, height: 380)
        
        collectionHeightConstraint.constant = 380
        
        homeScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: collectionView.frame.maxY)
                    
        return podFavCell
        
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
