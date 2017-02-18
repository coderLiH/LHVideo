//
//  UIFont+Adaption.h
//  toy
//
//  Created by qmk on 15/7/27.
//  Copyright (c) 2015年 liyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont(Adaption)

+ (UIFont *)fontWithPX:(CGFloat)px;
+ (UIFont *)boldFontWithPX:(CGFloat)px;
+ (UIFont *)italicSystemFontWithPX:(CGFloat)px;
@end
