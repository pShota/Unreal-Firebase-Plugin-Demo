// Copyright Epic Games, Inc. All Rights Reserved.

using UnrealBuildTool;
using System.IO;
using Tools.DotNETCommon;
public class DemoPlugin : ModuleRules
{
	public DemoPlugin(ReadOnlyTargetRules Target) : base(Target)
	{
		PCHUsage = ModuleRules.PCHUsageMode.UseExplicitOrSharedPCHs;
		
		PublicIncludePaths.AddRange(
			new string[] {
				// ... add public include paths required here ...
			}
			);
				
		
		PrivateIncludePaths.AddRange(
			new string[] {
				"DemoPlugin/Private"
				// ... add other private include paths required here ...
			}
			);

		PrivateIncludePathModuleNames.AddRange(new string[] { "Settings" });
		PublicDependencyModuleNames.AddRange(new string[] { "Core", "CoreUObject", "Engine", "InputCore", "Projects"
		// ... add other public dependencies that you statically link with here ... 
		});
		
		
		PrivateDependencyModuleNames.AddRange(
			new string[]
			{
				// ... add private dependencies that you statically link with here ...	
			}
			);
		
		
		DynamicallyLoadedModuleNames.AddRange(
			new string[]
			{
				// ... add any modules that your module loads dynamically here ...
			}
			);

		if (Target.Platform == UnrealTargetPlatform.IOS)
		{
			PrivateIncludePaths.Add("DemoPlugin/Private/IOS");
		}
		else if (Target.Platform == UnrealTargetPlatform.Android)
		{
			PrivateIncludePaths.Add("DemoPlugin/Private/Android");
		}

		// Additional Frameworks and Libraries for IOS
		if (Target.Platform == UnrealTargetPlatform.IOS)
		{
			/*
			 * YOU MUST USE MAC OSX TO BUILD IOS IPA IF YOU NEED FCM PUSH NOTIFICATION
			 * DO NOT USE REMOTE BUILD FROM PC
			 * 
			 * Two methods to copy RAW files to iOS ipa
			 * 1) Use Build/IOS/Cloud, UE 4.23 onward, ONLY works on Mac
			 * 2) Use RemapDirectories in DefaultGame.ini, works on both PC and Mac
			 */
			//1)
			//copy raw files to Build/IOS/Cloud folder
			//Unreal engine build script would copy files from /Cloud directly into App folder
			/*
			string cloudPath = ModuleDirectory+"/../../../../Build/IOS/Cloud";
			string rawPath = Path.Combine(ModuleDirectory, "Raw");
			//Log.TraceInformation("cloudPath:"+cloudPath);
			if(Directory.Exists(cloudPath)==false){
				Directory.CreateDirectory(cloudPath);
			}
			File.Delete(cloudPath+"/GoogleService-Info.plist");
			File.Copy(rawPath +"/GoogleService-Info.plist",cloudPath+"/GoogleService-Info.plist");
			*/
			
			//2) 
			//use DefaultGame.ini method by adding staging line in DefaultGame.ini file
			//like: 
			//[Staging]
			//+RemapDirectories=(From="UnrealPluginDemo/Plugins/DemoPlugin/Source/DemoPlugin/Raw", To="Raw")
			//this will endup files under "Raw" Folder in ipa
			RuntimeDependencies.Add(Path.Combine(ModuleDirectory, "Raw/GoogleService-Info.plist"), StagedFileType.SystemNonUFS);
			
			


			// Add any import libraries or static libraries
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "../Libs/iOS/libFirebaseUnrealWrapper.a"));
			//Firebase
			addFirebase();
			//FCM
			addFCM();

			//optional flag seems not supported here
			PublicFrameworks.AddRange(
				new string[]
				{
					"iAd",
					"AdSupport"
				}
			);
			
			

			//UPL
			string PluginPath = Utils.MakePathRelativeTo(ModuleDirectory, Target.RelativeEnginePath);
			AdditionalPropertiesForReceipt.Add("IOSPlugin", Path.Combine(PluginPath, "DemoPlugin_UPL_IOS.xml"));
		}
		// Additional Frameworks and Libraries for Android
		else if (Target.Platform == UnrealTargetPlatform.Android)
		{
			//android copy files in UPL xml
			//JNI
			PrivateDependencyModuleNames.AddRange(new string[] { "Launch" });
			//UPL
			string PluginPath = Utils.MakePathRelativeTo(ModuleDirectory, Target.RelativeEnginePath);
			AdditionalPropertiesForReceipt.Add("AndroidPlugin", Path.Combine(PluginPath, "DemoPlugin_UPL_Android.xml"));
		}

	}


	public void addFirebase(){
		
		PublicAdditionalFrameworks.Add(
			new Framework(
				"FirebaseCore",
				"../ThirdParty/iOS/Firebase_7.5.0/FirebaseCore.embeddedframework.zip"
			)
		);	
		PublicAdditionalFrameworks.Add(
			new Framework(
				"FirebaseAnalytics",
				"../ThirdParty/iOS/Firebase_7.5.0/FirebaseAnalytics.embeddedframework.zip"
			)
		);	
		PublicAdditionalFrameworks.Add(
			new Framework(
				"FirebaseCoreDiagnostics",
				"../ThirdParty/iOS/Firebase_7.5.0/FirebaseCoreDiagnostics.embeddedframework.zip"
			)
		);
		
		PublicAdditionalFrameworks.Add(
			new Framework(
				"FirebaseInstallations",
				"../ThirdParty/iOS/Firebase_7.5.0/FirebaseInstallations.embeddedframework.zip"
			)
		);	
		PublicAdditionalFrameworks.Add(
			new Framework(
				"GoogleAppMeasurement",
				"../ThirdParty/iOS/Firebase_7.5.0/GoogleAppMeasurement.embeddedframework.zip"
			)
		);
		PublicAdditionalFrameworks.Add(
			new Framework(
				"GoogleDataTransport",
				"../ThirdParty/iOS/Firebase_7.5.0/GoogleDataTransport.embeddedframework.zip"
			)
		);
		PublicAdditionalFrameworks.Add(
			new Framework(
				"GoogleUtilities",
				"../ThirdParty/iOS/Firebase_7.5.0/GoogleUtilities.embeddedframework.zip"
			)
		);
		PublicAdditionalFrameworks.Add(
			new Framework(
				"nanopb",
				"../ThirdParty/iOS/Firebase_7.5.0/nanopb.embeddedframework.zip"
			)
		);
		PublicAdditionalFrameworks.Add(
			new Framework(
				"PromisesObjC",
				"../ThirdParty/iOS/Firebase_7.5.0/PromisesObjC.embeddedframework.zip"
			)
		);
	}

	public void addFCM(){
		PublicAdditionalFrameworks.Add(
			new Framework(
				"FirebaseInstanceID",
				"../ThirdParty/iOS/FCM_7.5.0/FirebaseInstanceID.embeddedframework.zip"
			)
		);
		PublicAdditionalFrameworks.Add(
			new Framework(
				"FirebaseMessaging",
				"../ThirdParty/iOS/FCM_7.5.0/FirebaseMessaging.embeddedframework.zip"
			)
		);
	}
}
