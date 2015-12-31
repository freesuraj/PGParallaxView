//
//  CustomCollectionViewCell.swift
//  FrameMe
//
//  Created by Suraj Pathak on 29/12/15.
//  Copyright © 2015 Suraj Pathak. All rights reserved.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell, PGParallaxCellProtocol {
    
    @IBOutlet weak var parallaxImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var webView: UIWebView!
    
    var parallaxEffectView: UIView {
        return parallaxImageView!
    }
    
    static var reuseIdentifier: String {
        return "CustomCollectionViewCell"
    }
    
    override func awakeFromNib() {
        parallaxImageView.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        parallaxImageView.clipsToBounds = true
    }
    
    func asyncLoadImageViewFromUrlString(urlString: String) {
        guard let url = NSURL(string: urlString) else {
            return
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            if let data = NSData(contentsOfURL: url) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.parallaxImageView.image = UIImage(data: data)
                })
            }
        })
    }
}
