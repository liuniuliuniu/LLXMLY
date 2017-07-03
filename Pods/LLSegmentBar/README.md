<<<<<<< HEAD
# LLSegmentBar

[![CI Status](http://img.shields.io/travis/416997919@qq.com/LLSegmentBar.svg?style=flat)](https://travis-ci.org/416997919@qq.com/LLSegmentBar)
[![Version](https://img.shields.io/cocoapods/v/LLSegmentBar.svg?style=flat)](http://cocoapods.org/pods/LLSegmentBar)
[![License](https://img.shields.io/cocoapods/l/LLSegmentBar.svg?style=flat)](http://cocoapods.org/pods/LLSegmentBar)
[![Platform](https://img.shields.io/cocoapods/p/LLSegmentBar.svg?style=flat)](http://cocoapods.org/pods/LLSegmentBar)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

LLSegmentBar is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "LLSegmentBar"
```

```
// 1 设置segmentBar的frame
self.segmentVC.segmentBar.frame = CGRectMake(0, 0, 320, 35);
self.navigationItem.titleView = self.segmentVC.segmentBar;
// 2 添加控制器的V
self.segmentVC.view.frame = self.view.bounds;
[self.view addSubview:self.segmentVC.view];

// 3 设置标题
NSArray *items = @[@"item-one", @"item-two", @"item-three"];

// 4 在contentView, 展示子控制器的视图内容
UIViewController *vc1 = [UIViewController new];
vc1.view.backgroundColor = [UIColor redColor];
UIViewController *vc2 = [UIViewController new];
vc2.view.backgroundColor = [UIColor greenColor];
UIViewController *vc3 = [UIViewController new];
vc3.view.backgroundColor = [UIColor yellowColor];
[self.segmentVC setUpWithItems:items childVCs:@[vc1,vc2,vc3]];

// 5  配置基本设置  采用链式编程模式进行设置
[self.segmentVC.segmentBar updateWithConfig:^(LLSegmentBarConfig *config) {
config.itemNormalColor([UIColor blackColor]).itemSelectColor([UIColor redColor]).indicatorColor([UIColor greenColor]);
}];

```




## Author

416997919@qq.com, 416997919@qq.com

## License

LLSegmentBar is available under the MIT license. See the LICENSE file for more info.
=======
# LLSegmentBar
>>>>>>> 7e4ce6d648fefc09a01461c8ab0accfc77553327
