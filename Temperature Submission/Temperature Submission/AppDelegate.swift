//
//  AppDelegate.swift
//  Temperature Submission
//
//  Created by Wern Jie Lim on 26/6/20.
//  Copyright © 2020 Wern Jie Lim. All rights reserved.
//

import UIKit
import Intents

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge,.sound,.alert,.criticalAlert]) { (authorised, err) in
        }
        UNUserNotificationCenter.current().delegate = self
        clearNotifications()
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        if let I = userActivity.interaction,
            let i = I.intent as? SubmitTemperatureIntent {
            
            let temp = i.temperature
            if let tempStr = temp?.stringValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if let vc = homeVC {
                        if vc.webViewInjector?.submitting == false {
                            vc.webViewInjector?.performAutoSubmissionAll(temp: tempStr)
                        } else {
                            vc.showSubmissionSnapshot()
                        }
                    }
                }
            }
        }
        
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        clearNotifications()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .badge, .sound])
    }
    
}

func postNotification(message: String, title: String, timeInterval: TimeInterval = 0.5, count: Int = 0, critical: Bool = false, id: String? = nil) {
    //creating the notification content
    let content = UNMutableNotificationContent()
    content.title = title
    content.subtitle = ""
    content.body = message
    content.badge = count as NSNumber
    
    //Attempt to play critical sound if possible. Requires critical alert entitlement from Apple to work.
    if critical {
        content.sound = .defaultCriticalSound(withAudioVolume: 1.0)
    }
    
    //getting the notification trigger
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
    //getting the notification request
    let request = UNNotificationRequest(identifier: id ?? UUID.init().uuidString, content: content, trigger: trigger)
    //adding the notification to notification center
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
}

func clearNotifications(id: String) {
    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
}
func clearNotifications() {
    UIApplication.shared.applicationIconBadgeNumber = 1
    let notifications =  UNUserNotificationCenter.current()
    notifications.removeAllDeliveredNotifications()
    UIApplication.shared.applicationIconBadgeNumber = 0
}
