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
    
    func viewForIndexPath(indexPath: NSIndexPath, inParallaxView view: PGParallaxView) -> UIView {
        if let cell = NSBundle.mainBundle().loadNibNamed("CustomCollectionViewCell", owner: nil, options: nil)[0] as? CustomCollectionViewCell {
            cell.frame = view.frame
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

