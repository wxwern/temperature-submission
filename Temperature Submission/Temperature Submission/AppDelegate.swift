//
//  AppDelegate.swift
//  Temperature Submission
//
//  Created by Wern on 26/6/20.
//  Copyright © 2020 Wern. All rights reserved.
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
        UIApplication.shared.applicationIconBadgeNumber = 0
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        if let I = userActivity.interaction,
            let i = I.intent as? SubmitTemperatureIntent {
            
            let temp = i.temperature
            if let tempStr = temp?.stringValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if let vc = homeVC {
                        if let wvi = vc.webViewInjector, !wvi.submitting || wvi.submissionTaskNotResponding {
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
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .badge, .sound])
    }
    
}
