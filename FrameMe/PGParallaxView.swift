//
//  PGParallaxView.swift
//  FrameMe
//
//  Created by Suraj Pathak on 29/12/15.
//  Copyright © 2015 Suraj Pathak. All rights reserved.
//

import UIKit

// Protocol that feeds the necessary data for the parallax view
public protocol PGParallaxDataSource {
    func numberOfRowsInParallaxView(view: PGParallaxView) -> Int
    func cellForIndexPath(indexPath: NSIndexPath, inParallaxView view: PGParallaxView) -> UICollectionViewCell
}

@objc public protocol PGParallaxDelegate {
    optional func parallaView(view: PGParallaxView, didScrollToIndex: Int)
}

// PGParallaxView is a scrollable parallax view which was inspired by the Yahoo news parallax design
public class PGParallaxView: UIView {
    
    public enum PGParallaxScrollType: Int {
        case Horizontal = 1
        case Vertical = 2
    }
    
    private var parallaxCollectionView: UICollectionView?
    
    private var parallaxScrollType: PGParallaxScrollType = .Horizontal
    
    public private(set) var currentIndex: Int = 0
    public var separatorWidth: CGFloat = 5 // a dark separator separating two pages of the parallax view
    public var datasource: PGParallaxDataSource?
    
    
    // Initialization
    public convenience init(frame: CGRect, scrollType: PGParallaxScrollType) {
        self.init(frame: frame)
        parallaxScrollType = scrollType
        
        let layout = PGParallaxCollectionViewLayout()
        layout.separatorWidth = separatorWidth
        var collectionViewFrame = frame
        collectionViewFrame.size.width += separatorWidth
        let collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.pagingEnabled = true
        
        parallaxCollectionView = collectionView
        
        self.addSubview(parallaxCollectionView!)
    }
    
    // MARK : Public Methods
    public func registerClass(cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        parallaxCollectionView?.registerClass(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    public func dequeueReusableCellWithReuseIdentifier(identifier: String, forIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let collectionView = parallaxCollectionView else {
            return UICollectionViewCell()
        }
        return collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath)
    }

}

extension PGParallaxView: UICollectionViewDataSource, UICollectionViewDelegate {
     public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let parallaxDatasource = datasource else {
            return 0
        }
        return parallaxDatasource.numberOfRowsInParallaxView(self)
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let parallaxDatasource = datasource else {
            return UICollectionViewCell()
        }
        return parallaxDatasource.cellForIndexPath(indexPath, inParallaxView: self)
    }
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        print("TODO: parallax effect when parallax view scrolls")
        currentIndex = Int(scrollView.contentOffset.x/(self.frame.width + separatorWidth))
        
    }
}

private class PGParallaxCollectionViewLayout: UICollectionViewLayout {
    
    var separatorWidth: CGFloat = 0
    var itemSize: CGSize = CGSizeZero
    
    override func prepareLayout() {
        if let cv = collectionView {
            var boundsSize = cv.bounds.size
            boundsSize.width -= separatorWidth
            itemSize = boundsSize
        }
    }
    
    override func collectionViewContentSize() -> CGSize {
        guard let cv = collectionView else {
            return CGSizeZero
        }
        let numberOfRows = cv.numberOfItemsInSection(0)
        return CGSize(width: cv.bounds.width * CGFloat(numberOfRows), height: cv.bounds.height)
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        guard let cv = collectionView else {
            return nil
        }
        let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        attributes.size = itemSize
        let attributesX = CGFloat(indexPath.row + 1) * cv.bounds.width - (cv.bounds.width - separatorWidth)/2
        attributes.center = CGPoint(x: attributesX, y: cv.bounds.height/2)
        return attributes
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let cv = collectionView else {
            return nil
        }
        var attributes: [UICollectionViewLayoutAttributes] = []
        for(var i = 0; i < cv.numberOfItemsInSection(0); i++) {
            attributes.append(self.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: i, inSection: 0))!)
        }
        return attributes
    }
}
