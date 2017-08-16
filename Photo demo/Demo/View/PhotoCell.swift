//
//  PhotoCell.swift
//  Demo
//
//  Created by Vinay Nation on 14/08/17.
//  Copyright © 2017 None. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet var photoView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
       // self.contentView.layer.insertSublayer(self.shadowLayer, above: self.photoView?.layer)
        self.profileImg.layer.masksToBounds = true
       
        
    }
    
    
    fileprivate var shadowLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.clear.cgColor, UIColor(white: 0, alpha: 0.7).cgColor]
        layer.locations = [0, 0.5]
        return layer
    }()
    
    
    
}
