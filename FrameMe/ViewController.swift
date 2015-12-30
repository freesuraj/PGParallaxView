//
//  ViewController.swift
//  FrameMe
//
//  Created by Suraj Pathak on 28/12/15.
//  Copyright © 2015 Suraj Pathak. All rights reserved.
//

import UIKit

class ViewController: UIViewController, PGParallaxDataSource, PGParallaxDelegate {
    
    let newsHeadlines = NewsFeeder.loadHeadlines()

    override func viewDidLoad() {
        super.viewDidLoad()
        let parallaxView = PGParallaxView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        parallaxView.registerNib(UINib(nibName: "CustomCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CustomCollectionViewCell.reuseIdentifier)
        parallaxView.datasource = self
        parallaxView.delegate = self
        self.view.addSubview(parallaxView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: PGParallaxDataSource
    func numberOfRowsInParallaxView(view: PGParallaxView) -> Int {
        return newsHeadlines.count
    }
    
    func cellForIndexPath(indexPath: NSIndexPath, inParallaxView view: PGParallaxView) -> UICollectionViewCell {
        if let cell = view.dequeueReusableCellWithReuseIdentifier(CustomCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as? CustomCollectionViewCell {
//            cell.parallaxImageView?.image = UIImage(named: "\(indexPath.row).jpg")
            cell.titleLabel.text = newsHeadlines[indexPath.row].title
            cell.webView.loadHTMLString(newsHeadlines[indexPath.row].story, baseURL: nil)
            cell.asyncLoadImageViewFromUrlString(newsHeadlines[indexPath.row].imageUrlString)
            return cell
        }
        return UICollectionViewCell()
    }
    
    // MARK: PGParallaxDelegate
    func didScrollParallaxView(view: PGParallaxView, toIndex index: Int) {
//        print("parallax view scrolled to index \(index)")
    }


}

