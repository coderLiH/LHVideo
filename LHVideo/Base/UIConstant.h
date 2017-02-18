//
//  UIConstant.h
//  kezhuo
//
//  Created by Feng Jingjun on 14-7-9.
//  Copyright (c) 2014年 kezhuo365. All rights reserved.
//

#define Device_iphone4              ([UIScreen mainScreen].bounds.size.height == 480)
#define Device_iphone5              ([UIScreen mainScreen].bounds.size.height == 568)
#define Device_iphone6              ([UIScreen mainScreen].bounds.size.width == 375)
#define Device_iphone6p             ([UIScreen mainScreen].bounds.size.width == 414)


#define UI_MARGIN                   10
#define UI_NAVIGATION_STATUS_HEIGHT 64
#define UI_TOOLBAR_HEIGHT           44
#define UI_TAB_BAR_HEIGHT           49
#define UI_STATUS_BAR_HEIGHT        20
#define UI_SCREEN_WIDTH             ([[UIScreen mainScreen] bounds].size.width)
#define UI_SCREEN_HEIGHT            ([[UIScreen mainScreen] bounds].size.height)
#define UI_KEYBOARD_HEIGHT          200
#define UI_EMOTION_HEIGHT           216
#define UI_TOPBAR_HEIGHT            40

#define kCornerRadius               5
#define UI_LINE_WIDTH               0.5


#define UIColorFromRGB(rgbValue) \
                [UIColor colorWithRed:((float)(((rgbValue) & 0xFF0000) >> 16))/255.0 \
                green:((float)(((rgbValue) & 0xFF00) >> 8))/255.0 \
                blue:((float)((rgbValue) & 0xFF))/255.0 \
                alpha:1.0]

#define UIColorFromRGBA(rgbValue, alphaValue) \
                [UIColor colorWithRed:((float)(((rgbValue) & 0xFF0000) >> 16))/255.0 \
                green:((float)(((rgbValue) & 0xFF00) >> 8))/255.0 \
                blue:((float)((rgbValue) & 0xFF))/255.0 \
                alpha:(alphaValue)]

#define RGBColor(Red,Green,Blue)  [UIColor colorWithRed:(Red/255.0) green:(Green/255.0) blue:(Blue/255.0) alpha:1.0f]
