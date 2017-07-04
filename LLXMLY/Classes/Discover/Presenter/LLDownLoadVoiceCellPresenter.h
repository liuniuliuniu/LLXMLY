//
//  LLDownLoadVoiceCellPresenter.h
//  LLXMLY
//
//  Created by liushaohua on 2017/7/4.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLDownLoadVoiceModel.h"
#import "LLDownLoadVoiceCell.h"

@interface LLDownLoadVoiceCellPresenter : NSObject


@property (nonatomic, strong) LLDownLoadVoiceModel *voiceM;

@property (nonatomic, assign) NSInteger sortNum;

- (void)bindWithCell: (LLDownLoadVoiceCell *)cell;


@end
