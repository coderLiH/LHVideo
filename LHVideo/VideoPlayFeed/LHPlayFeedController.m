//
//  LHPlayFeedController.m
//  LHVideo
//
//  Created by 李允 on 2017/2/20.
//  Copyright © 2017年 liyun. All rights reserved.
//

#import "LHPlayFeedController.h"
#import "UIView+AutoLayout.h"
#import "UIConstant.h"
#import "LHVideoList.h"

@interface LHPlayFeedController () 
@property (nonatomic, strong) LHVideoList *rootList;
@property (nonatomic, strong) NSMutableArray *videos;
@end

@implementation LHPlayFeedController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _rootList = [[LHVideoList alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:_rootList];
//    [_rootList autoPinToTopLayoutGuideOfViewController:self withInset:0];
    [_rootList autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view];
    [_rootList autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view];
    [_rootList autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.view];
    [_rootList autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view];
    _rootList.videos = self.videos;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:backButton];
    [backButton setImage:[UIImage imageNamed:@"video_back"] forState:UIControlStateNormal];
    [backButton autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view withOffset:2 * UI_MARGIN];
    [backButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view withOffset:UI_MARGIN];
    [backButton addTarget:self action:@selector(videoViewBack) forControlEvents:UIControlEventTouchUpInside];
}

- (void)videoViewBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSMutableArray *)videos {
    if (!_videos) {
        _videos = [NSMutableArray array];
        
        LHVideo *video1 = [[LHVideo alloc] init];
        video1.video = @"https://ts.zlimg.com/v/disinfection.mp4";
        [_videos addObject:video1];
        
        LHVideo *video2 = [[LHVideo alloc] init];
        video2.video = @"https://ts.zlimg.com/v/report.mp4";
        [_videos addObject:video2];
        
        LHVideo *video3 = [[LHVideo alloc] init];
        video3.video = @"http://ts.zlimg.com/t/10129990002/v1.mp4";
        [_videos addObject:video3];
        
        LHVideo *video4 = [[LHVideo alloc] init];
        video4.video = @"http://ts.zlimg.com/t/10069990017/v1.mp4";
        [_videos addObject:video4];
        
        LHVideo *video5 = [[LHVideo alloc] init];
        video5.video = @"http://ts.zlimg.com/t/10129990024/v1.mp4";
        [_videos addObject:video5];
        
        LHVideo *video6 = [[LHVideo alloc] init];
        video6.video = @"https://ts.zlimg.com/t/10360960061/v1.mp4";
        [_videos addObject:video6];
        
        video1.height = video2.height = video3.height = video4.height = video5.height = video6.height = UI_SCREEN_WIDTH / 1.74;
    }
    return _videos;
}
@end
