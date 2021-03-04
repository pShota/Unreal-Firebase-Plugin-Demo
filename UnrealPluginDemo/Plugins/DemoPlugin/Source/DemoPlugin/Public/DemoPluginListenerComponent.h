// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "DemoPluginListenerComponent.generated.h"

DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FonReceiveFcmTokenEvent,FString, token);

UCLASS( ClassGroup=(Custom), meta=(BlueprintSpawnableComponent) )
class DEMOPLUGIN_API UDemoPluginListenerComponent : public UActorComponent
{
	GENERATED_BODY()

public:	
	// Sets default values for this component's properties
	UDemoPluginListenerComponent();

	//callback on blueprint/c++ code
	UPROPERTY(BlueprintAssignable, Category = "DemoPlugin")
	FonReceiveFcmTokenEvent OnReceiveFcmTokenDelegate;


public:
	//DemoPluginwrapper callback
	
    void onReceiveFcmToken(std::string token);
	

protected:
	// Called when the game starts
	virtual void BeginPlay() override;

public:	
	// Called every frame
	virtual void TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction) override;

		
};
