//
//  LLDownLoadVoiceCell.m
//  LLXMLY
//
//  Created by liushaohua on 2017/7/4.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLDownLoadVoiceCell.h"

@implementation LLDownLoadVoiceCell

static NSString *const cellID = @"downLoadVoiceCell";

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    LLDownLoadVoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"LLDownLoadVoiceCell" owner:nil options:nil] firstObject];
        [cell addObserver:cell forKeyPath:@"sortNumLabel.text" options:NSKeyValueObservingOptionNew context:nil];
    }
    return cell;
}

- (IBAction)downLoad {
    if (self.state == LLDownLoadVoiceCellStateWaitDownLoad) {
        if (self.downLoadBlock) {
            self.downLoadBlock();
        }
    }
}

- (IBAction)playOrPause:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (self.playBlock) {
        self.playBlock(sender.selected);
    }
    
}

- (void)setState:(LLDownLoadVoiceCellState)state {
    
    _state = state;
    switch (state) {
        case LLDownLoadVoiceCellStateWaitDownLoad:
//            NSLog(@"等待下载");
            [self removeRotationAnimation];
            [self.downLoadBtn setImage:[UIImage imageNamed:@"cell_download"] forState:UIControlStateNormal];
            break;
        case LLDownLoadVoiceCellStateDownLoading:
        {
//            NSLog(@"正在下载");
            [self.downLoadBtn setImage:[UIImage imageNamed:@"cell_download_loading"] forState:UIControlStateNormal];
            [self addRotationAnimation];
            break;
        }
        case LLDownLoadVoiceCellStateDownLoaded:
//            NSLog(@"下载完毕");
            [self removeRotationAnimation];
            [self.downLoadBtn setImage:[UIImage imageNamed:@"cell_downloaded"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    
}



- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
}

- (void)addRotationAnimation {
    [self removeRotationAnimation];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = @(0);
    animation.toValue = @(M_PI * 2.0);
    animation.duration = 10;
    animation.removedOnCompletion = NO;
    animation.repeatCount = MAXFLOAT;
    [self.downLoadBtn.imageView.layer addAnimation:animation forKey:@"rotation"];
    
}

- (void)removeRotationAnimation {
    
    [self.downLoadBtn.imageView.layer removeAllAnimations];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.playOrPauseBtn.layer.masksToBounds = YES;
    self.playOrPauseBtn.layer.borderWidth = 3;
    self.playOrPauseBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.playOrPauseBtn.layer.cornerRadius = 20;
    
}

-(void)dealloc {
    [self removeObserver:self forKeyPath:@"sortNumLabel.text"];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"sortNumLabel.text"]) {
        NSInteger sort = [change[NSKeyValueChangeNewKey] integerValue];
        if (sort == 1) {
            self.sortNumLabel.textColor = [UIColor redColor];
        }else if (sort == 2) {
            self.sortNumLabel.textColor = [UIColor orangeColor];
        }else if (sort == 3) {
            self.sortNumLabel.textColor = [UIColor greenColor];
        }else {
            self.sortNumLabel.textColor = [UIColor grayColor];
        }
        return;
    }    
}
@end
