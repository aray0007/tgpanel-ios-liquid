const fs = require('fs');
const path = require('path');

const baseDir = __dirname;
const tgPanelDir = path.join(baseDir, 'TGPanelApp');
const wwwDir = path.join(tgPanelDir, 'www');
const xcodeDir = path.join(baseDir, 'TGPanel.xcodeproj');
const workflowsDir = path.join(baseDir, '.github', 'workflows');

[tgPanelDir, wwwDir, xcodeDir, workflowsDir].forEach(d => {
  if (!fs.existsSync(d)) fs.mkdirSync(d, { recursive: true });
});

// 1. Copy web assets to TGPanelApp/www
['index.html', 'styles.css', 'app.js', 'manifest.json', 'AppIcon60x60@2x.png', 'AppIcon60x60@3x.png'].forEach(f => {
  const src = path.join(baseDir, f);
  if (fs.existsSync(src)) {
    fs.copyFileSync(src, path.join(wwwDir, f));
  }
});

// 2. AppDelegate.swift
const appDelegateCode = `
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        return true
    }
}
`;
fs.writeFileSync(path.join(tgPanelDir, 'AppDelegate.swift'), appDelegateCode.trim());

// 3. SceneDelegate.swift
const sceneDelegateCode = `
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
    }
}
`;
fs.writeFileSync(path.join(tgPanelDir, 'SceneDelegate.swift'), sceneDelegateCode.trim());

// 4. ViewController.swift
const viewControllerCode = `
import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 6/255, green: 8/255, blue: 13/255, alpha: 1.0)
        
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.preferences.javaScriptEnabled = true
        
        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        view.addSubview(webView)
        loadLocalContent()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func loadLocalContent() {
        if let wwwPath = Bundle.main.path(forResource: "index", ofType: "html", inDirectory: "www") {
            let url = URL(fileURLWithPath: wwwPath)
            webView.loadFileURL(url, allowingReadAccessToURL: url.deletingLastPathComponent())
        } else if let indexPath = Bundle.main.path(forResource: "index", ofType: "html") {
            let url = URL(fileURLWithPath: indexPath)
            webView.loadFileURL(url, allowingReadAccessToURL: url.deletingLastPathComponent())
        }
    }
}
`;
fs.writeFileSync(path.join(tgPanelDir, 'ViewController.swift'), viewControllerCode.trim());

// 5. Info.plist in TGPanelApp
const infoPlist = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>zh_CN</string>
    <key>CFBundleDisplayName</key>
    <string>TG管理面板</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>com.tgpanel.liquidglass</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>3.2.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UIApplicationSceneManifest</key>
    <dict>
        <key>UIApplicationSupportsMultipleScenes</key>
        <false/>
        <key>UISceneConfigurations</key>
        <dict>
            <key>UIWindowSceneSessionRoleApplication</key>
            <array>
                <dict>
                    <key>UISceneConfigurationName</key>
                    <string>Default Configuration</string>
                    <key>UISceneDelegateClassName</key>
                    <string>$(PRODUCT_MODULE_NAME).SceneDelegate</string>
                </dict>
            </array>
        </dict>
    </dict>
    <key>UILaunchScreen</key>
    <dict/>
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>arm64</string>
    </array>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
</dict>
</plist>
`;
fs.writeFileSync(path.join(tgPanelDir, 'Info.plist'), infoPlist.trim());

// 6. Xcode project.pbxproj
const pbxproj = `// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
		E0A1010128000001 /* AppDelegate.swift in Sources */ = {isa = PBXBuildFile; fileRef = E0A1000128000001 /* AppDelegate.swift */; };
		E0A1010228000002 /* SceneDelegate.swift in Sources */ = {isa = PBXBuildFile; fileRef = E0A1000228000002 /* SceneDelegate.swift */; };
		E0A1010328000003 /* ViewController.swift in Sources */ = {isa = PBXBuildFile; fileRef = E0A1000328000003 /* ViewController.swift */; };
		E0A1010428000004 /* www in Resources */ = {isa = PBXBuildFile; fileRef = E0A1000428000004 /* www */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		E0A1000028000000 /* TGPanel.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = TGPanel.app; sourceTree = BUILT_PRODUCTS_DIR; };
		E0A1000128000001 /* AppDelegate.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AppDelegate.swift; sourceTree = "<group>"; };
		E0A1000228000002 /* SceneDelegate.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SceneDelegate.swift; sourceTree = "<group>"; };
		E0A1000328000003 /* ViewController.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ViewController.swift; sourceTree = "<group>"; };
		E0A1000428000004 /* www */ = {isa = PBXFileReference; lastKnownFileType = folder; path = www; sourceTree = "<group>"; };
		E0A1000528000005 /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
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
				E0A1000128000001 /* AppDelegate.swift */,
				E0A1000228000002 /* SceneDelegate.swift */,
				E0A1000328000003 /* ViewController.swift */,
				E0A1000428000004 /* www */,
				E0A1000528000005 /* Info.plist */,
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
				E0A1010428000004 /* www in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		E0A1060028000000 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				E0A1010128000001 /* AppDelegate.swift in Sources */,
				E0A1010228000002 /* SceneDelegate.swift in Sources */,
				E0A1010328000003 /* ViewController.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		E0A10A0128000001 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = TGPanelApp/Info.plist;
				IPHONEOS_DEPLOYMENT_TARGET = 15.0;
				MARKETING_VERSION = 3.2.0;
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
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CODE_SIGNING_ALLOWED = NO;
				CODE_SIGN_STYLE = Manual;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = TGPanelApp/Info.plist;
				IPHONEOS_DEPLOYMENT_TARGET = 15.0;
				MARKETING_VERSION = 3.2.0;
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

// 7. GitHub Actions Workflow
const githubWorkflow = `
name: Build iOS IPA

on:
  push:
    branches: [ main, master ]
  workflow_dispatch:

jobs:
  build-ipa:
    runs-on: macos-14
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.4.app/Contents/Developer

      - name: Build and Archive
        run: |
          xcodebuild -project TGPanel.xcodeproj \\
            -scheme TGPanel \\
            -configuration Release \\
            -sdk iphoneos \\
            -destination 'generic/platform=iOS' \\
            -archivePath build/TGPanel.xcarchive \\
            archive \\
            CODE_SIGNING_ALLOWED=NO

      - name: Package Payload into IPA
        run: |
          mkdir -p Payload
          cp -r build/TGPanel.xcarchive/Products/Applications/TGPanel.app Payload/
          zip -r -9 TGPanel_LiquidGlass.ipa Payload
          ls -lh TGPanel_LiquidGlass.ipa

      - name: Upload IPA Artifact
        uses: actions/upload-artifact@v4
        with:
          name: TGPanel_LiquidGlass_IPA
          path: TGPanel_LiquidGlass.ipa
`;
fs.writeFileSync(path.join(workflowsDir, 'build-ipa.yml'), githubWorkflow.trim());

console.log('✅ Complete Swift Xcode project & GitHub Actions workflow successfully created!');
