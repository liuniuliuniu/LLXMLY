//
//  LLDownLoadVoiceCellPresenter.m
//  LLXMLY
//
//  Created by liushaohua on 2017/7/4.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLDownLoadVoiceCellPresenter.h"
#import "UIButton+WebCache.h"
#import "LLDownLoadManager.h"
#import "LLRemotePlayer.h"
#import "LLSqliteModelTool.h"


@interface LLDownLoadVoiceCellPresenter ()

@property (nonatomic,weak) LLDownLoadVoiceCell * cell;

@end


@implementation LLDownLoadVoiceCellPresenter

- (NSString *)title {
    return self.voiceM.title;
}

- (NSString *)authorName {
    return [NSString stringWithFormat:@"by %@", self.voiceM.nickname];
}

- (NSURL *)voiceURL {
    return [NSURL URLWithString:self.voiceM.coverSmall];
}

- (NSString *)sortNumStr {
    return [NSString stringWithFormat:@"%zd", self.sortNum];
}

- (NSURL *)playOrDownLoadURL {
    return [NSURL URLWithString:self.voiceM.playPathAacv164];
}


- (LLDownLoadVoiceCellState)cellDownLoadState {
    LLDownLoader *downLoaer = [[LLDownLoadManager shareInstance] getDownLoaderWithURL:[self playOrDownLoadURL]];
    if (downLoaer.state == LLDownLoaderStateDowning) {
        return  LLDownLoadVoiceCellStateDownLoading;
    }else if (downLoaer.state == LLDownLoaderStateSuccess  || [LLDownLoader downLoadedFileWithURL:[self playOrDownLoadURL]].length > 0) {
        return   LLDownLoadVoiceCellStateDownLoaded;
    }else {
        return  LLDownLoadVoiceCellStateWaitDownLoad;
    }
    
}

- (BOOL)isPlaying {
    if ([[self playOrDownLoadURL] isEqual:[LLRemotePlayer shareInstance].url]) {
        LLRemotePlayerState state = [LLRemotePlayer shareInstance].state;
        if (state == LLRemotePlayerStatePlaying || state == LLRemotePlayerStateLoading) {
            return YES;
        }else {
            return NO;
        }
    }else {
        return NO;
    }
}


- (void)bindWithCell: (LLDownLoadVoiceCell *)cell {
    
    self.cell = cell;
    
    cell.voiceTitleLabel.text = [self title];
    cell.voiceAuthorLabel.text = [self authorName];
    [cell.playOrPauseBtn sd_setBackgroundImageWithURL:[self voiceURL]  forState:UIControlStateNormal];
    cell.sortNumLabel.text = [self sortNumStr];
    
    // 动态计算下载状态
    cell.state = [self cellDownLoadState];
    // 动态计算播放状态
    cell.playOrPauseBtn.selected = [self isPlaying];
    
    [cell setPlayBlock:^(BOOL isPlay) {
                
        if (isPlay) {
            [[LLRemotePlayer shareInstance] playWithURL:[self playOrDownLoadURL] isCache:NO];
        }else {
            [[LLRemotePlayer shareInstance] pause];
        }
        
                [[NSNotificationCenter defaultCenter]postNotificationName:@"playState" object:@(isPlay)];
        
                [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[self voiceURL] options:0
                                                                     progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
                                                                     } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                
                                                                         [[NSNotificationCenter defaultCenter]postNotificationName:@"playImage" object:image];
        
                                                                     }];
    }];
    
    
    __weak typeof(self) weakSelf = self;
    [cell setDownLoadBlock:^{
        
        __strong typeof(weakSelf.voiceM) strongVoiceM = weakSelf.voiceM;
        [[LLDownLoadManager shareInstance] downLoadWithURL:[self playOrDownLoadURL] downLoadInfo:^(long long fileSize) {
            
            strongVoiceM.totalSize = fileSize;
            [LLSqliteModelTool saveModel:strongVoiceM uid:nil];
            
        } success:^(NSString *cacheFilePath) {
            
            strongVoiceM.isDownLoaded = YES;
            [LLSqliteModelTool saveModel:strongVoiceM uid:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadCache" object:nil];
        } failed:nil];
    }];
    
}


- (void)downLoadStateChange: (NSNotification *)notice {
    
    NSDictionary *dic = notice.userInfo;
    NSString *url = dic[@"downLoadURL"];
    if (![url isEqual:self.playOrDownLoadURL]) {
        return;
    }
    
    self.cell.state = [self cellDownLoadState];
}


- (void)playStateChange: (NSNotification *)notice {
    NSDictionary *noticeDic = notice.userInfo;
    NSURL *url = noticeDic[@"playURL"];
    
    if (![[self playOrDownLoadURL] isEqual:url]) {
        self.cell.playOrPauseBtn.selected = NO;
        return;
    }
    
    LLRemotePlayerState state = [noticeDic[@"playState"] integerValue];
    if (state == LLRemotePlayerStatePlaying || state == LLRemotePlayerStateLoading) {
        self.cell.playOrPauseBtn.selected = YES;
    }else {
        self.cell.playOrPauseBtn.selected = NO;
    }
    
}


- (instancetype)init{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downLoadStateChange:) name:kDownLoadURLOrStateChangeNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playStateChange:) name:kRemotePlayerURLOrStateChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"释放模型--%@", self.voiceM.title);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
