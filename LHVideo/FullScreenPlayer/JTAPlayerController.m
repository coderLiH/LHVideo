//
//  JTAPlayerController.m
//  toy
//
//  Created by 李允 on 2016/12/19.
//  Copyright © 2016年 liyun. All rights reserved.
//

#import "JTAPlayerController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIConstant.h"
#import "UIFont+Adaption.h"
#import "UIView+Frame.h"

#define TimeCountAreaWidth                60

@interface JTAPlayerController ()
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playItem;
@property (nonatomic, strong) AVPlayerLayer *playLayer;
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, assign) BOOL playing;

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIView *controlView;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UILabel *currentTimeView;
@property (nonatomic, strong) UILabel *totalTimeView;
@property (nonatomic, strong) UIProgressView *bufferView;
@property (nonatomic, strong) UISlider *progressView;
@property (nonatomic, assign) BOOL userDragging;
@end

@implementation JTAPlayerController
-(instancetype)initWithContentURL:(NSURL *)url {
    if (self = [super init]) {
        self.view.backgroundColor = [UIColor blackColor];
        _playItem = [AVPlayerItem playerItemWithURL:url];
        _player = [AVPlayer playerWithPlayerItem:_playItem];
        _playLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _playLayer.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT);
        [self.view.layer addSublayer:_playLayer];
        
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:_backButton];
        [_backButton setImage:[UIImage imageNamed:@"video_back"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(videoViewBack) forControlEvents:UIControlEventTouchUpInside];
        _backButton.frame = CGRectMake(UI_MARGIN, UI_MARGIN, _backButton.imageView.image.size.width + UI_MARGIN, _backButton.imageView.image.size.height + UI_MARGIN);
        
        _controlView = [[UIView alloc] init];
        [self.view addSubview:_controlView];
        _controlView.backgroundColor = UIColorFromRGBA(0x000000, 0.6);
        _controlView.frame = CGRectMake(0, UI_SCREEN_HEIGHT - UI_TOOLBAR_HEIGHT, UI_SCREEN_WIDTH, UI_TOOLBAR_HEIGHT);
        _controlView.layer.cornerRadius = 5;
        
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_controlView addSubview:_playButton];
        [_playButton setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(videoControlPlay) forControlEvents:UIControlEventTouchUpInside];
        _playButton.frame = CGRectMake(UI_MARGIN, 0, UI_TOOLBAR_HEIGHT, UI_TOOLBAR_HEIGHT);
        
        UIView *liner = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_playButton.frame), UI_MARGIN * 1.6, 0.5, 12)];
        liner.backgroundColor = UIColorFromRGBA(0xffffff, 0.2);
        [_controlView addSubview:liner];
        
        _currentTimeView = [[UILabel alloc] init];
        [_controlView addSubview:_currentTimeView];
        _currentTimeView.textColor = UIColorFromRGB(0xf0f0f0);
        _currentTimeView.font = [UIFont fontWithPX:24];
        _currentTimeView.text = @"00:00";
        [self fitCurrent];
        
        _bufferView = [[UIProgressView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_playButton.frame) + TimeCountAreaWidth, (UI_TOOLBAR_HEIGHT - 2) / 2, UI_SCREEN_WIDTH - 2 * TimeCountAreaWidth - UI_TOOLBAR_HEIGHT - 2 * UI_MARGIN, 2)];
        _bufferView.progressTintColor = UIColorFromRGB(0xb3b3b3);
        _bufferView.trackTintColor = UIColorFromRGB(0xb3b3b3);
        [_controlView addSubview:_bufferView];
        
        _totalTimeView = [[UILabel alloc] init];
        [_controlView addSubview:_totalTimeView];
        _totalTimeView.textColor = UIColorFromRGB(0xf0f0f0);
        _totalTimeView.font = [UIFont fontWithPX:24];
        _totalTimeView.text = @"00:00";
        [self fitTotal];
        
        _progressView = [[UISlider alloc] initWithFrame:CGRectMake(_bufferView.x - 2, 0, _bufferView.width + 4, UI_TOOLBAR_HEIGHT)];
        _progressView.maximumTrackTintColor = [UIColor clearColor];
        _progressView.minimumTrackTintColor = UIColorFromRGB(0xfed130);
        [_progressView setThumbImage:[UIImage imageNamed:@"video_progress"] forState:UIControlStateNormal];
        [_controlView addSubview:_progressView];
        _progressView.userInteractionEnabled = NO;
        [_progressView addTarget:self action:@selector(progressUserBeginDrag) forControlEvents:UIControlEventTouchDown];
        [_progressView addTarget:self action:@selector(progressUserEndDrag) forControlEvents:UIControlEventTouchUpInside];
        [_progressView addTarget:self action:@selector(progressUserEndDrag) forControlEvents:UIControlEventTouchUpOutside];
        [_progressView addTarget:self action:@selector(progressUserEndDrag) forControlEvents:UIControlEventTouchCancel];
        [_progressView addTarget:self action:@selector(progressUserChange) forControlEvents:UIControlEventValueChanged];
        
        [_playItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [_playItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        
        [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchControlsHidden)]];
    }
    return self;
}

#pragma mark device and view
- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceRotate) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)videoViewBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)switchControlsHidden {
    if (_backButton.hidden) {
        _backButton.hidden = NO;
        _controlView.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^{
            _backButton.alpha = 1.0;
            _controlView.alpha = 1.0;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            _backButton.alpha = 0.0;
            _controlView.alpha = 0.0;
        } completion:^(BOOL finished) {
            _backButton.hidden = YES;
            _controlView.hidden = YES;
        }];
    }
}

