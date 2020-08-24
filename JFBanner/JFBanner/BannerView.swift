//
//  BannerView.swift
//  JFBanner
//
//  Created by HongXiangWen on 2020/8/5.
//  Copyright © 2020 WHX. All rights reserved.
//

import UIKit


/// 如果有任何问题，请联系我。
/// 如果觉得不错，也请给个star，谢谢！
/// https://github.com/hxwxww/JFBanner.git


///  数据源代理
public protocol BannerViewDataSource: class {
    
    func numberOfItems(in bannerView: BannerView) -> Int
    
    func bannerView(_ bannerView: BannerView, cellForItemAt index: Int) -> UICollectionViewCell
}

///  行为代理
@objc public protocol BannerViewDelegate: class {
    
    @objc optional func bannerView(_ bannerView: BannerView, didScrollItemAt index: Int)
    
    @objc optional func bannerView(_ bannerView: BannerView, didSelectItemAt index: Int)
}

private let reuseIdentifier = "com.whx.bannerCell"

open class BannerView: UIView {
    
    /// 分页控制器位置
    public enum PageControlAlignment {
        case bottomCenter
        case bottomLeft
        case bottomRight
    }
    
    // MARK: -  Public Properties

    /// 数据源代理
    open weak var dataSource: BannerViewDataSource?
    
    /// 行为代理
    open weak var delegate: BannerViewDelegate?
    
    /// 每个banner的大小，默认为整个view的大小
    open var itemSize: CGSize {
        set { layout.itemSize = newValue }
        get { layout.itemSize }
    }
    
    /// banner滚动方向，默认为`horizontal`
    open var direction: UICollectionView.ScrollDirection {
        set { layout.scrollDirection = newValue }
        get { layout.scrollDirection}
    }
    
    /// banner的间隔，默认为`20.0`
    open var itemSpacing: CGFloat {
        set { layout.itemSpacing = newValue }
        get { layout.itemSpacing }
    }
    
    /// 缩放比例，默认为`0.7`，如果不想设置缩放，请设置为`1.0`
    open var scaleRate: CGFloat {
        set { layout.scaleRate = max(0, min(1, newValue)) }
        get { layout.scaleRate }
    }
    
    /// 透明度比例，默认为`0.7`，如果不想设置透明度，请设置为`1.0`
    open var alphaRate: CGFloat {
        set { layout.alphaRate = max(0, min(1, newValue)) }
        get { layout.alphaRate }
    }
    
    /// pageControl的位置，默认为`bottomCenter`
    open var pageControlAlignment: PageControlAlignment = .bottomCenter {
        didSet {
            layoutPageControl()
        }
    }
    
    /// 是否隐藏pageControl，默认`false`
    open var isPageControlHidden: Bool = false {
        didSet {
            pageControl.isHidden = isPageControlHidden
        }
    }
    
    /// pageControl的小点的颜色，默认为`lightGray`
    open var pageIndicatorTintColor: UIColor = .lightGray {
        didSet {
            pageControl.pageIndicatorTintColor = pageIndicatorTintColor
        }
    }
    
    /// pageControl的当前的小点的颜色，默认为`white`
    open var currentPageIndicatorTintColor: UIColor = .white {
        didSet {
            pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor
        }
    }
    
    /// collectionView是否可滚动，默认为`true`
    open var isScrollEnabled: Bool = true {
        didSet {
            collectionView.isScrollEnabled = isScrollEnabled
        }
    }
    
    /// 是否无限循环，默认为`true`
    open var isInfinite: Bool = true
    
    /// 自动滚动的时间间隔，默认为`3`秒
    open var autoScrollTimeInterval: TimeInterval = 3
    
    /// banner的个数
    open var bannerCount: Int { dataSource?.numberOfItems(in: self) ?? 0 }
    
    /// 当前滚动的位置
    open var currentIndex: Int { pageControl.currentPage }

    // MARK: -  Private Properties
    
    private var collectionView: UICollectionView!
    
    private var pageControl: UIPageControl!
    
    private var layout: BannerLayout!
    
    private var pageControlConstraints: [NSLayoutConstraint] = []
            
    private var itemCount: Int { bannerCount * (isInfinite ? 100 : 1) }
    
    private var itemIndex: Int = 0

    private var autoScrollTimer: Timer?
    
    private var shouldResumeTimer: Bool = false
    
    private var isAutoScrolling: Bool { autoScrollTimer?.isValid ?? false }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    /// 更新数据，在更新属性后，请调用此方法更新界面
    open func reloadData() {
        destoryAutoScrollTimer()
        pageControl.currentPage = 0
        pageControl.numberOfPages = bannerCount
        pageControl.sizeToFit()
        collectionView.reloadData()
        if isInfinite {
            collectionView.layoutIfNeeded()
            itemIndex = itemCount / 2
            scrollItem(to: itemIndex, animated: false)
        }
    }
    
