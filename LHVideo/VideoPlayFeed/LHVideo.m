//
//  LHVideo.m
//  LHVideo
//
//  Created by 李允 on 2017/2/21.
//  Copyright © 2017年 liyun. All rights reserved.
//

#import "LHVideo.h"

@implementation LHVideo
- (void)setVideo:(NSString *)video {
    _video = [video copy];
    
    _playItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:video]];
}
@end
