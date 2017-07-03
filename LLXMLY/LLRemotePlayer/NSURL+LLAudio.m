//
//  NSURL+LLAudio.m
//  LLXMLY
//
//  Created by liushaohua on 2017/7/3.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "NSURL+LLAudio.h"

@implementation NSURL (LLAudio)

- (NSURL *)streamingURL {
    
    NSURLComponents *commpents = [NSURLComponents componentsWithString:self.absoluteString];
    [commpents setScheme:@"streaming"];
    
    return [commpents URL];
    
}

- (NSURL *)httpURL {
    NSURLComponents *commpents = [NSURLComponents componentsWithString:self.absoluteString];
    [commpents setScheme:@"http"];
    
    return [commpents URL];
}


@end
