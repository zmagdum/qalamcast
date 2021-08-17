//
//  PodcastSeriesCell.swift
//  QalamCast
//
//  Created by apple on 10/08/21.
//  Copyright © 2021 Zakir Magdum. All rights reserved.
//

import UIKit

class PodcastSeriesCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var podImgView: UIImageView!
    @IBOutlet weak var podTitle: UILabel!
    @IBOutlet weak var podDetails: UILabel!
    @IBOutlet weak var appName: UILabel!
    @IBOutlet weak var episodeNumber: UILabel!
    @IBOutlet weak var releaseDateLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var favouriteBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    
    @IBOutlet weak var dotLbl: UILabel!
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.selectionStyle = .none
    }
    
    let dateFormatter = DateFormatter()

    var series: Category! {
        didSet {
            podTitle.text = series.title!
            dateFormatter.dateFormat = "MMM dd, yyyy"
            //let lastUpdated = dateFormatter.string(from: series.lastUpdated!)
//            let unplayed = try! DB.shared.getUnplayedCount(series: series.title ?? "")
            var desc = "Episodes \(series.episodeCount ?? 0)"
            
            episodeNumber.text = String(series.episodeCount!) + " Eps"
            
            if series.lastUpdated != nil {
                desc += " " + dateFormatter.string(from: series.lastUpdated!)
            }
            podDetails.text = desc
            appName.text = series.speakers
            let imageUrl = series.artwork ?? ""
            if (imageUrl.starts(with: "http")) {
                let url = URL(string: imageUrl)
                podImgView.sd_setImage(with: url, completed: nil)
            } else {
                podImgView.image = UIImage(named: imageUrl)
            }
        }
    }

    
    @IBOutlet weak var seriesNameLabel: UILabel! {
        didSet {
            seriesNameLabel.numberOfLines = 2
        }
    }
    
    //MARK: - favourite button layout
    
    func favAndPlayBtnLayout() {
        
        favouriteBtn.layer.cornerRadius = 12.5
        favouriteBtn.layer.shadowColor = UIColor(hexaRGB: "#F4F4F4")?.cgColor
        favouriteBtn.layer.shadowOpacity = 1.0
        favouriteBtn.layer.shadowOffset = CGSize(width: 3, height: -3)
        favouriteBtn.layer.masksToBounds = false
        
        playBtn.layer.cornerRadius = 12.5
        playBtn.layer.shadowColor = UIColor(hexaRGB: "#F4F4F4")?.cgColor
        playBtn.layer.shadowOpacity = 1.0
        playBtn.layer.shadowOffset = CGSize(width: 3, height: -3)
        playBtn.layer.masksToBounds = false
        
        
    }
    
    override func layoutSubviews() {
        
        favAndPlayBtnLayout()
        
        //podImgView.layer.cornerRadius = 10.0
        //podImgView.layer.masksToBounds = true
        
        dotLbl.layer.cornerRadius = 2.5
        dotLbl.layer.masksToBounds = true
        
        mainView.layoutSubviews()
        
    }
    
    @IBAction func favBtnClick(_ sender: Any) {
        
        if favouriteBtn.isSelected {
            
            favouriteBtn.isSelected = false
            
        }
        else {
            
            favouriteBtn.isSelected = true
            
        }
        
    }
    
    @IBAction func playBtnClick(_ sender: Any) {
    }
    
    
}
