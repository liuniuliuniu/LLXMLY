//
//  LLDownLoadVoiceCell.h
//  LLXMLY
//
//  Created by liushaohua on 2017/7/4.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, LLDownLoadVoiceCellState) {
    LLDownLoadVoiceCellStateWaitDownLoad,
    LLDownLoadVoiceCellStateDownLoading,
    LLDownLoadVoiceCellStateDownLoaded,
};
@interface LLDownLoadVoiceCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, assign) LLDownLoadVoiceCellState state;
/** 声音标题 */
@property (weak, nonatomic) IBOutlet UILabel *voiceTitleLabel;
/** 声音作者 */
@property (weak, nonatomic) IBOutlet UILabel *voiceAuthorLabel;
/** 声音播放暂停按钮 */
@property (weak, nonatomic) IBOutlet UIButton *playOrPauseBtn;
/** 声音排名标签 */
@property (weak, nonatomic) IBOutlet UILabel *sortNumLabel;
/** 声音下载按钮 */
@property (weak, nonatomic) IBOutlet UIButton *downLoadBtn;

@property (nonatomic, copy) void(^playBlock)(BOOL isPlay);

@property (nonatomic, copy) void(^downLoadBlock)();



@end
