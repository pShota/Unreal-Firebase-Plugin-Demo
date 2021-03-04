
#pragma once

#include "CoreMinimal.h"
#include "Kismet/BlueprintFunctionLibrary.h"
#include "DemoPluginBlueprintLibrary.generated.h"

UCLASS()
class DEMOPLUGIN_API UDemoPluginBlueprintLibrary : public UBlueprintFunctionLibrary
{
	GENERATED_UCLASS_BODY()
    
public:
	
	/*
	 * Perform initialization on Firebase 
	 */
	UFUNCTION(BlueprintCallable, Category = "DemoPlugin")
	static void Firebase_init();
    
	/*
     * Fetch FCM token
     */
	UFUNCTION(BlueprintCallable, Category = "DemoPlugin")
	static void FetchFcmToken();

	/*
     * a firebase event logging example
     */
	UFUNCTION(BlueprintCallable, Category = "DemoPlugin")
	static void FirebaseLogEventTest();


};
