//
//  NotificationHelpers.swift
//  Temperature Submission
//
//  Created by Wern Jie Lim on 5/7/21.
//  Copyright © 2021 Wern Jie Lim. All rights reserved.
//

import Foundation
import UserNotifications

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
    let notifications =  UNUserNotificationCenter.current()
    notifications.removeAllDeliveredNotifications()
}
