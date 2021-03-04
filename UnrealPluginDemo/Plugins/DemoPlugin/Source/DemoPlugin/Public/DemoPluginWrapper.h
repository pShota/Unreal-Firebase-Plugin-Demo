//
//  DemoPluginWrapper.h

#pragma once

#include <string>
#include <map>
#include "Engine.h"
//notice:
//these callback is support from c++11 onward

#define CPP_CALLBACK_0(__selector__,__target__, ...) std::bind(&__selector__,__target__, ##__VA_ARGS__)
#define CPP_CALLBACK_1(__selector__,__target__, ...) std::bind(&__selector__,__target__, std::placeholders::_1, ##__VA_ARGS__)
#define CPP_CALLBACK_2(__selector__,__target__, ...) std::bind(&__selector__,__target__, std::placeholders::_1, std::placeholders::_2, ##__VA_ARGS__)
#define CPP_CALLBACK_3(__selector__,__target__, ...) std::bind(&__selector__,__target__, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3, ##__VA_ARGS__)


class DemoPluginWrapper {
public:
    DemoPluginWrapper();
    static DemoPluginWrapper* getInstance();
    
    static void _debugLog(FString log);
    static void _errorLog(FString log);

public:
    
    /*
     * Initialize Firebase
     */
    void firebase_init();
    /*
     * Fetch FCM token
     */
    void fetchFcmToken();
    /*
     * a firebase event logging example
     */
    void firebaseLogEventTest();
    
    //Callbacks method from native code and redirect to Unreal callbacks
    void onReceiveFcmToken(std::string token);

    //Callbacks delegate
    std::function<void(std::string token)> m_onReceiveFcmToken;
    
    
    
};













