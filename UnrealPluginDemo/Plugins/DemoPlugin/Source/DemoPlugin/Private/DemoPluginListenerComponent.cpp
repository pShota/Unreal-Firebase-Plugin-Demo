// Fill out your copyright notice in the Description page of Project Settings.


#include "DemoPluginListenerComponent.h"
#include "DemoPluginWrapper.h"

// Sets default values for this component's properties
UDemoPluginListenerComponent::UDemoPluginListenerComponent()
{
	// Set this component to be initialized when the game starts, and to be ticked every frame.  You can turn these features
	// off to improve performance if you don't need them.
	PrimaryComponentTick.bCanEverTick = true;

	// ...
}


// Called when the game starts
void UDemoPluginListenerComponent::BeginPlay()
{
	Super::BeginPlay();
	//setup callback
	DemoPluginWrapper::getInstance()->m_onReceiveFcmToken = CPP_CALLBACK_1(UDemoPluginListenerComponent::onReceiveFcmToken, this);
}                          
                           
                           
// Called every frame      
void UDemoPluginListenerComponent::TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction)
{                          
	Super::TickComponent(DeltaTime, TickType, ThisTickFunction);
                           
	// ...                 
}                          
                        

//DemoPluginWrapper Callback						   
void UDemoPluginListenerComponent::onReceiveFcmToken(std::string token){
	FString ftoken(token.c_str());
	FString printStr = FString::Printf( TEXT( "onReceiveFcmToken:%s" ), *ftoken );
	DemoPluginWrapper::_debugLog(printStr);
	OnReceiveFcmTokenDelegate.Broadcast(ftoken);
}

