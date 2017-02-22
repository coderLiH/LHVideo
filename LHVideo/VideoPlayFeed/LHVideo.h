//
//  LHVideo.h
//  LHVideo
//
//  Created by 李允 on 2017/2/21.
//  Copyright © 2017年 liyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface LHVideo : NSObject
@property (nonatomic, copy) NSString *video;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) AVPlayerItem *playItem;
@end
