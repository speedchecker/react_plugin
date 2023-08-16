//
//  SpeedCheckerPlugin.m
//  speedchecker_react_native_plugin
//
//  Created by Predrag Bogdanic on 8/16/23.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(SpeedCheckerPlugin, RCTEventEmitter)

RCT_EXTERN_METHOD(startTest)
RCT_EXTERN_METHOD(startTestWithTestType:(nonnull NSNumber *)testType)
RCT_EXTERN_METHOD(startTestWithCustomServer:(nonnull NSDictionary *)dict)
RCT_EXTERN_METHOD(stopTest)

@end
