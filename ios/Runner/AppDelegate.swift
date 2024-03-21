import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
     
        // Register Flutter channels, specifically for Live Activities
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        LiveActivitiesManager.register(controller: controller)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
