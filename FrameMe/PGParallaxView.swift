//
//  PGParallaxView.swift
//  FrameMe
//
//  Created by Suraj Pathak on 29/12/15.
//  Copyright © 2015 Suraj Pathak. All rights reserved.
//

import UIKit

// Protocol to which every cell must confor to for the parallax effect
public protocol PGParallaxCellProtocol {
    var parallaxEffectView: UIView { get }
}

// Protocol that feeds the necessary data for the parallax view
public protocol PGParallaxDataSource {
    func numberOfRowsInParallaxView(view: PGParallaxView) -> Int
    func cellForIndexPath(indexPath: NSIndexPath, inParallaxView view: PGParallaxView) -> UICollectionViewCell
}

public protocol PGParallaxDelegate {
    func didScrollParallaxView(view: PGParallaxView, toIndex index: Int)
}

// PGParallaxView is a scrollable parallax view which was inspired by the Yahoo news parallax design
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
        
        parallaxCollectionView = collectionView
        
        self.addSubview(parallaxCollectionView!)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK : Public Methods
    public func registerClass(cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        parallaxCollectionView?.registerClass(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    public func registerNib(nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        parallaxCollectionView?.registerNib(nib, forCellWithReuseIdentifier: identifier)
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
        guard let cachedCell = cellCache.cachedView(atIndexPath: indexPath) as? UICollectionViewCell else {
            return parallaxDatasource.cellForIndexPath(indexPath, inParallaxView: self)
        }
        return cachedCell
    }
    
    private func cacheCellAroundIndexPath(cell: UICollectionViewCell, indexPath: NSIndexPath) {
        cellCache.cacheView(cell, atIndexPath: indexPath)
        if let parallaxDataSource = datasource {
            if(indexPath.row > 0) {
                let previousIndexPath = NSIndexPath(forItem: indexPath.row - 1, inSection: indexPath.section)
                cellCache.cacheView(parallaxDataSource.cellForIndexPath(previousIndexPath, inParallaxView: self), atIndexPath: previousIndexPath)
            }
            if(indexPath.row < parallaxDataSource.numberOfRowsInParallaxView(self) - 1) {
                let nextIndexPath = NSIndexPath(forItem: indexPath.row + 1, inSection: indexPath.section)
                cellCache.cacheView(parallaxDataSource.cellForIndexPath(nextIndexPath, inParallaxView: self), atIndexPath: nextIndexPath)
            }
        }
    }
    
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        currentIndex = Int(collectionView.contentOffset.x/(self.frame.width + pageSeparatorWidth))
        if let parallaxDelegate = delegate, let dataCount = self.datasource?.numberOfRowsInParallaxView(self) where currentIndex < dataCount {
            parallaxDelegate.didScrollParallaxView(self, toIndex: currentIndex)
        }
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
        
        if let leftView = self.parallaxCollectionView?.cellForItemAtIndexPath(NSIndexPath(forItem: currentIndex, inSection: 0)) as? PGParallaxCellProtocol {
            var leftViewFrame = leftView.parallaxEffectView.frame
            leftViewFrame.origin.x = leftViewMargin
            leftViewFrame.size.width = leftViewWidth
            leftView.parallaxEffectView.frame = leftViewFrame
        }
        if let dataCount = self.datasource?.numberOfRowsInParallaxView(self) where currentIndex < dataCount - 1{
            if let rightView = self.parallaxCollectionView?.cellForItemAtIndexPath(NSIndexPath(forItem: currentIndex + 1, inSection: 0)) as? PGParallaxCellProtocol {
                var righViewFrame = rightView.parallaxEffectView.frame
                righViewFrame.origin.x = rightViewMargin
                righViewFrame.size.width = rightViewWidth
                rightView.parallaxEffectView.frame = righViewFrame
            }
        }
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

internal struct PGViewCache: CustomDebugStringConvertible {
    
    private var cache: NSCache = NSCache()
    
    mutating func cacheView(view: UIView, atIndexPath indexPath: NSIndexPath) {
        if let _ = cache.objectForKey(indexPath.stringKey) {
            print("already cached at \(indexPath.stringKey)")
            return
        }
        cache.setObject(view, forKey: indexPath.stringKey)
        print("cached view at \(indexPath.stringKey)")
    }
    
    mutating func removeCachedViewAtIndexPath(atIndexPath indexPath: NSIndexPath) {
        cache.removeObjectForKey(indexPath.stringKey)
    }
    
    func cachedView(atIndexPath indexPath: NSIndexPath) -> UIView? {
        return cache.objectForKey(indexPath.stringKey) as? UIView
    }
    
    var debugDescription: String {
        return "PGViewCache-debug"
    }
}

extension NSIndexPath {
    private var stringKey: String {
        return String("\(self.section)-\(self.row)")
    }
}
