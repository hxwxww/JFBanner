//
//  BannerAttributes.swift
//  JFBanner
//
//  Created by HongXiangWen on 2020/8/7.
//  Copyright © 2020 WHX. All rights reserved.
//

import UIKit

class BannerAttributes: UICollectionViewLayoutAttributes {
    
    var centerX: CGFloat = 0
    var centerY: CGFloat = 0
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! BannerAttributes
        copy.centerX = centerX
        copy.centerY = centerY
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let o = object as? BannerAttributes else { return false }
        return super.isEqual(o) && o.centerX == centerX && o.centerY == centerY
    }
}
