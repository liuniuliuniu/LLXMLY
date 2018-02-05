//
//  LLTabBar.m
//  LLMusic
//
//  Created by liushaohua on 2017/5/11.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLTabBar.h"
#import "LLNavigationController.h"
#import "LLMiddleView.h"

#import "UIView+LLLayout.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface LLTabBar ()

@property (nonatomic,weak) LLMiddleView * middleView;

@end


@implementation LLTabBar

- (LLMiddleView *)middleView{
    if (_middleView == nil) {
        LLMiddleView *middleView = [LLMiddleView shareInstance];
        [self addSubview:middleView];
        _middleView = middleView;
        
    }
    return _middleView;
}


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupInit];
    }
    return self;
}

- (void)setupInit{
    // 设置样式 去除tabbar上面的黑线
    self.barStyle = UIBarStyleBlack;
    
    // 设置tabbar 背景图片
    self.backgroundImage = [UIImage imageNamed:@"tabbar_bg"];
    
    // 添加按钮 准备放在中间
    CGFloat width = 65;
    CGFloat height = 65;
    
    self.middleView.frame = CGRectMake((kScreenWidth - width) * 0.5, (kScreenHeight - height), width, height);
    
}

-(void)setMiddleClickBlock:(void (^)(BOOL))middleClickBlock {
    self.middleView.middleClickBlock = middleClickBlock;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    NSInteger count = self.items.count;
    // 1 遍历所有的子空间
    NSArray *subViews = self.subviews;
    
    // 确定单个控件的大小
    CGFloat btnw = self.width / (count + 1);
    CGFloat btnh = self.height;
    CGFloat btnY = 5;
    NSInteger index = 0;
    for (UIView *subView in subViews) {
        if ([subView isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            if (index == count / 2) {
                index ++;
            }
            CGFloat btnX = index * btnw;
            subView.frame = CGRectMake(btnX, btnY, btnw, btnh);
            index ++;
        }
    }
    self.middleView.centerX = self.frame.size.width * 0.5;
    self.middleView.y = self.height - self.middleView.height;
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    // 设置允许交互的区域
    // 1. 转换点击在tabbar上的坐标点, 到中间按钮上
    CGPoint pointInMiddleBtn = [self convertPoint:point toView:self.middleView];
    
    // 2. 确定中间按钮的圆心
    CGPoint middleBtnCenter = CGPointMake(33, 33);
    
    // 3. 计算点击的位置距离圆心的距离
    CGFloat distance = sqrt(pow(pointInMiddleBtn.x - middleBtnCenter.x, 2) + pow(pointInMiddleBtn.y - middleBtnCenter.y, 2));
    
    // 4. 判定中间按钮区域之外
    if (distance > 33 && pointInMiddleBtn.y < 18) {
        return NO;
    }    
    return YES;
}





@end
