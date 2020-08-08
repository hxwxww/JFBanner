//
//  ViewController.swift
//  JFBannerExample
//
//  Created by HongXiangWen on 2020/8/5.
//  Copyright © 2020 WHX. All rights reserved.
//

import UIKit
import JFBanner

class ViewController: UIViewController, BannerViewDataSource, BannerViewDelegate {

    @IBOutlet weak var bannerView: BannerView!
    @IBOutlet weak var bannerView2: BannerView!
    @IBOutlet weak var bannerView3: BannerView!
    @IBOutlet weak var bannerView4: BannerView!
    
    private let colors: [UIColor] = [.red, .orange, .yellow, .green, .cyan, .blue, .purple]
    
    private let texts = [
        "用Banner，就用JFBanner",
        "JFBanner好用吗",
        "好用就给个star吧",
        "github: https://github.com/hxwxww/JFBanner.git"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView.registerCell(BannerCell.self)
        bannerView.itemSize = CGSize(width: 100, height: 200)
        bannerView.dataSource = self
        bannerView.delegate = self
        bannerView.reloadData()
        
        bannerView2.registerCell(BannerCell2.self)
        bannerView2.itemSpacing = 0
        bannerView2.scaleRate = 2
        bannerView2.isScrollEnabled = false
        bannerView2.direction = .vertical
        bannerView2.dataSource = self
        bannerView2.isPageControlHidden = true
        bannerView2.delegate = self
        bannerView2.reloadData()
        
        bannerView3.registerCell(BannerCell.self)
        bannerView3.itemSize = CGSize(width: 300, height: 200)
        bannerView3.scaleRate = 2
        bannerView3.dataSource = self
        bannerView3.delegate = self
        bannerView3.reloadData()
        
        bannerView4.registerCell(BannerCell.self)
        bannerView4.scaleRate = 1
        bannerView4.isInfinite = false
        bannerView4.dataSource = self
        bannerView4.delegate = self
        bannerView4.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bannerView.startAutoScroll()
        bannerView2.startAutoScroll()
        bannerView3.startAutoScroll()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bannerView.stopAutoScroll()
        bannerView2.stopAutoScroll()
        bannerView3.stopAutoScroll()
    }
    
    func numberOfItems(in bannerView: BannerView) -> Int {
        if bannerView == bannerView2 {
            return texts.count
        } else {
            return colors.count
        }
    }
    
    func bannerView(_ bannerView: BannerView, cellForItemAt index: Int) -> UICollectionViewCell {
        if bannerView == bannerView2 {
            let cell = bannerView.dequeueReusableCell(for: index) as BannerCell2
            cell.backgroundColor = colors[index]
            cell.textLabel.text = texts[index]
            return cell
        } else {
            let cell = bannerView.dequeueReusableCell(for: index) as BannerCell
            cell.backgroundColor = colors[index]
            cell.label.text = "\(index + 1)"
            return cell
        }
    }
    
    func bannerView(_ bannerView: BannerView, didSelectItemAt index: Int) {
        if bannerView == self.bannerView {
            print("didSelectItemAt: \(index)")
        }
    }
    
    func bannerView(_ bannerView: BannerView, didScrollItemAt index: Int) {
        if bannerView == self.bannerView {
            print("didScrollItemAt: \(index)")
        }
    }
}

