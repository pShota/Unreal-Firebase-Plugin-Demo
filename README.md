# Firebase Unreal Plugin Demo

A project demonstrates how to integrate [Firebase](http://firebase.google.com/) into [Unreal Engine 4](https://www.unrealengine.com/).<br>

**This is not a full integration**<br>

Also fixing a plist path bug in iOS by using iOS swizzling,<br>
which I filed a Firebase issue [here](https://github.com/firebase/firebase-ios-sdk/issues/7510)

Platform: iOS and Android<br>
iOS Firebase Version: 7.5.0<br>
Android Firebase Version: BOM 25.8.0<br>
Unreal Engine 4 Version: 4.25.4<br>

Firebase modules in this demo:<br>
Analytic, Firebase Cloud Messaging.

### Android build requirements:
* JDK 12.0.2
* NDK r21d


## Integration Guide


Firebase config files `google-services.json` and `GoogleService-Info.plist` placed in /DemoPlugin/Source/DemoPlugin/Raw <br>

<br>

## iOS

### Copying raw file in iOS

There are at least 3 methods to do so.<br>

#### Method 1: Use `DefaultGame.ini` config file.

you add this path in `DefaultGame.ini`

```
[Staging]
+RemapDirectories=(From="UnrealPluginDemo/Plugins/DemoPlugin/Source/DemoPlugin/Raw", To="Raw")
```

and also in plugin Build.cs, you add

```
RuntimeDependencies.Add(Path.Combine(ModuleDirectory, "Raw/GoogleService-Info.plist"), StagedFileType.SystemNonUFS);
```

by default, the file will not be included as cooked file in UE4 System,<br>
but you also need to move it out of cooked file folder which contain the project target name in the path.<br>
that said, This config will copy files from cooked data folder to "Raw" folder<br>
The disadvantage of doing so is you cannot move it root path of the app aka `target.ipa/target.app/yourFile`<br>
here comes a problem, Firebase has a bug mentioned above cannot load plist file other than default location.<br>
you will need that swizzling fix to use this method.<br>


#### Method 2: Use "Cloud" folder.

UE4 will copy all files under Build/Cloud folder, tested from UE 4.23 onward.<br>
add following code in Build.cs.

```C#
string cloudPath = ModuleDirectory+"/../../../../Build/IOS/Cloud";
string rawPath = Path.Combine(ModuleDirectory, "Raw");
if(Directory.Exists(cloudPath)==false){
    Directory.CreateDirectory(cloudPath);
}
File.Delete(cloudPath+"/GoogleService-Info.plist");//remove previous file if exists
File.Copy(rawPath +"/GoogleService-Info.plist",cloudPath+"/GoogleService-Info.plist");
```

this method can copy raw files under root folder of `target.ipa/target.app/`<br>
The disadvantage of doing so is you must use Mac OS to build ipa.<br>
**This will not work when using PC to build ipa using UE4 remote build.**<br>


#### Method 3: Use IOS_UPL.xml

by looking at this [repo](https://github.com/nprudnikov/PrFirebase) by @nprudnikov<br>
you can also use UPL copyFile command to copy raw files.<br>

```xml
<iosPListUpdates>
  <if condition="bEnabled">
    <true>
      <copyFile src="$S(PluginDir)/../../../../$S(ConfigFile)" dst="$S(BuildDir)/GoogleService-Info.plist" force="false"/>
    </true>
  </if>
</iosPListUpdates>
```

### Confront to FIRMessagingDelegate protocol

By default UE4 does not suport @import objective-C module,<br>
you may encounter issue when you need to implement certain protocol in your class
use NSObject `conformsToProtocol` method to implement, here is how to implement FIRMessagingDelegate.

```objective-c
+ (BOOL)conformsToProtocol:(Protocol *)protocol{
    if(protocol == NSProtocolFromString(@"FIRMessagingDelegate")){
        return YES;
    }
    return [super conformsToProtocol:protocol];
}
```

or you can find "Firebase.h" from cocoapod sources. use #import "Firebase.h" instead.<br>

<br>

## Android

<br>

### Support AndroidX

Swap UE4 support-library classes to AndroidX classes.<br>
To do so you need you do that in UE4 `Android_UPL.xml` file,<br>
use ant task to replace all "import" library package names.<br>

```gradle
task replaceImport {
	ant.replace(token:'import android.support.v13.app.FragmentCompat;', value:'import androidx.legacy.app.FragmentCompat;') {
		fileset(dir: '../permission_library/src/main/java/com/google/vr/sdk/samples/permission', includes: 'PermissionFragment.java')
	}
	ant.replace(token:'import android.support.v4.content.ContextCompat;', value:'import androidx.core.content.ContextCompat;') {
		fileset(dir: '../permission_library/src/main/java/com/google/vr/sdk/samples/permission', includes: 'PermissionHelper.java')
	}

	ant.replace(token:'import android.support.v4.app.NotificationCompat;', value:'import androidx.core.app.NotificationCompat;') {
		fileset(dir: 'src/main/java/com/google/android/vending/expansion/downloader/impl', includes: 'DownloadNotification.java')
	}

	ant.replace(token:'import android.support.v4.app.NotificationCompat;', value:'import androidx.core.app.NotificationCompat;') {
		fileset(dir: 'src/main/java/com/epicgames/ue4', includes: 'LocalNotificationReceiver.java')
	}

	ant.replace(token:'import android.support.annotation.NonNull;', value:'import androidx.annotation.NonNull;') {
		fileset(dir: 'src/main/java/com/epicgames/ue4/network', includes: 'NetworkChangedManager.java')
	}
	ant.replace(token:'import android.support.annotation.Nullable;', value:'import androidx.annotation.Nullable;') {
		fileset(dir: 'src/main/java/com/epicgames/ue4/network', includes: 'NetworkChangedManager.java')
	}
	ant.replace(token:'import android.support.annotation.NonNull;', value:'import androidx.annotation.NonNull;') {
		fileset(dir: 'src/main/java/com/epicgames/ue4/network', includes: 'NetworkConnectivityClient.java')
	}

	ant.replace(token:'import android.support.v4.app.NotificationManagerCompat;', value:'import androidx.core.app.NotificationManagerCompat;') {
		fileset(dir: 'src/main/java/com/epicgames/ue4', includes: 'GameActivity.java')
	}

	ant.replace(token:'import android.support.v4.app.ActivityCompat;', value:'import androidx.core.app.ActivityCompat;') {
		fileset(dir: 'src/main/java/com/epicgames/ue4', includes: 'SplashActivity.java')
	}
	ant.replace(token:'import android.support.v4.content.ContextCompat;', value:'import androidx.core.content.ContextCompat;') {
		fileset(dir: 'src/main/java/com/epicgames/ue4', includes: 'SplashActivity.java')
	}

	ant.replace(token:'import android.support.v4.content.FileProvider;', value:'import androidx.core.content.FileProvider;') {
		fileset(dir: 'src/main/java/com/epicgames/ue4', includes: 'GameActivity.java')
	}

	ant.replace(token:'import android.arch.lifecycle.Lifecycle;', value:'import androidx.lifecycle.Lifecycle;') {
		fileset(dir: 'src/main/java/com/epicgames/ue4', includes: 'GameApplication.java')
	}
	ant.replace(token:'import android.arch.lifecycle.LifecycleObserver;', value:'import androidx.lifecycle.LifecycleObserver;') {
		fileset(dir: 'src/main/java/com/epicgames/ue4', includes: 'GameApplication.java')
	}
	ant.replace(token:'import android.arch.lifecycle.OnLifecycleEvent;', value:'import androidx.lifecycle.OnLifecycleEvent;') {
		fileset(dir: 'src/main/java/com/epicgames/ue4', includes: 'GameApplication.java')
	}
	ant.replace(token:'import android.arch.lifecycle.ProcessLifecycleOwner;', value:'import androidx.lifecycle.ProcessLifecycleOwner;') {
		fileset(dir: 'src/main/java/com/epicgames/ue4', includes: 'GameApplication.java')
	}

}

```

also add `android.useAndroidX=true` & `android.enableJetifier=true` in gradle.properties file

```
<gradleProperties>
  <insert>
    android.useAndroidX=true
    android.enableJetifier=true
  </insert>
</gradleProperties>
```

<br>

### Thread handling of JNI Callback from java

Be aware which thread you are using when performing task in Java side,<br>
normally the best practice is using UI Thread of Android system and use Game Thread<br>
when picking up callback in JNI.

In UE4, use `AsyncTask` to run callback code in UE4 engine.

```c++
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
```

<br>

## C++ implementation in UE4

### Callback handling

in this demo, use C++11 feature to bind delegate methods.

```c++
#define CPP_CALLBACK_0(__selector__,__target__, ...) std::bind(&__selector__,__target__, ##__VA_ARGS__)
#define CPP_CALLBACK_1(__selector__,__target__, ...) std::bind(&__selector__,__target__, std::placeholders::_1, ##__VA_ARGS__)
#define CPP_CALLBACK_2(__selector__,__target__, ...) std::bind(&__selector__,__target__, std::placeholders::_1, std::placeholders::_2, ##__VA_ARGS__)
#define CPP_CALLBACK_3(__selector__,__target__, ...) std::bind(&__selector__,__target__, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3, ##__VA_ARGS__)
```

assign delegate in DemoPluginListenerComponet.cpp:

```c++
DemoPluginWrapper::getInstance()->m_onReceiveFcmToken = CPP_CALLBACK_1(UDemoPluginListenerComponent::onReceiveFcmToken, this);
```

DemoPluginListenerComponent extends `UActorComponent` which can be added in you Map.<br>
DemoPluginListenerComponent use `Multicast Delegate` to boardcast callback to other UE4 receiver.<br>
This callback support both c++ and blueprint.

```c++
DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FonReceiveFcmTokenEvent,FString, token);
```

