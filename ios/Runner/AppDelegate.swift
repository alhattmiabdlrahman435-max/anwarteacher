import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    
    if let controller = window?.rootViewController as? FlutterViewController {
      setupBadgeChannel(messenger: controller.binaryMessenger)
    }
    
    return result
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    setupBadgeChannel(messenger: engineBridge.applicationRegistrar.messenger())
  }

  private func setupBadgeChannel(messenger: FlutterBinaryMessenger) {
    let badgeChannel = FlutterMethodChannel(name: "com.anwaralola.app/badge",
                                              binaryMessenger: messenger)
    badgeChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "setBadge" {
        if let args = call.arguments as? [String: Any],
           let count = args["count"] as? Int {
          if #available(iOS 16.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(count) { error in
              if let error = error {
                print("Error setting badge: \(error.localizedDescription)")
              }
            }
          } else {
            UIApplication.shared.applicationIconBadgeNumber = count
          }
          result(true)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Count is required", details: nil))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
  }
}
