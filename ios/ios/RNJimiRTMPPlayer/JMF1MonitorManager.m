//
//  JMF1MonitorManager.m
//  example
//
//  Created by lzj<lizhijian_21@163.com> on 2019/8/27.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "JMF1MonitorManager.h"
#import <React/RCTConvert.h>

JMMonitor *gRNJMMonitor = nil;

@implementation JMF1MonitorManager

RCT_EXPORT_MODULE(JMF1Monitor)

RCT_CUSTOM_VIEW_PROPERTY(image, NSDictionary, JMMonitor) {
    UIImage *img = [RCTConvert UIImage:json];
    if (img) {
        [view displayImage:img];
    }
}

- (UIImageView *)view
{
    if (gRNJMMonitor == nil) {
        gRNJMMonitor = [[JMMonitor alloc] init];
        gRNJMMonitor.contentMode = UIViewContentModeScaleAspectFit;
    }

    return gRNJMMonitor;
}

@end
