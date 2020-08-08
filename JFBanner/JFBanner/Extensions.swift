//
//  Extensions.swift
//  JFBanner
//
//  Created by HongXiangWen on 2020/8/8.
//  Copyright © 2020 WHX. All rights reserved.
//

import UIKit

extension CGRect {
    
    func scale(byX x: CGFloat, y: CGFloat) -> CGRect {
        let newSize = CGSize(width: size.width * x, height: size.height * y)
        let newOrigin = CGPoint(x: minX + (size.width - newSize.width) / 2, y: minY + (size.height - newSize.height) / 2)
        return CGRect(origin: newOrigin, size: newSize)
    }
    
    func translation(byX x: CGFloat, y: CGFloat) -> CGRect {
        let newOrigin = CGPoint(x: minX + x, y: minY + y)
        return CGRect(origin: newOrigin, size: size)
    }
}

/// 滚动方向
extension UICollectionView.ScrollDirection {

    var scrollPosition: UICollectionView.ScrollPosition {
        switch self {
        case .horizontal:
            return .centeredHorizontally
        case .vertical:
            return .centeredVertically
        @unknown default:
            fatalError("Unknown case!")
        }
    }
}
