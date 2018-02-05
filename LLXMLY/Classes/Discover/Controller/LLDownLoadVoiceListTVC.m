//
//  LLDownLoadVoiceListTVC.m
//  LLXMLY
//
//  Created by liushaohua on 2017/7/4.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLDownLoadVoiceListTVC.h"
#import "LLDownLoadDataProvider.h"
#import "LLDownLoadVoiceCellPresenter.h"
#import "LLDownLoadVoiceCell.h"

@interface LLDownLoadVoiceListTVC ()

@property (nonatomic, strong) NSArray<LLDownLoadVoiceCellPresenter *> *presenterMs;

@end

@implementation LLDownLoadVoiceListTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 80;
    __weak typeof(self) weakSelf = self;
    
    [[LLDownLoadDataProvider shareInstance] getTodayFireVoiceMsWithKey:self.loadKey result:^(NSArray<LLDownLoadVoiceModel *> *voiceMs) {
        
        NSMutableArray *presenters = [NSMutableArray array];
        for (LLDownLoadVoiceModel *voiceM in voiceMs) {
            LLDownLoadVoiceCellPresenter *presenter = [[LLDownLoadVoiceCellPresenter alloc] init];
            presenter.voiceM = voiceM;
            [presenters addObject:presenter];
        }
        weakSelf.presenterMs = presenters;
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

   return self.presenterMs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LLDownLoadVoiceCell *cell = [LLDownLoadVoiceCell cellWithTableView:tableView];
    
    LLDownLoadVoiceCellPresenter *presenter = self.presenterMs[indexPath.row];
    presenter.sortNum = indexPath.row + 1;
    [presenter bindWithCell:cell];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LLDownLoadVoiceCellPresenter *presenter = self.presenterMs[indexPath.row];
    NSLog(@"跳转到播放器界面进行播放--%@--", presenter.voiceM.title);
}

- (void)setPresenterMs:(NSArray<LLDownLoadVoiceCellPresenter *> *)presenterMs {
    _presenterMs = presenterMs;
    [self.tableView reloadData];
}

@end
