//
//  PGStickyHeader.swift
//  FrameMe
//
//  Created by Suraj Pathak on 31/12/15.
//  Copyright © 2015 Suraj Pathak. All rights reserved.
//

import UIKit

class PGParallaxHeaderFlowLayout: UICollectionViewFlowLayout {
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let layoutCollectionView = self.collectionView,
              let attributes = super.layoutAttributesForElementsInRect(rect) else {
            return nil
        }
        
        let insets = layoutCollectionView.contentInset
        let offset = layoutCollectionView.contentOffset
        let minY = -insets.top
        for attr in attributes {
            if attr.representedElementKind == UICollectionElementKindSectionHeader {
                let headerSize = headerReferenceSize
                var headerRect = attr.frame
                if offset.y < minY {
                    let deltaY =  fabs(offset.y - minY)
                    headerRect.size.height = max(minY, headerSize.height + deltaY)
                    headerRect.origin.y -= deltaY
                    attr.frame = headerRect
                } else if offset.y > minY {
                    let deltaY =  fabs(offset.y - minY)
                    headerRect.size.height = max(minY, headerSize.height - deltaY)
                    headerRect.origin.y += deltaY
                    attr.frame = headerRect
                }
                
                break
            }
        }
        
        return attributes
    }
}

class PGParallaxTableViewHeader: UIView, UIScrollViewDelegate {
    
    var tableView: UITableView?
    var referenceHeight: CGFloat?
    
    let parallaxDeltaFactor: CGFloat = 0.5
    
    func updateHeaderView() {
        guard let tableView = self.tableView,
            let referenceHeight = self.referenceHeight else {
            return
        }
        let offset = tableView.contentOffset
        var headerRect = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: referenceHeight)
        
        if offset.y < 0 {
            let delta = fabs(min(0.0, tableView.contentOffset.y))
            headerRect.size.height += delta
            headerRect.origin.y -= delta
            self.frame = headerRect
            self.clipsToBounds = false
        } else if offset.y > 0 {
            headerRect.origin.y = max(tableView.contentOffset.y * parallaxDeltaFactor, 0)
            self.frame = headerRect
            self.clipsToBounds = true
        }
    
    }
}