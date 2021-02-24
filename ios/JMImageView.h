//
//  JMimageView.h
//  RNJMaxBrowser
//
//  Created by jimi01 on 2019/3/29.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JMImageView : UIImageView
-(void)configNetworkImageWithUrl:(NSString *)urlStr  completionHandler:(void(^)(CGSize imageSize))completionHandler;
@end

NS_ASSUME_NONNULL_END
