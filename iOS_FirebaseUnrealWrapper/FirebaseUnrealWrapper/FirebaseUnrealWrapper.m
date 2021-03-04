//
//  FirebaseUnrealWrapper.m
//  FirebaseUnrealWrapper
//
//  Created by Philip on 3/3/2021.
//

#import "FirebaseUnrealWrapper.h"
#import "EPPZSwizzler.h"
@import Firebase;
@import FirebaseAnalytics;
@import UIKit;

static FirebaseUnrealWrapper *s_instance = nil;


@implementation FirebaseUnrealWrapper
/*
 * a "fix" for firebase returning wrong plist path when GoogleService-Info.plist not located
 * in default path.
 * see Readme.md for details
 */
static NSString* s_firePlistPath = nil;
static BOOL FIROptionsMethodNotMatchSwizzling = NO;
static BOOL APMInfoPlistFileUtilMethodNotMatchSwizzling = NO;

+(void)load{
    //default location
    s_firePlistPath = @"";
    
    /*
     * firebase has a bug in GoogleAppMeasurement.framework
     * up to version 7.5.0 when I type this
     * that would call + (NSString *)plistFilePathWithName:(NSString *)fileName
     * in FIROptions class and gave a default path of GoogleService-Info.plist
     * where we need to use a path other than default path for unreal sdk
     *
     * current solution: use method swizzling :)
     * an issue was submitted to firebase ios github, no fix will come soon.
     * https://github.com/firebase/firebase-ios-sdk/issues/7510
     */
    
    //perform method swizzling on FIROptions class to fix path bug
    // Add empty placholder to target class
    Class FIROptionsClass = NSClassFromString(@"FIROptions");
    [EPPZSwizzler addClassMethod:@selector(FirebaseUnrealWrapper_placeholder_plistFilePathWithName:)
                                     toClass:FIROptionsClass
                                   fromClass:[FirebaseUnrealWrapper class]];
    //[FIROptions plistFilePathWithName:]
    if ([EPPZSwizzler hasClassMethod:@selector(plistFilePathWithName:) ofClass:FIROptionsClass]) {
        // Save the original app delegate implementation into placeholder.
        [EPPZSwizzler swapClassMethod:@selector(FirebaseUnrealWrapper_placeholder_plistFilePathWithName:)
                      withClassMethod:@selector(FirebaseUnrealWrapper_placeholder_plistFilePathWithName:)
                                       ofClass:FIROptionsClass];
        // Replace app delegate with ours.
        [EPPZSwizzler replaceClassMethod:@selector(plistFilePathWithName:)
                                          ofClass:FIROptionsClass
                                        fromClass:[FirebaseUnrealWrapper class]];
        
    }
    else{
        FIROptionsMethodNotMatchSwizzling = YES;
//        SWErrorLog(@"FIROptions has no method plistFilePathWithName:, updated firebase??");
    }
    //[APMInfoPlistFileUtil googleServiceInfoPlistPath]
    Class APMInfoPlistFileUtilClass = NSClassFromString(@"APMInfoPlistFileUtil");
    [EPPZSwizzler addClassMethod:@selector(FirebaseUnrealWrapper_placeholder_googleServiceInfoPlistPath)
                                     toClass:APMInfoPlistFileUtilClass
                                   fromClass:[FirebaseUnrealWrapper class]];
    
    if ([EPPZSwizzler hasClassMethod:@selector(googleServiceInfoPlistPath) ofClass:APMInfoPlistFileUtilClass]) {
        // Save the original app delegate implementation into placeholder.
        [EPPZSwizzler swapClassMethod:@selector(FirebaseUnrealWrapper_placeholder_googleServiceInfoPlistPath)
                      withClassMethod:@selector(FirebaseUnrealWrapper_placeholder_googleServiceInfoPlistPath)
                                       ofClass:APMInfoPlistFileUtilClass];
        // Replace app delegate with ours.
        [EPPZSwizzler replaceClassMethod:@selector(googleServiceInfoPlistPath)
                                          ofClass:APMInfoPlistFileUtilClass
                                        fromClass:[FirebaseUnrealWrapper class]];
        
    }
    else{
        APMInfoPlistFileUtilMethodNotMatchSwizzling = YES;
    }
}
+(NSString*) getPlistPath{
    return s_firePlistPath;
}
+(NSString *)plistFilePathWithName:(NSString *)fileName{
    return [FirebaseUnrealWrapper getPlistPath];
}

