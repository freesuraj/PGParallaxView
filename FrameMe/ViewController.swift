//
//  ViewController.swift
//  FrameMe
//
//  Created by Suraj Pathak on 28/12/15.
//  Copyright © 2015 Suraj Pathak. All rights reserved.
//

import UIKit

class ViewController: UIViewController, PGParallaxDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        let parallaxView = PGParallaxView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height), scrollType: .Horizontal)
        parallaxView.registerClass(CustomCollectionViewCell.self, forCellWithReuseIdentifier: CustomCollectionViewCell.reuseIdentifier)
        parallaxView.datasource = self
        self.view.addSubview(parallaxView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: PGParallaxDataSource
    
    func numberOfRowsInParallaxView(view: PGParallaxView) -> Int {
        return 5
    }
    
    func cellForIndexPath(indexPath: NSIndexPath, inParallaxView view: PGParallaxView) -> UICollectionViewCell {
        if let cell = view.dequeueReusableCellWithReuseIdentifier(CustomCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as? CustomCollectionViewCell {
            cell.parallaxImageView?.image = UIImage(named: "\(indexPath.row).jpg")
            return cell
        }
        return UICollectionViewCell()
    }


}

