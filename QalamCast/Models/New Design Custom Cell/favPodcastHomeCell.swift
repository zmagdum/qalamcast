//
//  favPodcastHomeCell.swift
//  QalamCast
//
//  Created by apple on 11/08/21.
//  Copyright © 2021 Zakir Magdum. All rights reserved.
//

import UIKit

class favPodcastHomeCell: UICollectionViewCell {
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var podcastImgView: UIImageView!
    
    @IBOutlet weak var podcastTitleLbl: UILabel!
    
    @IBOutlet weak var podcastAuthorLbl: UILabel!
    
    @IBOutlet weak var dotLbl: UILabel!
    
    @IBOutlet weak var episodNumbersLbl: UILabel!
    
    
    override func layoutSubviews() {
        
        podcastImgView.layer.cornerRadius = 8.0
        podcastImgView.layer.masksToBounds = true
        
        dotLbl.layer.cornerRadius = 2.5
        dotLbl.layer.masksToBounds = true
        
    }
}
