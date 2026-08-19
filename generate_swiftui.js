const fs = require('fs');
const path = require('path');

const baseDir = __dirname;
const tgPanelDir = path.join(baseDir, 'TGPanelApp');
const xcodeDir = path.join(baseDir, 'TGPanel.xcodeproj');

// Update Xcode project.pbxproj for Pure SwiftUI with ThemeManager
const pbxproj = `// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
		E0A1010128000001 /* ContentView.swift in Sources */ = {isa = PBXBuildFile; fileRef = E0A1000128000001 /* ContentView.swift */; };
		E0A1010228000002 /* PanelViewModel.swift in Sources */ = {isa = PBXBuildFile; fileRef = E0A1000228000002 /* PanelViewModel.swift */; };
		E0A1010328000003 /* ThemeManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = E0A1000328000003 /* ThemeManager.swift */; };
		E0A1010528000005 /* Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = E0A1000528000005 /* Assets.xcassets */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		E0A1000028000000 /* TGPanel.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = TGPanel.app; sourceTree = BUILT_PRODUCTS_DIR; };
		E0A1000128000001 /* ContentView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ContentView.swift; sourceTree = "<group>"; };
		E0A1000228000002 /* PanelViewModel.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = PanelViewModel.swift; sourceTree = "<group>"; };
		E0A1000328000003 /* ThemeManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ThemeManager.swift; sourceTree = "<group>"; };
		E0A1000528000005 /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; };
		E0A1000628000006 /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		E0A1020028000000 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		E0A1030028000000 = {
			isa = PBXGroup;
			children = (
				E0A1030128000001 /* TGPanelApp */,
				E0A1030228000002 /* Products */,
			);
			sourceTree = "<group>";
		};
		E0A1030128000001 /* TGPanelApp */ = {
			isa = PBXGroup;
			children = (
				E0A1000128000001 /* ContentView.swift */,
				E0A1000228000002 /* PanelViewModel.swift */,
				E0A1000328000003 /* ThemeManager.swift */,
				E0A1000528000005 /* Assets.xcassets */,
				E0A1000628000006 /* Info.plist */,
			);
			path = TGPanelApp;
			sourceTree = "<group>";
		};
		E0A1030228000002 /* Products */ = {
			isa = PBXGroup;
			children = (
				E0A1000028000000 /* TGPanel.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		E0A1040028000000 /* TGPanel */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = E0A1050028000000 /* Build configuration list for PBXNativeTarget "TGPanel" */;
			buildPhases = (
				E0A1060028000000 /* Sources */,
				E0A1020028000000 /* Frameworks */,
				E0A1070028000000 /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = TGPanel;
			productName = TGPanel;
			productReference = E0A1000028000000 /* TGPanel.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		E0A1080028000000 /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
				TargetAttributes = {
					E0A1040028000000 = {
						CreatedOnToolsVersion = 15.0;
					};
				};
			};
			buildConfigurationList = E0A1090028000000 /* Build configuration list for PBXProject "TGPanel" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = zh_CN;
			hasScannedForEncodings = 0;
			knownRegions = (
				zh_CN,
				Base,
			);
			mainGroup = E0A1030028000000;
			productRefGroup = E0A1030228000002 /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				E0A1040028000000 /* TGPanel */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		E0A1070028000000 /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				E0A1010528000005 /* Assets.xcassets in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		E0A1060028000000 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				E0A1010128000001 /* ContentView.swift in Sources */,
				E0A1010228000002 /* PanelViewModel.swift in Sources */,
				E0A1010328000003 /* ThemeManager.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		E0A10A0128000001 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 7;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = TGPanelApp/Info.plist;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				MARKETING_VERSION = 3.7.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.tgpanel.liquidglass;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Debug;
		};
		E0A10A0228000002 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CODE_SIGNING_ALLOWED = NO;
				CODE_SIGN_STYLE = Manual;
				CURRENT_PROJECT_VERSION = 7;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = TGPanelApp/Info.plist;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				MARKETING_VERSION = 3.7.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.tgpanel.liquidglass;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Release;
		};
		E0A10A0328000003 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				SDKROOT = iphoneos;
			};
			name = Debug;
		};
		E0A10A0428000004 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				SDKROOT = iphoneos;
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		E0A1050028000000 /* Build configuration list for PBXNativeTarget "TGPanel" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				E0A10A0128000001 /* Debug */,
				E0A10A0228000002 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		E0A1090028000000 /* Build configuration list for PBXProject "TGPanel" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				E0A10A0328000003 /* Debug */,
				E0A10A0428000004 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */

	};
	rootObject = E0A1080028000000 /* Project object */;
}
`;
fs.writeFileSync(path.join(xcodeDir, 'project.pbxproj'), pbxproj.trim());

console.log('✅ Xcode project updated with ThemeManager.swift!');
