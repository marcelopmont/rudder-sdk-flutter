import UIKit
import Flutter
import BrazeKit
import Rudder_Braze

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      registerForPushNotifications(application)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    func registerForPushNotifications(_ application: UIApplication) {
        DispatchQueue.main.async {
            application.registerForRemoteNotifications()
            let center = UNUserNotificationCenter.current()
            center.setNotificationCategories(Braze.Notifications.categories)
            center.delegate = self
            var options: UNAuthorizationOptions = [.alert, .sound, .badge]
            if #available(iOS 12.0, *) {
                options = UNAuthorizationOptions(rawValue: options.rawValue | UNAuthorizationOptions.provisional.rawValue)
            }
            center.requestAuthorization(options: options) { granted, error in
                print("Notification authorization, granted: \(granted), error: \(String(describing: error))")
            }
        }
    }
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 15) {
            RudderBrazeFactory.instance().integration?.didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
        }
    }
    
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        RudderBrazeFactory.instance().integration?.didReceiveRemoteNotification(userInfo, fetchCompletionHandler: completionHandler)
    }
    
    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        RudderBrazeFactory.instance().integration?.didReceive(response, withCompletionHandler: completionHandler)
    }
    
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([.list, .banner])
        } else {
            completionHandler([.alert])
        }
    }
    
}
