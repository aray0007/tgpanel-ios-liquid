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

// 4. ViewController.swift (Fixed Swift API parameter name)
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
        
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        config.defaultWebpagePreferences = preferences
        
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
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else if let indexPath = Bundle.main.path(forResource: "index", ofType: "html") {
            let url = URL(fileURLWithPath: indexPath)
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }
}
`;
fs.writeFileSync(path.join(tgPanelDir, 'ViewController.swift'), viewControllerCode.trim());

console.log('✅ Swift ViewController updated with modern iOS SDK method names!');
