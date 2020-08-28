//
//  Extensions.swift
//  JFBanner
//
//  Created by HongXiangWen on 2020/8/8.
//  Copyright © 2020 WHX. All rights reserved.
//

import UIKit

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
