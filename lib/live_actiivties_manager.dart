import 'dart:developer';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

// The flutter version of LiveActivitiesManager. The other side of these channels is in `ios/Runner/LiveActivitiesManager.swift`.
class LiveActivitiesManager {
  static const MethodChannel _managerMethodChannel = MethodChannel('com.example.flutter_application_la/liveActivitiesManager');
  static const MethodChannel _callbackMethodChannel = MethodChannel('com.example.flutter_application_la/liveActivitiesCallback');

  static register() {
    _callbackMethodChannel.setMethodCallHandler(_handleCallback);
  }

  static Future<Null> _handleCallback(MethodCall call) async {
    var args = call.arguments.cast<String, dynamic>();
    switch (call.method) {
      case 'updatePushTokenCallback':
        OneSignal.LiveActivities.enterLiveActivity(args["activityId"], args["token"]);
      default:
        log("Unrecognized callback method");
    }

    return null;
  }

  static Future<void> startLiveActivity(String activityId, String name, String emoji) async {
    try {
      await _managerMethodChannel.invokeListMethod('startLiveActivity', {'activityId': activityId, 'name': name, 'emoji': emoji});
    } catch (e, st) {
      log(e.toString(), stackTrace: st);
    }
  }
}