
#import <UIKit/UIkit.h>
#import "DemoPluginWrapper.h"
#include "FirebaseUnrealWrapper.h"

@interface DemoPluginWrapper_ios : NSObject

@end

static DemoPluginWrapper_ios* interfaceInstance = nil;

@implementation DemoPluginWrapper_ios


+(DemoPluginWrapper_ios*)getInstance{
    if (interfaceInstance == nil) {
        interfaceInstance = [[DemoPluginWrapper_ios alloc] init];
    }
    return interfaceInstance;
}

- (id)init{
    [super init];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self
    selector:@selector(receiveFcmToken:)
        name:NOTIFICATION_FCM_TOKEN
      object:nil];    
    
    return self;
}
-(void)receiveFcmToken:(NSNotification*)notificaion {
    NSDictionary* userInfo = notificaion.userInfo;
    NSString*token = [userInfo objectForKey:NOTIFI_KEY_FCM_TOKEN_KEY];
    DemoPluginWrapper::getInstance()->onReceiveFcmToken([token UTF8String]);
}
@end

// #pragma mark firebase fcm
void DemoPluginWrapper::firebase_init(){
    [FirebaseUnrealWrapper firebase_init];
}
void DemoPluginWrapper::fetchFcmToken(){
    [FirebaseUnrealWrapper fetchFCMToken];
}
void DemoPluginWrapper::firebaseLogEventTest(){
    [FirebaseUnrealWrapper firebaseLogEventTest];
}



