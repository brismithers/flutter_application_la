import Foundation

import ActivityKit
import Flutter
import Foundation

class LiveActivitiesManager {
    private static var callbackChannel: FlutterMethodChannel? = nil
    private static var managerChannel: FlutterMethodChannel? = nil
    
    public static func register(controller: FlutterViewController) {
        // Setup the iOS native->Flutter channel. This is primarily used to allow iOS to tell Flutter
        // when there is a new Live Activity update push token.
        // The name here must be equivalent to the name for `_callbackMethodChannel` in `lib/live_activities_manager.dart`
        callbackChannel = FlutterMethodChannel(
                    name: "com.example.flutter_application_la/liveActivitiesCallback",
                    binaryMessenger: controller.binaryMessenger
                )
        
        // Setup the Flutter->iOS native channel. Currently supports `startLiveActivity` but can be
        // expanded for more if needed.
        // The name here must be equivalent to the name for `_managerMethodChannel` in `lib/live_activities_manager.dart`
        managerChannel = FlutterMethodChannel(
                    name: "com.example.flutter_application_la/liveActivitiesManager",
                    binaryMessenger: controller.binaryMessenger
                )
        managerChannel?.setMethodCallHandler(handleMethodCall)
    }
    
    static func handleMethodCall(call: FlutterMethodCall, result: FlutterResult) {
        switch call.method {
        case "startLiveActivity":
            LiveActivitiesManager.startLiveActivity(
                data: call.arguments as? Dictionary<String,Any> ?? [String: Any](),
                result: result)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    static func startLiveActivity(data: [String: Any], result: FlutterResult) {
        if #unavailable(iOS 16.1) {
            result(FlutterError(code: "1", message: "Live activity supported on 16.1 and higher", details: nil))
        }
        
        let attributes = WidgetExtensionAttributes(name: data["name"] as? String ?? "LA Title")
        
        let state = WidgetExtensionAttributes.ContentState(
            emoji: data["emoji"] as? String ?? "😀"
        )
        
        if #available(iOS 16.1, *) {
            do {
                let newActivity = try Activity<WidgetExtensionAttributes>.request(
                    attributes: attributes,
                    contentState: state,
                    pushType: .token)
                
                Task {
                    for await pushToken in newActivity.pushTokenUpdates {
                        let token = pushToken.map {String(format: "%02x", $0)}.joined()
                        callbackChannel?.invokeMethod("updatePushTokenCallback", arguments: ["activityId": data["activityId"], "token": token ])
                    }
                }
            } catch let error {
                result(FlutterError(code: "2", message: "Error requesting live activity", details: nil))
            }
        }
    }
}
