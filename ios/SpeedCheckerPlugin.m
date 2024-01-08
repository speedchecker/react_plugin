// SpeedCheckerPlugin.m

#import "SpeedCheckerPlugin.h"
#import <React/RCTEventDispatcherProtocol.h>
@import SpeedcheckerSDK;
@import CoreLocation;

@interface SpeedCheckerPlugin () <InternetSpeedTestDelegate, CLLocationManagerDelegate>
@property (nonatomic, strong) InternetSpeedTest *internetTest;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) SpeedTestServer *server;
@property (nonatomic, strong) NSMutableDictionary *resultDict;
@property (nonatomic, strong) NSString* licenseKey;
@end

@implementation SpeedCheckerPlugin

#pragma mark - Init
- (instancetype)init {
    self = [super init];
    if (self) {
        self.locationManager = [CLLocationManager new];
        self.resultDict = [NSMutableDictionary new];
    }
    return self;
}

#pragma mark - RCTEventEmitter supported events
- (NSArray<NSString *> *)supportedEvents {
    return @[@"onTestStarted"];
}

#pragma mark - Queue
+ (BOOL)requiresMainQueueSetup {
    return YES;
}

#pragma mark - Exports

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(setLicenseKey:(NSString*)licenseKey) {
    _licenseKey = licenseKey;
}

RCT_EXPORT_METHOD(startTest) {
    [self resetServer];
    [self startSpeedTest];
}

RCT_EXPORT_METHOD(startTestWithCustomServer:(NSDictionary*)serverInfo) {
    self.server = [self speedTestServerFromDict:serverInfo];
    [self startSpeedTest];
}

RCT_EXPORT_METHOD(stopTest) {
    [self.internetTest forceFinish:^(enum SpeedTestError error) {
    }];
}

#pragma mark - Helpers
- (void)sendErrorResult:(SpeedTestError)error {
    NSDictionary *dict = @{@"error": [self descriptionForError:error]};
    
    [self sendEventWithName:@"onTestStarted" body:dict];
}

- (void)sendResultDict {
    NSDictionary *dict = [self.resultDict copy];
    
    [self sendEventWithName:@"onTestStarted" body:dict];
}

- (void)resetServer {
    self.server = nil;
}

- (void)startSpeedTest {
    self.internetTest = [[InternetSpeedTest alloc] initWithLicenseKey:self.licenseKey delegate:self];
    
    typedef void (^SpeedTestCompletionHandler)(enum SpeedTestError error);
    SpeedTestCompletionHandler completionHandler = ^(enum SpeedTestError error) {
        if (error != SpeedTestErrorOk) {
            [self sendErrorResult:error];
            [self resetServer];
        } else {
            self.resultDict = [@{
                @"status": @"Speed test started",
                @"server": @"",
                @"ping": @0,
                @"jitter": @0,
                @"downloadSpeed": @0,
                @"percent": @0,
                @"currentSpeed": @0,
                @"uploadSpeed": @0,
                @"connectionType": @"",
                @"serverInfo": @"",
                @"deviceInfo": @"",
                @"downloadTransferredMb": @0,
                @"uploadTransferredMb": @0
            } mutableCopy];
            [self sendResultDict];
        }
    };
    
    if (self.server && ![self isStringNilOrEmpty:self.server.domain]) {
        [self.internetTest start:@[self.server] completion:completionHandler];
    } else if ([self isStringNilOrEmpty:self.licenseKey]) {
        [self.internetTest startFreeTest:completionHandler];
    } else {
        [self.internetTest start:completionHandler];
    }
}

- (void)requestLocation {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([CLLocationManager locationServicesEnabled]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.locationManager.delegate = self;
                [self.locationManager requestWhenInUseAuthorization];
                [self.locationManager requestAlwaysAuthorization];
            });
        }
    });
}

- (NSString*)descriptionForError:(SpeedTestError)error {
    switch (error) {
        case SpeedTestErrorOk:
            return @"Ok";
        case SpeedTestErrorInvalidSettings:
            return @"Invalid settings";
        case SpeedTestErrorInvalidServers:
            return @"Invalid servers";
        case SpeedTestErrorInProgress:
            return @"In progress";
        case SpeedTestErrorFailed:
            return @"Failed";
        case SpeedTestErrorNotSaved:
            return @"Not saved";
        case SpeedTestErrorCancelled:
            return @"Cancelled";
        case SpeedTestErrorLocationUndefined:
            return @"Location undefined";
        case SpeedTestErrorAppISPMismatch:
            return @"App-ISP mismatch";
        case SpeedTestErrorInvalidlicenseKey:
            return @"Invalid license key";
        default:
            return @"Unknown";
    }
}

- (NSString*)serverInfo:(SpeedTestResult*)result {
    NSString *cityName = result.server.cityName ?: @"";
    NSString *country = result.server.country ?: @"";
    NSString *serverInfo = [NSString stringWithFormat:@"%@, %@", cityName, country];
    if ([cityName isEqualToString:@""] || [country isEqualToString:@""]) {
        serverInfo = [serverInfo stringByReplacingOccurrencesOfString:@", " withString:@""];
    }
    return serverInfo;
}

