//
//  RNTImageBrowserManager.m
//  RNJMaxBrowser
//
//  Created by jimi01 on 2019/3/29.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "RNTImageBrowserManager.h"
#import "JMImageScrollView.h"
@implementation RNTImageBrowserManager
RCT_EXPORT_MODULE(JMZoomImageView)
RCT_EXPORT_VIEW_PROPERTY(source,NSString)
RCT_EXPORT_VIEW_PROPERTY(placeholderPath,NSString)
RCT_EXPORT_VIEW_PROPERTY(width,float)
RCT_EXPORT_VIEW_PROPERTY(height,float)

- (UIView *)view
{
    return [[JMImageScrollView alloc] init];
}

@end
