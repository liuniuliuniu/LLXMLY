//
//  LLNavigationController.m
//  LLMusic
//
//  Created by liushaohua on 2017/5/11.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLNavigationController.h"
#import "LLNavBar.h"
#import "LLMiddleView.h"


@interface LLNavigationController ()<UIGestureRecognizerDelegate>

@end

@implementation LLNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        [self setValue:[[LLNavBar alloc]init] forKey:@"navigationBar"];
    }
    return self;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置手势代理
    UIGestureRecognizer *gester = self.interactivePopGestureRecognizer;
    
    // 自定义手势
    // 手势加在谁身上, 手势执行谁的什么方法
    UIPanGestureRecognizer *panGester = [[UIPanGestureRecognizer alloc] initWithTarget:gester.delegate action:NSSelectorFromString(@"handleNavigationTransition:")];
    // 其实就是控制器的容器视图
    [gester.view addGestureRecognizer:panGester];
    
    gester.delaysTouchesBegan = YES;
    panGester.delegate = self;
}

- (void)back {
    [self popViewControllerAnimated:YES];
}

/**
 *  当控制器, 拿到导航控制器(需要是这个子类), 进行压栈时, 都会调用这个方法
 *
 *  @param viewController 要压栈的控制器
 *  @param animated       动画
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{

    if (self.childViewControllers.count > 0) {
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left_back_n"] style:0 target:self action:@selector(back)];
        viewController.hidesBottomBarWhenPushed = YES;
    }
    
    [super pushViewController:viewController animated:animated];
    
    if (viewController.view.tag == 666) {
        viewController.view.tag = 888;
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
        [viewController.view addSubview:middleView];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if(self.childViewControllers.count == 1) {
        return NO;
    }
    return YES;
}

@end
