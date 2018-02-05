//
//  LLTabBarController.m
//  LLMusic
//
//  Created by liushaohua on 2017/5/11.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLTabBarController.h"
#import "LLTabBar.h"
#import "LLNavigationController.h"
#import "UIImage+LLImage.h"
#import "LLMiddleView.h"

@interface LLTabBarController ()

@end

@implementation LLTabBarController

+ (instancetype)shareInstance{
    static LLTabBarController *tabbarC;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tabbarC = [[LLTabBarController alloc]init];
    });
    return tabbarC;
}

+ (instancetype)tabBarControllerWithAddChildVCsBlock:(void (^)(LLTabBarController *))addVCBlock{

    LLTabBarController *tabbarC = [LLTabBarController new];
    if (addVCBlock) {
        addVCBlock(tabbarC);
    }
    
    return tabbarC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置tabbar
    [self setUpTabbar];
}

- (void)setUpTabbar {
    [self setValue:[[LLTabBar alloc] init] forKey:@"tabBar"];
}

/**
 *  根据参数, 创建并添加对应的子控制器
 *
 *  @param vc                需要添加的控制器(会自动包装导航控制器)
 *  @param isRequired             标题
 *  @param normalImageName   一般图片名称
 *  @param selectedImageName 选中图片名称
 */
- (void)addChildVC:(UIViewController *)vc normalImageName:(NSString *)normalImageName selectedImageName:(NSString *)selectedImageName isRequiredNavController:(BOOL)isRequired{
    
    // 是否需要导航控制器
    if (isRequired) {
        LLNavigationController *nav = [[LLNavigationController alloc]initWithRootViewController:vc];
        nav.tabBarItem = [[UITabBarItem alloc]initWithTitle:nil image:[UIImage originImageWithName:normalImageName]selectedImage:[UIImage originImageWithName:selectedImageName]];
        [self addChildViewController:nav];
    }else{
        [self addChildViewController:vc];
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex{
    [super setSelectedIndex:selectedIndex];
    UIViewController *vc = self.childViewControllers[selectedIndex];
    
    if (vc.view.tag == 666) {
        vc.view.tag = 888;
        LLMiddleView *middleView = [LLMiddleView middleView];
        middleView.middleClickBlock = [LLMiddleView shareInstance].middleClickBlock;
        middleView.isPlaying = [LLMiddleView shareInstance].isPlaying;
        middleView.middleImg = [LLMiddleView shareInstance].middleImg;
        CGRect frame = middleView.frame;
        frame.size.width = 65;
        frame.size.height = 65;
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        frame.origin.x = (screenSize.width - 65) * 0.5;
        frame.origin.y = screenSize.height - 65;
        middleView.frame = frame;
        [vc.view addSubview:middleView];
        
    }
}






@end
