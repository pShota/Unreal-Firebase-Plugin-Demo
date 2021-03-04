

#pragma once

#if PLATFORM_ANDROID

#include "Android/AndroidApplication.h"
#include "Android/AndroidJNI.h"
#include "Async/Async.h"

#include "DemoPluginWrapper.h"

#define FIREBASEUNREALWRAPPER_CLASS_NAME "com/pshota/firebaseunrealwrapper/FirebaseUnrealWrapper"
#define GAMEACTIVITY_CLASS_NAME "com/epicgames/ue4/GameActivity"

typedef struct JniMethodInfo_
{
    JNIEnv *    env;
    jclass      classID;
    jmethodID   methodID;
	
} JniMethodInfo;



bool getStaticMethodInfo(JniMethodInfo &methodinfo,
                                        const char *className, 
                                        const char *methodName,
                                        const char *paramCode) {
        if ((nullptr == className) ||
            (nullptr == methodName) ||
            (nullptr == paramCode)) {
            return false;
        }

        JNIEnv *env = FAndroidApplication::GetJavaEnv();
        
            
        jclass classID = AndroidJavaEnv::FindJavaClass(className);
		if (! classID) {
			FString str(className);
			UE_LOG(LogTemp, Warning, TEXT("Failed to find class %s"), *str);
            env->ExceptionClear();
            return false;
        }
		
        jmethodID methodID = env->GetStaticMethodID(classID, methodName, paramCode);
        if (! methodID) {
			FString str(methodName);
            UE_LOG(LogTemp, Warning, TEXT("Failed to find static method id of %s"), *str);
            env->ExceptionClear();
            return false;
        }
            
        methodinfo.classID = classID;
        methodinfo.env = env;
        methodinfo.methodID = methodID;
        return true;
}


std::string jstring2string(jstring jStr) {
    if (!jStr)
        return "";

	JNIEnv *env = FAndroidApplication::GetJavaEnv();
        
    const jclass stringClass = env->GetObjectClass(jStr);
    const jmethodID getBytes = env->GetMethodID(stringClass, "getBytes", "(Ljava/lang/String;)[B");
    const jbyteArray stringJbytes = (jbyteArray) env->CallObjectMethod(jStr, getBytes, env->NewStringUTF("UTF-8"));

    size_t length = (size_t) env->GetArrayLength(stringJbytes);
    jbyte* pBytes = env->GetByteArrayElements(stringJbytes, NULL);

    std::string ret = std::string((char *)pBytes, length);
    env->ReleaseByteArrayElements(stringJbytes, pBytes, JNI_ABORT);

    env->DeleteLocalRef(stringJbytes);
    env->DeleteLocalRef(stringClass);
    return ret;
}
extern "C"
{
    
    /*
    * Class:
    * Method:    nativeOnManualFcmTokenSuccess
    * Signature: (Ljava/lang/String;)V
    */
    JNIEXPORT void JNICALL Java_com_epicgames_ue4_GameActivity_nativeOnReceiveFcmToken
    (JNIEnv * env, jclass _class, jstring jtoken){
        std::string ctoken = jstring2string(jtoken);
        AsyncTask(ENamedThreads::GameThread, [=]()
		{ 
            DemoPluginWrapper::getInstance()->onReceiveFcmToken(ctoken);
        });
    }
    
}
//end of extern C




void DemoPluginWrapper::firebase_init(){
   
	JNIEnv *env = FAndroidApplication::GetJavaEnv();
    
	jmethodID myMethodID = env->GetStaticMethodID(FJavaWrapper::GameActivityClassID, "FirebaseWrapper_firebase_init", "()V");
    if (!myMethodID)
    {
	    DemoPluginWrapper::_errorLog("error to get methodInfo: FirebaseWrapper_firebase_init");
    }
    else{
        env->CallStaticVoidMethod(FJavaWrapper::GameActivityClassID, myMethodID);
    }
}

void DemoPluginWrapper::fetchFcmToken(){
    JniMethodInfo methodInfo;
    
    if (! getStaticMethodInfo(methodInfo,FIREBASEUNREALWRAPPER_CLASS_NAME, "FirebaseWrapper_fetchFcmToken","()V"))
    {
        DemoPluginWrapper::_errorLog("error to get methodInfo: FirebaseWrapper_fetchFcmToken");
    }
    else{
        methodInfo.env->CallStaticVoidMethod(methodInfo.classID, methodInfo.methodID);
        methodInfo.env->DeleteLocalRef(methodInfo.classID);
    }
}

void DemoPluginWrapper::firebaseLogEventTest(){
    JniMethodInfo methodInfo;
    
    if (! getStaticMethodInfo(methodInfo,FIREBASEUNREALWRAPPER_CLASS_NAME, "FirebaseWrapper_firebaseLogEventTest","()V"))
    {
        DemoPluginWrapper::_errorLog("error to get methodInfo: FirebaseWrapper_firebaseLogEventTest");
    }
    else{
        methodInfo.env->CallStaticVoidMethod(methodInfo.classID, methodInfo.methodID);
        methodInfo.env->DeleteLocalRef(methodInfo.classID);
    }
}



#endif