//
//  LLMiddleView.m
//  LLMusic
//
//  Created by liushaohua on 2017/5/11.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLMiddleView.h"
#import "CALayer+PauseAimate.h"

@interface LLMiddleView()

/**
 中间的播放内容视图
 */
@property (weak, nonatomic) IBOutlet UIImageView *middleImageView;

/**
 播放按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *playBtn;

@end

@implementation LLMiddleView

static LLMiddleView *_shareInstance;

+ (instancetype)shareInstance{
    if (_shareInstance == nil) {
        _shareInstance = [LLMiddleView middleView];
    }
    return _shareInstance;
}

+ (instancetype)middleView {
    LLMiddleView *middleView = [[[NSBundle mainBundle] loadNibNamed:@"LLMiddleView" owner:nil options:nil] firstObject];
    return middleView;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.middleImageView.layer.masksToBounds = YES;
    self.middleImg = self.middleImageView.image;
    [self.middleImageView.layer removeAnimationForKey:@"playAnnimation"];
    CABasicAnimation *basicAnnimation = [[CABasicAnimation alloc]init];
    basicAnnimation.keyPath = @"transform.rotation.z";
    
    basicAnnimation.fromValue = @0;
    
    basicAnnimation.toValue = @(M_PI * 2);
    
    basicAnnimation.duration = 30;
    
    basicAnnimation.repeatCount = MAXFLOAT;
    
    basicAnnimation.removedOnCompletion = NO;
    
    [self.middleImageView.layer addAnimation:basicAnnimation forKey:@"playAnnimation"];
    
    [self.middleImageView.layer pauseAnimate];
    
    [self.playBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isPlayerPlay:) name:@"playState" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPlayImage:) name:@"playImage" object:nil];
}


- (void)isPlayerPlay:(NSNotification *)notification {
    BOOL isPlay = [notification.object boolValue];
    self.isPlaying = isPlay;
}

- (void)setPlayImage:(NSNotification *)notification {
    UIImage *image = notification.object;
    self.middleImg = image;
}

- (void)btnClick:(UIButton *)btn {
    if (self.middleClickBlock) {
        self.middleClickBlock(!self.isPlaying);
    }
}

- (void)setIsPlaying:(BOOL)isPlaying{
    if (_isPlaying == isPlaying) {
        return;
    }
    _isPlaying = isPlaying;
    
    if (isPlaying) {
        [self.playBtn setImage:nil forState:UIControlStateNormal];
        // 开始动画
        [self.middleImageView.layer resumeAnimate];
    }else{
        UIImage *image = [UIImage imageNamed:@"tabbar_np_play"];
        [self.playBtn setImage:image forState:UIControlStateNormal];
        // 暂停动画
        [self.middleImageView.layer pauseAnimate];
    }
}

- (void)setMiddleImg:(UIImage *)middleImg{
    _middleImg = middleImg;
    self.middleImageView.image = middleImg;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.middleImageView.layer.cornerRadius = self.middleImageView.frame.size.width * 0.5;

}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
