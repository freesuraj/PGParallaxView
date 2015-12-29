//
//  CustomCollectionViewCell.swift
//  FrameMe
//
//  Created by Suraj Pathak on 29/12/15.
//  Copyright © 2015 Suraj Pathak. All rights reserved.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    
    var parallaxImageView: UIImageView?
    
    static var reuseIdentifier: String {
        return "CustomCollectionViewCell"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        parallaxImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        parallaxImageView?.contentMode = .Center
        contentView.addSubview(parallaxImageView!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func layoutSubviews() {
        parallaxImageView?.clipsToBounds = true
        parallaxImageView?.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
    }
}