+(NSString *)FirebaseUnrealWrapper_placeholder_plistFilePathWithName:(NSString *)fileName{
    return @"";
}

+(NSString *)googleServiceInfoPlistPath{
    return [FirebaseUnrealWrapper getPlistPath];
}
+(NSString *)FirebaseUnrealWrapper_placeholder_googleServiceInfoPlistPath{
    return @"";
}


+(FirebaseUnrealWrapper*_Nonnull)getInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(s_instance==nil){
            s_instance = [[FirebaseUnrealWrapper alloc]init];
            
        }
    });
    
    return s_instance;

}

+(void)firebase_init{
    /*
     * Unreal packaging moves GoogleService-Info.plist under Raw folder
     * see Readme.md for details
     */
    NSString* path = [[NSBundle mainBundle] pathForResource:@"Raw/GoogleService-Info" ofType:@"plist"];
    
    //update static path
    s_firePlistPath = path;
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){
        //google config exist, now check if swizzling successful
        if(FIROptionsMethodNotMatchSwizzling){
            NSLog(@"FirebaseUnrealWrapper: FIROptions has no method plistFilePathWithName:, this firebase version not support");
        }
        if(APMInfoPlistFileUtilMethodNotMatchSwizzling){
            NSLog(@"FirebaseUnrealWrapper: APMInfoPlistFileUtil has no method plistFilePathWithName:, this firebase version not support");
        }
        
        FIROptions *options = [[FIROptions alloc] initWithContentsOfFile:path];
        if (options == nil) {
            NSLog(@"Invalid Firebase configuration file.");
        }
        
        //firebase library will read corrected plist path after ios swizzling
        [FIRApp configureWithOptions:options];
        
        [FIRMessaging messaging].delegate = s_instance;
        [FirebaseUnrealWrapper registerPushNotification];
        
    }
    else{
        NSLog(@"FirebaseUnrealWrapper: cannot find GoogleService-Info.plist! check your build! Firebase not initialize");
    }
    
   
}
+(void)registerPushNotification{
    UIApplication* application = [UIApplication sharedApplication];
    if (@available(iOS 10.0, *)) {
        if ([UNUserNotificationCenter class] != nil) {
            // iOS 10 or later
            // For iOS 10 display notification (sent via APNS)
//            [UNUserNotificationCenter currentNotificationCenter].delegate = self;
            UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert |
            UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
            [[UNUserNotificationCenter currentNotificationCenter]
             requestAuthorizationWithOptions:authOptions
             completionHandler:^(BOOL granted, NSError * _Nullable error) {
                // ...
            }];
        }
    } else {
        // Fallback on earlier versions
        // iOS 10 notifications aren't available; fall back to iOS 8-9 notifications.
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
    
    [application registerForRemoteNotifications];
}

+ (void) fetchFCMToken{
    [[FIRMessaging messaging] tokenWithCompletion:^(NSString *token, NSError *error) {
      if (error != nil) {
        NSLog(@"Error getting FCM registration token: %@", error);
      } else {
        NSLog(@"FCM registration token: %@", token);
        NSDictionary *dataDict = [NSDictionary dictionaryWithObject:token forKey:NOTIFI_KEY_FCM_TOKEN_KEY];
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_FCM_TOKEN
                                                             object:nil
                                                           userInfo:dataDict];
      }
    }];
    
}
+(void)firebaseLogEventTest{
    [FIRAnalytics logEventWithName:kFIREventLogin parameters:nil];
}
-(void)messaging:(FIRMessaging*)messaging didReceiveRegistrationToken:(NSString*)fcmToken{
    NSLog(@"Automatic received FCM registration token: %@", fcmToken);
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:fcmToken forKey:NOTIFI_KEY_FCM_TOKEN_KEY];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_FCM_TOKEN
                                                         object:nil
                                                       userInfo:dataDict];
}

//we do not have protocol class as we wrote dynamic code
//override NSObject method
+ (BOOL)conformsToProtocol:(Protocol *)protocol{
    if(protocol == NSProtocolFromString(@"FIRMessagingDelegate")){
        return YES;
    }
    return [super conformsToProtocol:protocol];
}


@end
