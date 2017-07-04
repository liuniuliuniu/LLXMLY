//
//  LLDiscoverViewController.m
//  LLXMLY
//
//  Created by liushaohua on 2017/7/3.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLDiscoverViewController.h"
#import "LLSubscribeViewController.h"
#import "LLSegmentBarVC.h"

#import "LLDownLoadVoiceListTVC.h"
#import "LLDownLoadDataProvider.h"


@interface LLDiscoverViewController ()

@property (nonatomic, weak) LLSegmentBarVC *segContentVC;

@property (nonatomic, strong) NSArray<LLCategoryModel *> *categoryMs;

@end

@implementation LLDiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"高仿XMLY下载听模块";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.segContentVC.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.view addSubview:self.segContentVC.view];
    // 链式编程设置属性
    [self.segContentVC.segmentBar updateWithConfig:^(LLSegmentBarConfig *config) {
        config.segmentBarBackColor([UIColor whiteColor]).itemNormalColor([UIColor blackColor]);
    }];
    
        // 发送网络请求
    __weak typeof(self) weakSelf = self;
    
    [[LLDownLoadDataProvider shareInstance] getTodayFireCategoryMs:^(NSArray<LLCategoryModel *> *categoryMs) {
        weakSelf.categoryMs = categoryMs;
    }];
    
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



- (LLSegmentBarVC *)segContentVC {
    if (!_segContentVC) {
        LLSegmentBarVC *contentVC = [[LLSegmentBarVC alloc] init];
        [self addChildViewController:contentVC];
        _segContentVC = contentVC;
    }
    return _segContentVC;
}

- (void)setCategoryMs:(NSArray<LLCategoryModel *> *)categoryMs {
    _categoryMs = categoryMs;
    
    NSInteger vcCount = _categoryMs.count;
    NSMutableArray *vcs = [NSMutableArray arrayWithCapacity:vcCount];
    for (LLCategoryModel *model in _categoryMs) {
        LLDownLoadVoiceListTVC *vc = [[LLDownLoadVoiceListTVC alloc] init];
        vc.loadKey = model.key;
        [vcs addObject:vc];
    }
    
    [self.segContentVC setUpWithItems:[categoryMs valueForKeyPath:@"name"] childVCs:vcs];
    
}



@end
