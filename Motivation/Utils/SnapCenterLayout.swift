//
//  SnapCenterLayout.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import UIKit

final class SnapCenterLayout: UICollectionViewFlowLayout {
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset,
                                             withScrollingVelocity: velocity)
        }
        
        let parent = super.targetContentOffset(forProposedContentOffset: proposedContentOffset,
                                               withScrollingVelocity: velocity)
        let itemSpace = QuoteCell.size.height + minimumInteritemSpacing
        var currentItemIdy = round(collectionView.contentOffset.y / itemSpace)
        
        let vY = velocity.y
        if vY > 0 {
            currentItemIdy += 1
        } else if vY < 0 {
            currentItemIdy -= 1
        }
        
        let nearestPageOffset = currentItemIdy * itemSpace
        
        return CGPoint(x: parent.x,
                       y: nearestPageOffset)
    }
}
