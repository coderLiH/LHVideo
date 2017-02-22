//
//  LHPlayCell.m
//  LHVideo
//
//  Created by 李允 on 2017/2/21.
//  Copyright © 2017年 liyun. All rights reserved.
//

#import "LHPlayCell.h"
#import "UIView+AutoLayout.h"
#import "UIFont+Adaption.h"

@interface LHPlayCell ()
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playLayer;

@property (nonatomic, strong) UIView *controlView;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UILabel *currentTimeView;
@property (nonatomic, strong) UILabel *totalTimeView;
@property (nonatomic, strong) UIProgressView *bufferView;
@property (nonatomic, strong) UISlider *progressView;

@property (nonatomic, assign) BOOL userDragging;
@end
NSString *const kVideoPauseNotifation = @"VideoPauseNotifation";
@implementation LHPlayCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _player = [AVPlayer playerWithPlayerItem:nil];
        _playLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        [self.contentView.layer addSublayer:_playLayer];
        
        _controlView = [[UIView alloc] init];
        [self.contentView addSubview:_controlView];
        [_controlView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.contentView];
        [_controlView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.contentView];
        [_controlView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView];
        [_controlView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.contentView withOffset:-UI_MARGIN];
        
        _playButton = [[UIButton alloc] init];
        [self.contentView addSubview:_playButton];
        [_playButton autoCenterInSuperview];
        [_playButton setImage:[UIImage imageNamed:@"list_play"] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
        
        _currentTimeView = [[UILabel alloc] init];
        [_controlView addSubview:_currentTimeView];
        _currentTimeView.textColor = UIColorFromRGB(0xf0f0f0);
        _currentTimeView.font = [UIFont fontWithPX:24];
        _currentTimeView.text = @"00:00";
        [_currentTimeView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:_controlView withOffset:UI_MARGIN];
        [_currentTimeView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:_controlView withOffset:-UI_MARGIN];
        
        _totalTimeView = [[UILabel alloc] init];
        [_controlView addSubview:_totalTimeView];
        _totalTimeView.textColor = UIColorFromRGB(0xf0f0f0);
        _totalTimeView.font = [UIFont fontWithPX:24];
        _totalTimeView.text = @"00:00";
        [_totalTimeView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:_controlView withOffset:-UI_MARGIN];
        [_totalTimeView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:_controlView withOffset:-UI_MARGIN];
        
        _bufferView = [[UIProgressView alloc] initWithFrame:CGRectZero];
        _bufferView.progressTintColor = UIColorFromRGB(0xb3b3b3);
        _bufferView.trackTintColor = UIColorFromRGB(0xf0f0f0);
        [_controlView addSubview:_bufferView];
        [_bufferView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:_currentTimeView];
        [_bufferView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_currentTimeView withOffset:UI_MARGIN];
        [_bufferView autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:_totalTimeView withOffset:-UI_MARGIN];
        [_bufferView autoSetDimension:ALDimensionHeight toSize:2];
        
        _progressView = [[UISlider alloc] initWithFrame:CGRectZero];
        _progressView.maximumTrackTintColor = [UIColor clearColor];
        _progressView.minimumTrackTintColor = UIColorFromRGB(0xfed130);
        [_progressView setThumbImage:[UIImage imageNamed:@"video_progress"] forState:UIControlStateNormal];
        [_controlView addSubview:_progressView];
        [_progressView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:_bufferView withOffset:-1];
        [_progressView autoAlignAxis:ALAxisVertical toSameAxisOfView:_bufferView];
        [_progressView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:_bufferView withOffset:8];
        [_progressView autoSetDimension:ALDimensionHeight toSize:UI_TOOLBAR_HEIGHT];
        _progressView.userInteractionEnabled = NO;
        [_progressView addTarget:self action:@selector(progressUserBeginDrag) forControlEvents:UIControlEventTouchDown];
        [_progressView addTarget:self action:@selector(progressUserEndDrag) forControlEvents:UIControlEventTouchUpInside];
        [_progressView addTarget:self action:@selector(progressUserEndDrag) forControlEvents:UIControlEventTouchUpOutside];
        [_progressView addTarget:self action:@selector(progressUserEndDrag) forControlEvents:UIControlEventTouchCancel];
        [_progressView addTarget:self action:@selector(progressUserChange) forControlEvents:UIControlEventValueChanged];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVideo) name:kVideoPauseNotifation object:nil];
        
        _controlView.hidden = YES;
        _controlView.alpha = 0.0;
        [self.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchControlsHidden)]];
    }
    return self;
}

- (void)switchControlsHidden {
    
    if (_controlView.hidden) {
        _controlView.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^{
            _controlView.alpha = 1.0;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            _controlView.alpha = 0.0;
        } completion:^(BOOL finished) {
            _controlView.hidden = YES;
        }];
    }
}

#pragma mark control
- (void)progressUserBeginDrag {
    _userDragging = YES;
}

- (void)progressUserEndDrag {
    _userDragging = NO;
    int64_t totalSecond = _video.playItem.duration.value / _video.playItem.duration.timescale;
    int64_t showCurrentSec = totalSecond * _progressView.value;
    [_player seekToTime:CMTimeMake(showCurrentSec, 1)];
    [_player play];
}

- (void)progressUserChange {
    int64_t totalSecond = _video.playItem.duration.value / _video.playItem.duration.timescale;
    int64_t showCurrentSec = totalSecond * _progressView.value;
    NSString *currentTime = [self convertTime:showCurrentSec];
    _currentTimeView.text = currentTime;
}

- (void)playVideo {
    [[NSNotificationCenter defaultCenter] postNotificationName:kVideoPauseNotifation object:nil];
    [_player replaceCurrentItemWithPlayerItem:_video.playItem];
    _playButton.hidden = YES;
    [_player play];
    [_video.playItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [_video.playItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    _controlView.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        _controlView.alpha = 1.0;
    }];
}

- (void)stopVideo {
    _playButton.hidden = NO;
    _controlView.hidden = YES;
    _controlView.alpha = 0.0;
    [_player pause];
    [_player replaceCurrentItemWithPlayerItem:nil];
    @try {
        [_video.playItem removeObserver:self forKeyPath:@"status"];
        [_video.playItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    } @catch (NSException *exception) {} @finally {}
}

#pragma mark video
- (void)setVideo:(LHVideo *)video {
    _video = video;
    
    _playLayer.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, video.height);
}

- (void)videoChanged {
    if (_userDragging) return;
    int64_t currentSecond = 0;
    if (_video.playItem.currentTime.timescale) {
        currentSecond = _video.playItem.currentTime.value / _video.playItem.currentTime.timescale;
        NSString *currentTime = [self convertTime:currentSecond];
        _currentTimeView.text = currentTime;
    }
    if (_video.playItem.duration.timescale) {
        int64_t totalSecond = _video.playItem.duration.value / _video.playItem.duration.timescale;
        [_progressView setValue:currentSecond * 1.0 / totalSecond animated:YES];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            CMTime duration = playerItem.duration;
            int64_t totalSecond = duration.value / duration.timescale;
            _totalTimeView.text = [self convertTime:totalSecond];
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

- (void)dealloc {
    @try {
        [_video.playItem removeObserver:self forKeyPath:@"status"];
        [_video.playItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    } @catch (NSException *exception) {} @finally {}
}
@end