    /// 注册cell
    open func registerCell<T: UICollectionViewCell>(_ cellClass: T.Type) {
        if let _ = Bundle.main.path(forResource: "\(cellClass)", ofType: "nib") {
            let cellNib = UINib(nibName: "\(cellClass)", bundle: nil)
            collectionView.register(cellNib, forCellWithReuseIdentifier: reuseIdentifier)
        } else {
            collectionView.register(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
        }
    }
    
    /// 获取可重用的cell
    open func dequeueReusableCell<T: UICollectionViewCell>(for index: Int) -> T {
        let indexPath = IndexPath(item: index, section: 0)
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? T else {
            fatalError("Please register cell fisrt.")
        }
        return cell
    }
    
    /// 开始自动滚动，只在循环模式下有效，推荐在`reloadData`后调用此方法
    /// 也推荐在`viewWillAppear`或`viewDidAppear`中调用此方法
    open func startAutoScroll() {
        guard isInfinite else { return }
        setupAutoScrollTimer()
    }
    
    /// 停止自动滚动，只在循环模式下有效
    /// 推荐在`viewWillDisappear`或`viewDidDisappear`中调用此方法
    open func stopAutoScroll() {
        guard isInfinite else { return }
        destoryAutoScrollTimer()
    }
}

extension BannerView {
    
    private func setup() {
        backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
        
        layout = BannerLayout()
        collectionView = makeCollectionView()
        pageControl = mackPageControl()
                
        addSubview(collectionView)
        addSubview(pageControl)
        
        layoutCollectionView()
        layoutPageControl()
    }
    
    private func makeCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.decelerationRate = .fast
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = isScrollEnabled
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }
    
    private func mackPageControl() -> UIPageControl {
        let pageControl = UIPageControl(frame: .zero)
        pageControl.pageIndicatorTintColor = pageIndicatorTintColor
        pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }
    
    private func layoutCollectionView() {
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func layoutPageControl() {
        NSLayoutConstraint.deactivate(pageControlConstraints)
        switch pageControlAlignment {
        case .bottomCenter:
            pageControlConstraints = [
                pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
                pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
            ]
        case .bottomLeft:
            pageControlConstraints = [
                pageControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
            ]
        case .bottomRight:
            pageControlConstraints = [
                pageControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
            ]
        }
        NSLayoutConstraint.activate(pageControlConstraints)
    }
}

extension BannerView {
    
    private func setupAutoScrollTimer() {
        destoryAutoScrollTimer()
        let timer = Timer(timeInterval: autoScrollTimeInterval, target: self, selector: #selector(autoScrollItem), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
        autoScrollTimer = timer
    }
    
    private func destoryAutoScrollTimer() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
    
    @objc private func autoScrollItem() {
        scrollItem(to: itemIndex + 1, animated: true)
    }
    
    private func scrollItem(to index: Int, animated: Bool) {
        guard index > 0 && index < itemCount else { return }
        layout.invalidateLayout()
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: direction.scrollPosition, animated: animated)
    }
    
    private func checkWillScrollEnd() {
        guard isInfinite else { return }
        if itemIndex + 1 > itemCount - 10 || itemIndex - 1 < 10 {
            let delta = itemIndex % bannerCount
            itemIndex = itemCount / 2 + delta
            scrollItem(to: itemIndex, animated: false)
        }
    }
}

extension BannerView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCount
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return dataSource?.bannerView(self, cellForItemAt: indexPath.item % bannerCount) ?? UICollectionViewCell()
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item % bannerCount == currentIndex {
            delegate?.bannerView?(self, didSelectItemAt: currentIndex)
        } else {
            scrollViewWillBeginDragging(collectionView)
            scrollItem(to: indexPath.item, animated: true)
        }
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let centerPoint: CGPoint
        switch direction {
        case .horizontal:
            centerPoint = CGPoint(x: scrollView.contentOffset.x + scrollView.frame.width / 2, y: scrollView.frame.height / 2)
        case .vertical:
            centerPoint = CGPoint(x: scrollView.frame.width / 2, y: scrollView.contentOffset.y + scrollView.frame.height / 2)
        @unknown default:
            fatalError("Unknown case!")
        }
        guard let indexPath = collectionView.indexPathForItem(at: centerPoint) else { return }
        guard itemIndex != indexPath.item else { return }
        itemIndex = indexPath.item
        pageControl.currentPage = itemIndex % bannerCount
        delegate?.bannerView?(self, didScrollItemAt: currentIndex)
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if isAutoScrolling {
            stopAutoScroll()
            shouldResumeTimer = true
        }
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidEndDecelerating(scrollView)
        }
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if shouldResumeTimer {
            startAutoScroll()
            shouldResumeTimer = false
        }
        checkWillScrollEnd()
    }
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDidEndDecelerating(scrollView)
    }
}
