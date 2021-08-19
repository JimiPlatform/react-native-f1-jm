//
//  JMF1PlayerManager.m
//  RNJimiF1Player
//
//  Created by lzj<lizhijian_21@163.com> on 2019/8/27.
//  Copyright © 2019 Jimi. All rights reserved.
//

#import "JMF1PlayerManager.h"
#import "JMF1MonitorManager.h"
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
    return @[@"kOnStreamPlayerPlayStatus",
             @"kOnStreamPlayerTalkStatus",
             @"kOnStreamPlayerRecordStatus",
             @"kOnStreamPlayerReceiveFrameInfo",
             @"kOnStreamPlayerReceiveDeviceData",
             @"kOnStreamPlayerServerStatus"];
}

- (NSDictionary *)constantsToExport
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic addEntriesFromDictionary:@{@"kOnStreamPlayerPlayStatus": @"kOnStreamPlayerPlayStatus",
                                    @"kOnStreamPlayerTalkStatus": @"kOnStreamPlayerTalkStatus",
                                    @"kOnStreamPlayerRecordStatus": @"kOnStreamPlayerRecordStatus",
                                    @"kOnStreamPlayerReceiveFrameInfo": @"kOnStreamPlayerReceiveFrameInfo",
                                    @"kOnStreamPlayerReceiveDeviceData": @"kOnStreamPlayerReceiveDeviceData",
                                    @"kOnStreamPlayerServerStatus": @"kOnStreamPlayerServerStatus"
                                    }];
    
    [dic addEntriesFromDictionary:@{@"videoStatusPrepare": @(JM_MEDIA_PLAY_STATUS_PREPARE),
                                    @"videoStatusStart": @(JM_MEDIA_PLAY_STATUS_START),
                                    @"videoStatusStop": @(JM_MEDIA_PLAY_STATUS_STOP),
                                    @"videoStatusErrOpenFail": @(JM_MEDIA_PLAY_STATUS_FAILED)
                                    }];
    return dic;
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didJMSmartAppEngineExit) name:@"kJMSmartAppEngineExit" object:nil];
        [JMOrderCoreKit configServer:serverIp];
        [JMOrderCoreKit configDeveloper:key secret:secret userID:userId];
        JMOrderCoreKit.shared.delegate = self;
        [JMOrderCoreKit.shared connect];
    }
    
}

RCT_EXPORT_METHOD(connectServer) {
    [JMOrderCoreKit.shared connect];
}

RCT_EXPORT_METHOD(deInitialize) {
    NSLog(@"============ deInitialize ===========>");
    if ([JMOrderCoreKit DeInitialize] == 0) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.pOrderCamera stop];
        [self.pOrderCamera deattachMonitor];
        JMOrderCoreKit.shared.delegate = nil;
    }
}

RCT_EXPORT_METHOD(startPlayLive) {
    __weak typeof(self) weakSelf = self;
    [self.pOrderCamera startPlay:^(BOOL success, JMError * _Nullable error) {
        NSLog(@"=============================startPlay:%d error[%ld]:%@ ========================>", success, (long)error.errCode, error.errMsg);
        
        NSMutableDictionary *body = [weakSelf getEmptyBody];
        body[@"status"] = @(success?JM_MEDIA_PLAY_STATUS_START:JM_MEDIA_PLAY_STATUS_FAILED);
        if (error) {
            body[@"errMsg"] = error.errMsg.length?error.errMsg:@"";
        }
        [weakSelf sendEventWithName:@"kOnStreamPlayerPlayStatus" body:body];
    }];
    
}

RCT_EXPORT_METHOD(stopPlay) {
    [self.pOrderCamera stopPlay];
}

#pragma mark - JMOrderCoreKitServerDelegate
- (void)didJMOrderCoreKitConnectWithStatus:(enum JM_SERVER_CONNET_STATE)state;
{
//    if (state == JM_SERVER_CONNET_STATE_CONNECTED) {
//        [self startPlayLive];
//    }
    NSMutableDictionary *body = [self getEmptyBody];
    body[@"status"] = @(state);
    [self sendEventWithName:@"kOnStreamPlayerServerStatus" body:body];
}

- (void)didJMOrderCoreKitReceiveDeviceData:(NSString * _Nullable)imei data:(NSString *_Nullable)data
{
    if (!data) return;
    [self sendEventWithName:@"kOnStreamPlayerReceiveDeviceData" body:data];
}

#pragma mark - JMMediaNetworkPlayerDelegate
- (void)didJMMediaNetworkPlayerPlay:(JMMediaNetworkPlayer *_Nonnull)player status:(enum JM_MEDIA_PLAY_STATUS)status error:(JMError *_Nullable)error
{
    NSMutableDictionary *body = [self getEmptyBody];
    body[@"status"] = @(status);

    if (error) {
        body[@"errCode"] = @(error.errCode);
        body[@"errMsg"] = error.errMsg.length?error.errMsg:@"";
    }

    [self sendEventWithName:@"kOnStreamPlayerPlayStatus" body:body];
}

- (void)didJMMediaNetworkPlayerPlayInfo:(JMMediaNetworkPlayer *_Nonnull)player playInfo:(JMMediaPlayInfo *)playInfo {
    NSMutableDictionary *body = [self getEmptyBody];
    body[@"width"] = @(playInfo.videoWidth);
    body[@"height"] = @(playInfo.videoHeight);
    body[@"videoBps"] = @(playInfo.videoBps);
    body[@"audioBPS"] = @(playInfo.audioBps);
    body[@"timestamp"] = @(playInfo.timestamp);
    body[@"onlineCount"] = @(playInfo.onlineCount);

    [self sendEventWithName:@"kOnStreamPlayerReceiveFrameInfo" body:body];
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
