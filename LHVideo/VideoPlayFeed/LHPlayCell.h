//
//  LHPlayCell.h
//  LHVideo
//
//  Created by 李允 on 2017/2/21.
//  Copyright © 2017年 liyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LHVideo.h"
#import "UIConstant.h"

UIKIT_EXTERN NSString *const kVideoPauseNotifation;

@interface LHPlayCell : UITableViewCell
@property (nonatomic, strong) LHVideo *video;
- (void)stopVideo;
@end
