//
//  CALayer+PauseAimate.h
//  LLMusic
//
//  Created by liushaohua on 2017/5/12.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (PauseAimate)

// 暂停动画
- (void)pauseAnimate;

// 恢复动画
- (void)resumeAnimate;

@end