#pragma mark video control
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_player play];
    _playing = YES;
    [_playButton setImage:[UIImage imageNamed:@"video_pause"] forState:UIControlStateNormal];
}

- (void)progressUserBeginDrag {
    _userDragging = YES;
}

- (void)progressUserEndDrag {
    _userDragging = NO;
    int64_t totalSecond = _playItem.duration.value / _playItem.duration.timescale;
    int64_t showCurrentSec = totalSecond * _progressView.value;
    [_player seekToTime:CMTimeMake(showCurrentSec, 1)];
}

- (void)progressUserChange {
    int64_t totalSecond = _playItem.duration.value / _playItem.duration.timescale;
    int64_t showCurrentSec = totalSecond * _progressView.value;
    NSString *currentTime = [self convertTime:showCurrentSec];
    _currentTimeView.text = currentTime;
    [self fitCurrent];
}

- (void)videoControlPlay {
    if (_playing) {
        [_player pause];
        _playing = NO;
        [_playButton setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateNormal];
    } else {
        [_player play];
        _playing = YES;
        [_playButton setImage:[UIImage imageNamed:@"video_pause"] forState:UIControlStateNormal];
    }
}

#pragma mark observer
#pragma mark device
- (void)deviceRotate {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    // all
    CGAffineTransform transform = CGAffineTransformIdentity;
    // video
    CGRect videoFrame = CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT);
    
    // back button
    CGPoint backOrigin = CGPointMake(UI_MARGIN, UI_MARGIN);
    
    // control bar
    CGPoint controlCenter = CGPointMake(UI_SCREEN_WIDTH / 2, UI_SCREEN_HEIGHT - UI_TOOLBAR_HEIGHT / 2);
    
    if (orientation == UIDeviceOrientationLandscapeLeft) {
        transform = CGAffineTransformMakeRotation(M_PI_2);
        videoFrame = CGRectMake(0, 0, UI_SCREEN_HEIGHT, UI_SCREEN_WIDTH);
        backOrigin = CGPointMake(UI_SCREEN_WIDTH - UI_MARGIN - _backButton.width, UI_MARGIN);
        controlCenter = CGPointMake(UI_TOOLBAR_HEIGHT / 2, UI_SCREEN_HEIGHT / 2);
    } else if (orientation == UIDeviceOrientationLandscapeRight) {
        transform = CGAffineTransformMakeRotation(-M_PI_2);
        videoFrame = CGRectMake(0, 0, UI_SCREEN_HEIGHT, UI_SCREEN_WIDTH);
        backOrigin = CGPointMake(UI_MARGIN, UI_SCREEN_HEIGHT - UI_MARGIN - _backButton.width);
        controlCenter = CGPointMake(UI_SCREEN_WIDTH - UI_TOOLBAR_HEIGHT / 2, UI_SCREEN_HEIGHT / 2);
    }
    if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
        [_playLayer setAffineTransform:transform];
        _playLayer.bounds = videoFrame;
        
        [UIView animateWithDuration:0.2 animations:^{
            _backButton.transform = transform;
            _backButton.origin = backOrigin;
            
            _controlView.transform = transform;
            _controlView.center = controlCenter;
        }];
    }
}

#pragma mark video
- (void)videoEnd {
    _playing = NO;
    [_playButton setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateNormal];
    [_player seekToTime:CMTimeMake(0, 1)];
}
- (void)videoChanged {
    if (_userDragging) return;
    int64_t currentSecond = _playItem.currentTime.value / _playItem.currentTime.timescale;
    NSString *currentTime = [self convertTime:currentSecond];
    _currentTimeView.text = currentTime;
    [self fitCurrent];
    int64_t totalSecond = _playItem.duration.value / _playItem.duration.timescale;
    _progressView.value = currentSecond * 1.0 / totalSecond;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            CMTime duration = playerItem.duration;
            int64_t totalSecond = duration.value / duration.timescale;
            _totalTimeView.text = [self convertTime:totalSecond];
            [self fitTotal];
            _progressView.userInteractionEnabled = YES;
            
            __weak typeof(self) weakS = self;
            [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
                [weakS videoChanged];
            }];
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval timeInterval = startSeconds + durationSeconds;
        CMTime duration = playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [_bufferView setProgress:timeInterval / totalDuration animated:YES];
    }
}

#pragma mark private
- (NSString *)convertTime:(int64_t)time {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        return [NSString stringWithFormat:@"%02tu:%02tu",time/60, time%60];
    } else {
        return [NSString stringWithFormat:@"%02lld:%02lld",time/60, time%60];
    }
}

- (void)fitCurrent {
    [_currentTimeView sizeToFit];
    _currentTimeView.center = CGPointMake(CGRectGetMaxX(_playButton.frame) + TimeCountAreaWidth / 2, UI_TOOLBAR_HEIGHT / 2);
}

- (void)fitTotal {
    [_totalTimeView sizeToFit];
    _totalTimeView.center = CGPointMake(UI_SCREEN_WIDTH - UI_MARGIN - TimeCountAreaWidth / 2, UI_TOOLBAR_HEIGHT / 2);
}

- (void)dealloc {
    [_playItem removeObserver:self forKeyPath:@"status"];
    [_playItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}
@end
