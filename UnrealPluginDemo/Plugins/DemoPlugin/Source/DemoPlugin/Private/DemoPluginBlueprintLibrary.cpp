

#include "DemoPluginBlueprintLibrary.h"
#include "DemoPluginWrapper.h"
#include "Engine.h"

UDemoPluginBlueprintLibrary::UDemoPluginBlueprintLibrary(const FObjectInitializer& ObjectInitializer)
	: Super(ObjectInitializer)
{

}



void UDemoPluginBlueprintLibrary::Firebase_init(){
#if PLATFORM_ANDROID || PLATFORM_IOS
	DemoPluginWrapper::getInstance()->firebase_init();
#endif
}

void UDemoPluginBlueprintLibrary::FetchFcmToken(){
#if PLATFORM_ANDROID || PLATFORM_IOS
	DemoPluginWrapper::getInstance()->fetchFcmToken();
#endif
}

void UDemoPluginBlueprintLibrary::FirebaseLogEventTest(){
#if PLATFORM_ANDROID || PLATFORM_IOS
	DemoPluginWrapper::getInstance()->firebaseLogEventTest();
#endif
}


