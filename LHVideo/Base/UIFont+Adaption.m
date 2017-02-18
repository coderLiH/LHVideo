//
//  UIFont+Adaption.m
//  toy
//
//  Created by qmk on 15/7/27.
//  Copyright (c) 2015年 liyun. All rights reserved.
//

#import "UIFont+Adaption.h"
#import "UIConstant.h"

@implementation UIFont(Adaption)

+ (UIFont *)fontWithPX:(CGFloat)px {
    if (Device_iphone5) {
        return [UIFont systemFontOfSize:px / 2 + 1];
    } else if (Device_iphone6) {
        return [UIFont systemFontOfSize:px / 2 + 1];
    } else if (Device_iphone6p) {
        return [UIFont systemFontOfSize:px / 2 + 2];
    } else {
        // 默认的情况
        return [UIFont systemFontOfSize:px / 2 + 1];
    }
}

+ (UIFont *)boldFontWithPX:(CGFloat)px {
    if (Device_iphone5) {
        return [UIFont boldSystemFontOfSize:px / 2];
    } else if (Device_iphone6) {
        return [UIFont boldSystemFontOfSize:px / 2 + 1];
    } else if (Device_iphone6p) {
        return [UIFont boldSystemFontOfSize:px / 2 + 2];
    } else {
        // 默认的情况
        return [UIFont boldSystemFontOfSize:px / 2];
    }
}

+ (UIFont *)italicSystemFontWithPX:(CGFloat)px {
    if (Device_iphone5) {
        return [UIFont italicSystemFontOfSize:px / 2];
    } else if (Device_iphone6) {
        return [UIFont italicSystemFontOfSize:px / 2 + 1];
    } else if (Device_iphone6p) {
        return [UIFont italicSystemFontOfSize:px / 2 + 2];
    } else {
        // 默认的情况
        return [UIFont italicSystemFontOfSize:px / 2];
    }
}

@end