- (SpeedTestServer*)speedTestServerFromDict:(NSDictionary*)serverInfo {
    if (!serverInfo) {
        return nil;
    }
    
    NSNumber *serverID = [self objectOrNilForKey:@"id" ofClass:[NSNumber class] fromDictionary:serverInfo];
    NSString *domain = [self objectOrNilForKey:@"domain" ofClass:[NSString class] fromDictionary:serverInfo];
    NSString *downloadFolderPath = [[self objectOrNilForKey:@"downloadFolderPath" ofClass:[NSString class] fromDictionary:serverInfo] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    NSString *uploadFolderPath = [[self objectOrNilForKey:@"uploadFolderPath" ofClass:[NSString class] fromDictionary:serverInfo] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    NSString *countryCode = [self objectOrNilForKey:@"countryCode" ofClass:[NSString self] fromDictionary:serverInfo];
    NSString *cityName = [self objectOrNilForKey:@"city" ofClass:[NSString class] fromDictionary:serverInfo];
    
    SpeedTestServer *server = [[SpeedTestServer alloc] initWithID:serverID
                                                             type:SCServerTypeSpeedchecker
                                                           scheme:@"https"
                                                           domain:domain
                                                             port:nil
                                               downloadFolderPath:downloadFolderPath
                                                 uploadFolderPath:uploadFolderPath
                                                     uploadScript:@"php"
                                                      countryCode:countryCode
                                                         cityName:cityName];
    return server;
}

- (id)objectOrNull:(id)object {
  return object ?: [NSNull null];
}

- (id)objectOrNilForKey:(id)key ofClass:(Class)class fromDictionary:(NSDictionary *)dict {
    id object = [dict objectForKey:key];
    if (![object isEqual:[NSNull null]] && [object isKindOfClass:class]) {
        return object;
    }
    return nil;
}

- (BOOL)isStringNilOrEmpty:(NSString *)string {
    return !string || [string isEqualToString:@""] || string.length == 0;
}

#pragma mark - InternetSpeedTestDelegate

- (void)internetTestErrorWithError:(enum SpeedTestError)error {
    [self sendErrorResult:error];
    [self resetServer];
}

- (void)internetTestFinishWithResult:(SpeedTestResult *)result {
    self.resultDict[@"status"] = @"Speed test finished";
    self.resultDict[@"server"] = [self objectOrNull:result.server.domain];
    self.resultDict[@"ping"] = [NSNumber numberWithInteger:result.latencyInMs];
    self.resultDict[@"jitter"] = [NSNumber numberWithDouble:result.jitter];
    self.resultDict[@"downloadSpeed"] = [NSNumber numberWithDouble:result.downloadSpeed.mbps];
    self.resultDict[@"uploadSpeed"] = [NSNumber numberWithDouble:result.uploadSpeed.mbps];
    self.resultDict[@"connectionType"] = [self objectOrNull:result.connectionType];
    self.resultDict[@"serverInfo"] = [self objectOrNull:[self serverInfo:result]];
    self.resultDict[@"deviceInfo"] = [self objectOrNull:result.deviceInfo];
    self.resultDict[@"downloadTransferredMb"] = [NSNumber numberWithDouble:result.downloadTransferredMb];
    self.resultDict[@"uploadTransferredMb"] = [NSNumber numberWithDouble:result.uploadTransferredMb];
    [self sendResultDict];
    [self resetServer];
}

- (void)internetTestReceivedWithServers:(NSArray<SpeedTestServer *> *)servers {
    self.resultDict[@"status"] = @"Ping";
    [self sendResultDict];
}

- (void)internetTestSelectedWithServer:(SpeedTestServer *)server latency:(NSInteger)latency jitter:(NSInteger)jitter {
    self.resultDict[@"ping"] = [NSNumber numberWithInteger:latency];
    self.resultDict[@"server"] = [self objectOrNull:server.domain];
    self.resultDict[@"jitter"] = [NSNumber numberWithInteger:jitter];
    [self sendResultDict];
}

- (void)internetTestDownloadStart {
    self.resultDict[@"status"] = @"Download Test";
    [self sendResultDict];
}

- (void)internetTestDownloadFinish {
}

- (void)internetTestDownloadWithProgress:(double)progress speed:(SpeedTestSpeed *)speed {
    self.resultDict[@"status"] = @"Download Test";
    self.resultDict[@"percent"] = [NSNumber numberWithDouble:progress * 100];
    self.resultDict[@"currentSpeed"] = [NSNumber numberWithDouble:speed.mbps];
    self.resultDict[@"downloadSpeed"] = [NSNumber numberWithDouble:speed.mbps];
    [self sendResultDict];
}

- (void)internetTestUploadStart {
    self.resultDict[@"status"] = @"Upload Test";
    self.resultDict[@"currentSpeed"] = @0;
    self.resultDict[@"percent"] = @0;
    [self sendResultDict];
}

- (void)internetTestUploadFinish {
}

- (void)internetTestUploadWithProgress:(double)progress speed:(SpeedTestSpeed *)speed {
    self.resultDict[@"percent"] = [NSNumber numberWithDouble:progress * 100];
    self.resultDict[@"currentSpeed"] = [NSNumber numberWithDouble:speed.mbps];
    self.resultDict[@"uploadSpeed"] = [NSNumber numberWithDouble:speed.mbps];
    [self sendResultDict];
}

@end
