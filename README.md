# JFBanner

非常好用的Banner，支持无限滚动，支持卡片式缩放

## 截图

![image](https://github.com/hxwxww/JFBanner/raw/master/screenshots/screenshot.gif)

## 导入:

#### 使用`cocoaPods`:

```
pod 'JFPagingFlowLayout'
```

#### 使用`swift package manager`:

依次点击Xcode菜单：

`File` -> `Swift Packages` -> `Add Package Dependency`

在输入框中输入：`https://github.com/hxwxww/JFBanner.git`


## 用法

#### 基本用法：

- 设置`bannerView`属性：

```
	// 注册cell
	bannerView.registerCell(BannerCell.self)
	// 设置代理，必须设置dataSource并实现，否则没有数据展示
 	bannerView.dataSource = self
 	bannerView.delegate = self
 	// 更新banner
 	bannerView.reloadData()
```

- 实现`BannerViewDataSource`代理：

```
func numberOfItems(in bannerView: BannerView) -> Int {
	return colors.count
}
    
func bannerView(_ bannerView: BannerView, cellForItemAt index: Int) -> UICollectionViewCell {
	let cell = bannerView.dequeueReusableCell(for: index) as BannerCell
	cell.backgroundColor = colors[index]
	cell.label.text = "\(index + 1)"
	return cell
}
```

#### 个性化设置：

- 自定义`itemSize`:

`itemSize`默认为`bannerView`的大小，可自定义此属性：

```
bannerView.itemSize = CGSize(width: 300, height: 200)
```

- 自定义`scaleRate`:

`scaleRate`为缩放比例，默认为`0.7`，设置为`1`表示不缩放，可自定义此属性：

```
bannerView.scaleRate = 0.5
```

- 自定义`alphaRate`:

`alphaRate`为透明度比例，默认为`0.7`，设置为`1`表示不透明，可自定义此属性：

```
bannerView.alphaRate = 0.5
```

更具体的用法及参数设置，请下载 Demo 查看。
