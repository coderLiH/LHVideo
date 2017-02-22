//
//  LHVideoList.m
//  LHVideo
//
//  Created by 李允 on 2017/2/21.
//  Copyright © 2017年 liyun. All rights reserved.
//

#import "LHVideoList.h"

@interface LHVideoList ()<UITableViewDataSource, UITableViewDelegate>

@end
static NSString *LHPlayCellReuseId = @"LHPlayCellReuse";
@implementation LHVideoList

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        self.dataSource = self;
        self.delegate = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self registerClass:[LHPlayCell class] forCellReuseIdentifier:LHPlayCellReuseId];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LHPlayCell *cell = [tableView dequeueReusableCellWithIdentifier:LHPlayCellReuseId forIndexPath:indexPath];
    LHVideo *video = self.videos[indexPath.row];
    cell.video = video;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    LHVideo *video = self.videos[indexPath.row];
    return video.height + UI_MARGIN;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    LHPlayCell *lastCell = (LHPlayCell *)cell;
    [lastCell stopVideo];
}
@end
