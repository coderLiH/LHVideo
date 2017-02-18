//
//  ViewController.m
//  LHVideo
//
//  Created by 李允 on 2017/2/17.
//  Copyright © 2017年 liyun. All rights reserved.
//

#import "ViewController.h"
#import "JTAPlayerController.h"

@interface ViewController ()

@end

@implementation ViewController
- (IBAction)fullScreenVideo:(id)sender {
    JTAPlayerController *player = [[JTAPlayerController alloc] initWithContentURL:[NSURL URLWithString:@"https://ts.zlimg.com/v/disinfection.mp4"]];
    [self presentViewController:player animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
