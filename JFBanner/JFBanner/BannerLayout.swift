//
//  BannerLayout.swift
//  JFBanner
//
//  Created by HongXiangWen on 2020/8/5.
//  Copyright © 2020 WHX. All rights reserved.
//

import UIKit

class BannerLayout: UICollectionViewFlowLayout {
        
    var itemSpacing: CGFloat = 20
    
    var scaleRate: CGFloat = 0.7
    
    var alphaRate: CGFloat = 0.7
    
    private var contentView: UICollectionView {
        guard let collectionView = collectionView else {
            fatalError("CollectionView could not be nil!")
        }
        return collectionView
    }
    
    private var insetX: CGFloat { (contentView.frame.width - itemSize.width) / 2 }
    
    private var insetY: CGFloat { (contentView.frame.height - itemSize.height) / 2 }
    
    override class var layoutAttributesClass: AnyClass { BannerAttributes.self }
    
    override init() {
        super.init()
        itemSize = CGSize(width: 1, height: 1)
        scrollDirection = .horizontal
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        if itemSize == CGSize(width: 1, height: 1) {
            itemSize = contentView.frame.size
        }
        sectionInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
        minimumLineSpacing = itemSpacing
        minimumInteritemSpacing = 0
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        return attributes.compactMap { $0.copy() as? BannerAttributes }.map { transformLayoutAttributes($0) }
    }

    private func transformLayoutAttributes(_ attributes: BannerAttributes) -> UICollectionViewLayoutAttributes {
        
        let alphaFactor: CGFloat
        let finalFrame: CGRect
        
        switch scrollDirection {
        case .horizontal:
            let centerX = contentView.contentOffset.x + insetX + itemSize.width / 2
            let itemOffset = attributes.center.x - centerX
            let offsetFactor = itemOffset / (itemSize.width + itemSpacing)
            // 计算缩放比例
            // 如果scaleRate = 0.7 缩放比例为 ... 0.49 <- 0.7 <- 1 -> 0.7 -> 0.49 ...
            let scaleFactor = pow(scaleRate, abs(offsetFactor))
            let scaleFrame = attributes.frame.scale(byX: scaleFactor, y: scaleFactor)
            // 计算平移距离
            // 当前算法平移距离只是约等于itemSpacing，如果有更好的计算方法，请联系我，谢谢！
            let translationX = -(attributes.frame.width * (1 - scaleFactor) / 2) * offsetFactor
            
            finalFrame = scaleFrame.translation(byX: translationX, y: 0)
            alphaFactor = 1 - (abs(offsetFactor) * (1 - alphaRate))
            attributes.centerX = attributes.center.x
        case .vertical:
            let centerY = contentView.contentOffset.y + insetY + itemSize.height / 2
            let itemOffset = attributes.center.y - centerY
            let offsetFactor = itemOffset / (itemSize.height + itemSpacing)
            
            let scaleFactor = pow(scaleRate, abs(offsetFactor))
            let scaleFrame = attributes.frame.scale(byX: scaleFactor, y: scaleFactor)
            let translationY = -(attributes.frame.height * (1 - scaleFactor) / 2) * offsetFactor
            
            finalFrame = scaleFrame.translation(byX: 0, y: translationY)
            alphaFactor = 1 - (abs(offsetFactor) * (1 - alphaRate))
            attributes.centerY = attributes.center.y
        @unknown default:
            fatalError("Unknown case!")
        }
        
        attributes.alpha = max(0.3, alphaFactor)
        attributes.frame = finalFrame
        
        return attributes
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var targetContentOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        guard let layoutAttributes = layoutAttributesForElements(in: contentView.bounds) as? [BannerAttributes] else {
            return targetContentOffset
        }
        guard !layoutAttributes.isEmpty else {
            return targetContentOffset
        }
        switch scrollDirection {
        case .horizontal:
            let centerX = contentView.frame.width / 2
            let proposedCenterX = proposedContentOffset.x + centerX
            let closestAttributes = layoutAttributes.sorted(by: { abs($0.centerX - proposedCenterX) < abs($1.centerX - proposedCenterX) }).first!
            targetContentOffset = CGPoint(x: closestAttributes.centerX - centerX, y: proposedContentOffset.y)
        case .vertical:
            let centerY = contentView.frame.height / 2
            let proposedCenterY = proposedContentOffset.y + centerY
            let closestAttributes = layoutAttributes.sorted(by: { abs($0.centerY - proposedCenterY) < abs($1.centerY - proposedCenterY) }).first!
            targetContentOffset = CGPoint(x: proposedContentOffset.x, y: closestAttributes.centerY - centerY)
        @unknown default:
            fatalError("Unknown case!")
        }
        return targetContentOffset
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
