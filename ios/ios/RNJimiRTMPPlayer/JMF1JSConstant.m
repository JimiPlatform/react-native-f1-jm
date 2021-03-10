//
//  JMF1JSConstant.m
//  DoubleConversion
//
//  Created by lzj<lizhijian_21@163.com> on 2019/9/20.
//

#import "JMF1JSConstant.h"

NSString *const kOnStreamPlayerPlayStatus = @"kOnStreamPlayerPlayStatus";
NSString *const kOnStreamPlayerTalkStatus = @"kOnStreamPlayerTalkStatus";
NSString *const kOnStreamPlayerRecordStatus = @"kOnStreamPlayerRecordStatus";
NSString *const kOnStreamPlayerReceiveFrameInfo = @"kOnStreamPlayerReceiveFrameInfo";
NSString *const kOnStreamPlayerReceiveDeviceData = @"kOnStreamPlayerReceiveDeviceData";

@implementation JMF1JSConstant

+ (NSDictionary *)constantsToExport
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic addEntriesFromDictionary:@{kOnStreamPlayerPlayStatus: kOnStreamPlayerPlayStatus,
                                    kOnStreamPlayerTalkStatus: kOnStreamPlayerTalkStatus,
                                    kOnStreamPlayerRecordStatus: kOnStreamPlayerRecordStatus,
                                    kOnStreamPlayerReceiveFrameInfo: kOnStreamPlayerReceiveFrameInfo,
                                    kOnStreamPlayerReceiveDeviceData: kOnStreamPlayerReceiveDeviceData
                                    }];

    return dic;
}

@end
