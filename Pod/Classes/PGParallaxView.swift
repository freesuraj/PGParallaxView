//
//  PGParallaxView.swift
//  FrameMe
//
//  Created by Suraj Pathak on 29/12/15.
//  Copyright © 2015 Suraj Pathak. All rights reserved.
//

import UIKit

/**
 View which wants the parallax effect on a part of the view (like an UIImageView at the top) should conform to this protocol and set such view via parallaxEffectView. If the view does not implement this protocol, whole view will be used for parallax effect.
*/
public protocol PGParallaxEffectProtocol {
    var parallaxEffectView: UIView { get }
}

/**
 Protocol that feeds the necessary data for the parallax view
*/
public protocol PGParallaxDataSource {
    /**
     Number of Scrollable Cells in the parallax view
     */
    func numberOfRowsInParallaxView(view: PGParallaxView) -> Int
    /**
     Reusable views to be passed to the parallax view.
     */
    func viewForIndexPath(indexPath: NSIndexPath, inParallaxView view: PGParallaxView) -> UIView
}

public protocol PGParallaxDelegate {
    func didScrollParallaxView(view: PGParallaxView, toIndex index: Int)
}

/**
 PGParallaxView is a scrollable parallax view which was inspired by the Yahoo news parallax design
*/
public class PGParallaxView: UIView {
    
    private var parallaxCollectionView: UICollectionView?
    
    public private(set) var currentIndex: Int = 0
    public var pageSeparatorWidth: CGFloat = 1.0
    public var datasource: PGParallaxDataSource?
    public var delegate: PGParallaxDelegate?
    
    private var cellCache: PGViewCache = PGViewCache()
    
    // Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        let layout = PGParallaxCollectionViewLayout()
        layout.separatorWidth = pageSeparatorWidth
        var collectionViewFrame = frame
        collectionViewFrame.size.width += pageSeparatorWidth
        let collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.pagingEnabled = true
        collectionView.registerClass(PGParallaxCollectionViewCell.self, forCellWithReuseIdentifier: PGParallaxCollectionViewCell.reuseIdentifier)
        
        parallaxCollectionView = collectionView
        
        self.addSubview(parallaxCollectionView!)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
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
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PGParallaxCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as? PGParallaxCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        guard let parallaxDatasource = datasource else {
            return cell
        }
        
        guard let cachedCell = cellCache.cachedView(atIndexPath: indexPath) else {
            print("cell NOT found at cache \(indexPath.stringKey)")
            let view = parallaxDatasource.viewForIndexPath(indexPath, inParallaxView: self)
            cell.setParallaxView(view)
            return cell
        }
        cell.setParallaxView(cachedCell)
        print("cell FOUND at cache \(indexPath.stringKey)")
        
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        cacheCellAroundIndexPath(cell, indexPath: indexPath)
    }
    
    public func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
    }
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x/(scrollView.frame.width + pageSeparatorWidth))
        
        let movedMargin = fmod(scrollView.contentOffset.x + scrollView.frame.width + pageSeparatorWidth, scrollView.frame.width + pageSeparatorWidth)
        let widthMargin = fmod(fabs(scrollView.contentOffset.x + pageSeparatorWidth ),scrollView.frame.width + pageSeparatorWidth)
        
        let leftViewMargin = scrollView.contentOffset.x > 0 ? movedMargin : 0.0
        let leftViewWidth = scrollView.frame.width + pageSeparatorWidth - widthMargin
        let rightViewMargin = CGFloat(0.0)
        let rightViewWidth = leftViewMargin - pageSeparatorWidth
        
        if let leftView = self.parallaxCollectionView?.cellForItemAtIndexPath(NSIndexPath(forItem: currentIndex, inSection: 0)) as? PGParallaxEffectProtocol {
            var leftViewFrame = leftView.parallaxEffectView.frame
            leftViewFrame.origin.x = leftViewMargin
            leftViewFrame.size.width = leftViewWidth
            leftView.parallaxEffectView.frame = leftViewFrame
        }
        if let dataCount = self.datasource?.numberOfRowsInParallaxView(self) where currentIndex < dataCount - 1{
            if let rightView = self.parallaxCollectionView?.cellForItemAtIndexPath(NSIndexPath(forItem: currentIndex + 1, inSection: 0)) as? PGParallaxEffectProtocol {
                var righViewFrame = rightView.parallaxEffectView.frame
                righViewFrame.origin.x = rightViewMargin
                righViewFrame.size.width = rightViewWidth
                rightView.parallaxEffectView.frame = righViewFrame
            }
        }
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x/(self.frame.width + pageSeparatorWidth))
        if let parallaxDelegate = delegate, let dataCount = self.datasource?.numberOfRowsInParallaxView(self) where currentIndex < dataCount {
            parallaxDelegate.didScrollParallaxView(self, toIndex: currentIndex)
        }
    }
}

extension PGParallaxView {
    private func cacheCellAroundIndexPath(cell: UICollectionViewCell, indexPath: NSIndexPath) {
        guard let parallaxCell = cell as? PGParallaxCollectionViewCell else {
            return
        }
        cellCache.cacheView(parallaxCell.parallaxView, atIndexPath: indexPath)
        
        if let parallaxDataSource = datasource {
            if(indexPath.row > 0) {
                let previousIndexPath = NSIndexPath(forItem: indexPath.row - 1, inSection: indexPath.section)
                cellCache.cacheView(parallaxDataSource.viewForIndexPath(previousIndexPath, inParallaxView: self), atIndexPath: previousIndexPath)
            }
            if(indexPath.row < parallaxDataSource.numberOfRowsInParallaxView(self) - 1) {
                let nextIndexPath = NSIndexPath(forItem: indexPath.row + 1, inSection: indexPath.section)
                cellCache.cacheView(parallaxDataSource.viewForIndexPath(nextIndexPath, inParallaxView: self), atIndexPath: nextIndexPath)
            }
        }
    }
}

private class PGParallaxCollectionViewCell: UICollectionViewCell, PGParallaxEffectProtocol {
    
    private var parallaxView: UIView = UIView()
    
    var parallaxEffectView: UIView {
        guard let inputParallaxView = parallaxView as? PGParallaxEffectProtocol else {
            return parallaxView
        }
        return inputParallaxView.parallaxEffectView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = UIColor.redColor()
    }
    
    convenience init(frame: CGRect, parallaxView: UIView) {
        self.init(frame: frame)
        self.parallaxView = parallaxView
        self.contentView.addSubview(parallaxView)
    }
    
    func setParallaxView(view: UIView) {
        parallaxView.removeFromSuperview()
        parallaxView = view
        self.contentView.addSubview(parallaxView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    static var reuseIdentifier: String {
        return "PGParallaxCollectionViewCell"
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

private struct PGViewCache: CustomStringConvertible {
    
    private var cache: NSCache = NSCache()
    
    mutating func cacheView(view: UIView, atIndexPath indexPath: NSIndexPath) {
        if let _ = cache.objectForKey(indexPath.stringKey) {
            return
        }
        cache.setObject(view, forKey: indexPath.stringKey)
    }
    
    mutating func removeCachedViewAtIndexPath(atIndexPath indexPath: NSIndexPath) {
        cache.removeObjectForKey(indexPath.stringKey)
    }
    
    func cachedView(atIndexPath indexPath: NSIndexPath) -> UIView? {
        return cache.objectForKey(indexPath.stringKey) as? UIView
    }
    
    var description: String {
        return "PGViewCache- \(cache.name)"
    }
}

extension NSIndexPath {
    private var stringKey: String {
        return String("\(self.section)-\(self.row)")
    }
}
