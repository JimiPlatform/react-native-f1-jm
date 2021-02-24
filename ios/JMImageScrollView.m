//
//  JMImageScrollView.m
//  RNJMaxBrowser
//
//  Created by jimi01 on 2019/3/29.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "JMImageScrollView.h"
#import "JMImageView.h"
@interface JMImageScrollView()<UIScrollViewDelegate>
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) JMImageView *enlargeImage;
@end
@implementation JMImageScrollView

-(instancetype)init{
    if (self = [super init]) {
    }
    return self;
}
- (void)setWidth:(float)width
{
    _width = width;
    CGRect react = self.frame;
    react.size.width = width;
    self.frame = react;
    if (!_enlargeImage) {
        _enlargeImage = [[JMImageView alloc] init];
    }
    _enlargeImage.frame = react;
}
- (void)setPlaceholderPath:(NSString *)placeholderPath{
    _placeholderPath = placeholderPath;
    if (!_enlargeImage) {
        _enlargeImage = [[JMImageView alloc] init];
        _enlargeImage.image = [[UIImage alloc] initWithContentsOfFile:[placeholderPath stringByReplacingOccurrencesOfString:@"file://" withString:@""]];
    }else if(!_enlargeImage.image){
        _enlargeImage.image = [[UIImage alloc] initWithContentsOfFile:[placeholderPath stringByReplacingOccurrencesOfString:@"file://" withString:@""]];
    }
}
- (void)setHeight:(float)height
{
    _height = height;
    CGRect react = self.frame;
    react.size.height = height;
    self.frame = react;
    if (!_enlargeImage) {
        _enlargeImage = [[JMImageView alloc] init];
    }
    _enlargeImage.frame = react;
}
- (void)setSource:(NSString*)source
{
    _source = source;
    [self setUpView];
}
- (void)setUpView{
    _enlargeImage = [[JMImageView alloc] init];
    CGRect react = self.frame;
    if (!_width) {
        react.size.width = [UIScreen mainScreen].bounds.size.width;
    }
    if (!_height) {
        react.size.height = [UIScreen mainScreen].bounds.size.height;
    }
    self.frame= react;
    _enlargeImage.frame= react;
    _enlargeImage.contentMode = UIViewContentModeScaleAspectFit;
    
    if ([_source containsString:@"http"] || [_source containsString:@"HTTP"]) {
        __weak JMImageScrollView *weakSelf = self;
        [_enlargeImage configNetworkImageWithUrl:_source completionHandler:^(CGSize imageSize) {
            CGFloat width = weakSelf.frame.size.width;
            CGFloat height = imageSize.height/imageSize.width*width;
            CGFloat statuAndNavH = weakSelf.frame.size.height == [UIScreen mainScreen].bounds.size.height ? ([UIApplication sharedApplication].statusBarFrame.size.height + 44.0) : 0;
            weakSelf.enlargeImage.frame = CGRectMake(0, (weakSelf.frame.size.height - height - statuAndNavH)/2 , width, height);
        }];
    }else if(_source.length > 0){
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:[_source stringByReplacingOccurrencesOfString:@"file://" withString:@""]];
        if (!image) {
            image = [self createImageWithColor:UIColor.blackColor size:CGSizeMake(react.size.width, 200)];
        }
        _enlargeImage.image = image;
        CGSize imageSize = image.size;
        CGFloat width = react.size.width;
        CGFloat height = imageSize.height/imageSize.width*width;
        CGFloat statuAndNavH = react.size.height == [UIScreen mainScreen].bounds.size.height ? ([UIApplication sharedApplication].statusBarFrame.size.height + 44.0) : 0;
        _enlargeImage.frame = CGRectMake(0, (react.size.height - height - statuAndNavH)/2 , width, height);
        
    }
    [self setUpScrollView];
}
- (void)setUpScrollView{
    if (_scrollView) {
        [_scrollView removeFromSuperview];
        _scrollView = nil;
    }
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _scrollView.minimumZoomScale = 0.5;
    _scrollView.maximumZoomScale = 10;
    _scrollView.delegate = self;
    [_scrollView addSubview:_enlargeImage];
    [self addSubview:_scrollView];
}
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.enlargeImage;
}
-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    CGRect frame = self.enlargeImage.frame;
    frame.origin.y = (self.scrollView.frame.size.height - self.enlargeImage.frame.size.height) > 0 ? (self.scrollView.frame.size.height - self.enlargeImage.frame.size.height) * 0.5 : 0;
    frame.origin.x = (self.scrollView.frame.size.width - self.enlargeImage.frame.size.width) > 0 ? (self.scrollView.frame.size.width - self.enlargeImage.frame.size.width) * 0.5 : 0;
    self.enlargeImage.frame = frame;
    self.scrollView.contentSize = CGSizeMake(self.enlargeImage.frame.size.width + 30, self.enlargeImage.frame.size.height + 30);
}
- (UIImage*)createImageWithColor: (UIColor*) color size:(CGSize)size{
    CGRect rect=CGRectMake(0.0f, 0.0f, size.width,size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();return theImage;
}

@end
