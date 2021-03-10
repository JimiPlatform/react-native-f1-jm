//
//  JMF1PlayerManager.m
//  RNJimiF1Player
//
//  Created by lzj<lizhijian_21@163.com> on 2019/8/27.
//  Copyright © 2019 Jimi. All rights reserved.
//

#import "JMF1PlayerManager.h"
#import "JMF1MonitorManager.h"
#import "JMF1JSConstant.h"
#import <JMOrderCoreKit/JMOrderCoreKit.h>


@interface JMF1PlayerManager() <JMOrderCoreKitServerDelegate, JMMediaNetworkPlayerDelegate>

@property (nonatomic, assign) BOOL hasListeners;
@property (nonatomic, copy) NSString *imei;
@property (nonatomic, strong) JMOrderCamera *pOrderCamera;

@end

@implementation JMF1PlayerManager

RCT_EXPORT_MODULE(JMF1PlayerManager);

- (void)startObserving {
    self.hasListeners = YES;
}

- (void)stopObserving {
    self.hasListeners = NO;
}

- (NSArray<NSString *> *)supportedEvents
{
    return @[kOnStreamPlayerPlayStatus,
             kOnStreamPlayerTalkStatus,
             kOnStreamPlayerRecordStatus,
             kOnStreamPlayerReceiveFrameInfo,
             kOnStreamPlayerReceiveDeviceData];
}

- (NSDictionary *)constantsToExport
{
    return [JMF1JSConstant constantsToExport];
}

- (void)sendEventWithName:(NSString *)eventName body:(id)body
{
    if (self.hasListeners) {
        [super sendEventWithName:eventName body:body];
    }
}

- (void)didJMSmartAppEngineExit
{
    [self deInitialize];
    gRNJMMonitor = nil;
}

#pragma mark -

RCT_EXPORT_METHOD(initialize:(NSString *)key
                  secret:(NSString *)secret
                  imei:(NSString *_Nonnull)imei
                  userId:(NSString *)userId
                  serverIp:(NSString *)serverIp) {
    self.imei = imei;
    NSLog(@"=====> init  key= %@, \n secret = %@ \n imei = %@ \n userId = %@ \n serverIp = %@",key, secret, imei, userId, serverIp);
    if ([JMOrderCoreKit Initialize] == 0) {
        [JMOrderCoreKit configServer:serverIp];
        [JMOrderCoreKit configDeveloper:key secret:secret userID:userId];
        JMOrderCoreKit.shared.delegate = self;
        [JMOrderCoreKit.shared connect];
    }
    
}

RCT_EXPORT_METHOD(deInitialize) {
    if ([JMOrderCoreKit DeInitialize] == 0) {
        [self.pOrderCamera stop];
        [self.pOrderCamera deattachMonitor];
        JMOrderCoreKit.shared.delegate = nil;
    }
}

RCT_EXPORT_METHOD(startPlayLive) {
    [self.pOrderCamera startPlay:^(BOOL success, JMError * _Nullable error) {
        NSLog(@"startPlay:%d error[%ld]:%@", success, (long)error.errCode, error.errMsg);
    }];
    
}

RCT_EXPORT_METHOD(stopPlay) {
    [self.pOrderCamera stopPlay];
}

#pragma mark - JMOrderCoreKitServerDelegate

- (void)didJMOrderCoreKitWithError:(JMError *)error
{
    NSMutableDictionary *body = [self getEmptyBody];

    if (error) {
        body[@"errCode"] = @(error.errCode);
        body[@"errMsg"] = error.errMsg.length?error.errMsg:@"";
        [self sendEventWithName:kOnStreamPlayerPlayStatus body:body];
    }
    NSLog(@"======> didJMOrderCoreKitWithError:%ld error:%@", (long)error.errCode, error.errMsg);
}

- (void)didJMOrderCoreKitConnectWithStatus:(enum JM_SERVER_CONNET_STATE)state;
{
    if (state == JM_SERVER_CONNET_STATE_CONNECTED) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.pOrderCamera startPlay:^(BOOL success, JMError * _Nullable error) {
                NSLog(@"startPlay:%d error[%ld]:%@", success, (long)error.errCode, error.errMsg);
            }];
        });
    } else if (state >= JM_SERVER_CONNET_STATE_FAILED) {
        NSLog(@"======> Failed to connect server!");
    }
}

- (void)didJMOrderCoreKitReceiveDeviceData:(NSString * _Nullable)imei data:(NSString *_Nullable)data
{
    if (!data) return;
    [self sendEventWithName:kOnStreamPlayerReceiveDeviceData body:data];
}

#pragma mark - JMMediaNetworkPlayerDelegate
- (void)didJMMediaNetworkPlayerPlay:(JMMediaNetworkPlayer *_Nonnull)player status:(enum JM_MEDIA_PLAY_STATUS)status error:(JMError *_Nullable)error
{
    NSLog(@"======> didJMMediaNetworkPlayerPlay----->status: %d", status);
    NSMutableDictionary *body = [self getEmptyBody];
    body[@"status"] = @(status);

    if (error) {
        body[@"errCode"] = @(error.errCode);
        body[@"errMsg"] = error.errMsg.length?error.errMsg:@"";
    }

    [self sendEventWithName:kOnStreamPlayerPlayStatus body:body];
}

- (void)didJMMediaNetworkPlayerPlayInfo:(JMMediaNetworkPlayer *_Nonnull)player playInfo:(JMMediaPlayInfo *)playInfo {
    NSMutableDictionary *body = [self getEmptyBody];
    body[@"width"] = @(playInfo.videoWidth);
    body[@"height"] = @(playInfo.videoHeight);
    body[@"videoBps"] = @(playInfo.videoBps);
    body[@"audioBPS"] = @(playInfo.audioBps);
    body[@"timestamp"] = @(playInfo.timestamp);
//    body[@"totalFrameCount"] = @(totalFrameCount);
    body[@"onlineCount"] = @(playInfo.onlineCount);

    [self sendEventWithName:kOnStreamPlayerReceiveFrameInfo body:body];
}

#pragma mark - load
- (NSMutableDictionary *)getEmptyBody {
    NSMutableDictionary *body = @{}.mutableCopy;
    return body;
}

- (JMOrderCamera *)pOrderCamera {
    if (!_pOrderCamera) {
        _pOrderCamera = [[JMOrderCamera alloc] initWithIMEI:self.imei channel:0];
        [_pOrderCamera attachMonitor:gRNJMMonitor];
        _pOrderCamera.delegate = self;
    }
    return _pOrderCamera;
}

@end
