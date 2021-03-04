//
//  DemoPluginWrapper.cpp


#include "DemoPluginWrapper.h"


static DemoPluginWrapper* s_instance = NULL;

void DemoPluginWrapper::_debugLog(FString log){
#if !UE_BUILD_SHIPPING
	UE_LOG(LogTemp, Display, TEXT("UnrealPluginDemo:UE:%s"),*log);       
#endif
}
void DemoPluginWrapper::_errorLog(FString log){

	UE_LOG(LogTemp, Error, TEXT("UnrealPluginDemo:UE:%s"),*log);       

}

DemoPluginWrapper::DemoPluginWrapper(){
    
    m_onReceiveFcmToken = NULL;
    
}
DemoPluginWrapper* DemoPluginWrapper::getInstance(){
    if(s_instance == NULL){
        s_instance = new DemoPluginWrapper();
    }
    return s_instance;
}

void DemoPluginWrapper::onReceiveFcmToken(std::string token){

    if(m_onReceiveFcmToken!=NULL){
        m_onReceiveFcmToken(token);
    }
}
