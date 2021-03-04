//
//  FirebaseUnrealWrapper.h
//  FirebaseUnrealWrapper
//
//  Created by Philip on 3/3/2021.
//

#import <Foundation/Foundation.h>
#define NOTIFICATION_FCM_TOKEN @"NOTIFICATION_FCM_TOKEN"
#define NOTIFI_KEY_FCM_TOKEN_KEY @"FCM_TOKEN"

//Unreal not allow using @import when building iOS plugin
//we use + (BOOL)conformsToProtocol:(Protocol *)protocol to implement FIRMessagingDelegate
@interface FirebaseUnrealWrapper : NSObject


+ (FirebaseUnrealWrapper*) getInstance;
+ (void) firebase_init;
+ (void) fetchFCMToken;
+ (void) firebaseLogEventTest;

@end
