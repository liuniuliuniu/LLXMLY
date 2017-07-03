//
//  NSURL+LLAudio.h
//  LLXMLY
//
//  Created by liushaohua on 2017/7/3.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (LLAudio)

- (NSURL *)streamingURL;

- (NSURL *)httpURL;

@end
