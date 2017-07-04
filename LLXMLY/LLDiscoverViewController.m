//
//  LLDiscoverViewController.m
//  LLXMLY
//
//  Created by liushaohua on 2017/7/3.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLDiscoverViewController.h"
#import "LLSubscribeViewController.h"

@interface LLDiscoverViewController ()

@end

@implementation LLDiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //
    static BOOL isPlay = NO;
    isPlay = !isPlay;
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"playState" object:@(isPlay)];
    UIImage *image = [UIImage imageNamed:@"LL_Icon"];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"playImage" object:image];
    
    [self.navigationController pushViewController:[LLSubscribeViewController new] animated:YES];
    
}


@end
