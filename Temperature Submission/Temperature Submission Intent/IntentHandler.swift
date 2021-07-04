//
//  IntentHandler.swift
//  Temperature Submission Intent
//
//  Created by Wern Jie Lim on 26/6/20.
//  Copyright © 2020 Wern Jie Lim. All rights reserved.
//

import Foundation
import Intents
import WebKit

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        guard intent is SubmitTemperatureIntent else {
            fatalError("Unhandled Intent error : \(intent)")
        }
        return SubmitTemperatureIntentHandler()
    }
    
}

fileprivate var cookieMissing = true
fileprivate var webViewInjector: WebViewInjector?
class SubmitTemperatureIntentHandler: NSObject, SubmitTemperatureIntentHandling {
    
    override init() {
        super.init()
        print("Intents: Initialised")
    }
    
    func handle(intent: SubmitTemperatureIntent, completion: @escaping (SubmitTemperatureIntentResponse) -> Void) {
        guard let webViewInjector = webViewInjector, !cookieMissing else {
            print("Intents: Continuing in app due to limited access...")
            completion(.init(code: .continueInApp, userActivity: nil))
            return
        }
        
        if webViewInjector.submitting {
            print("Intents: Submitting...")
            let resp = SubmitTemperatureIntentResponse(code: .successInProgress, userActivity: nil)
            resp.temperature = intent.temperature
            completion(resp)
            return
        }
        
        switch webViewInjector.success {
            case true:
                print("Intents: Success")
                let resp = SubmitTemperatureIntentResponse(code: .success, userActivity: nil)
                resp.temperature = intent.temperature
                completion(resp)
            case false:
                print("Intents: Failure")
                completion(.init(code: .failureRequiringAppLaunch, userActivity: nil))
            default:
                print("Intents: Undefined?")
                completion(.init(code: .failureRequiringAppLaunch, userActivity: nil))
        }
    }
    
    func obtainCookiesConfig(completion: @escaping (WKWebViewConfiguration) -> ()) {
        cookieMissing = true
        let config = WKWebViewConfiguration()
        if let cookiesData = universalStorage?.object(forKey: "cookies") {
            guard var cookiesRaw = cookiesData as? [[String : Any]] else {
                print("Cookies format invalid, cannot read")
                cookieMissing = true
                return
            }
            
            print("Cookies obtained: \(cookiesRaw.count)")
            
            func insertCookie() {
                if cookiesRaw.isEmpty {
                    cookieMissing = false
                    completion(config)
                    return
                }
                
                let cookieRaw = cookiesRaw.first!
                var cookieProperties: [HTTPCookiePropertyKey : Any] = [:]
                for key in cookieRaw.keys {
                    cookieProperties[HTTPCookiePropertyKey(key)] = cookieRaw[key]
                }
                if let cookieObj = HTTPCookie(properties: cookieProperties) {
                    print("- obtained: \(cookieObj.name)")
                    config.websiteDataStore.httpCookieStore.setCookie(cookieObj) {
                        cookiesRaw = Array<[String : Any]>(cookiesRaw.dropFirst())
                        insertCookie()
                    }
                } else {
                    print("- parsing failure")
                }
            }
            
            insertCookie()
        } else {
            print("No cookies found! May not work!")
            cookieMissing = true
            completion(config)
        }
    }
    
    func resolveTemperature(for intent: SubmitTemperatureIntent, with completion: @escaping (SubmitTemperatureTemperatureResolutionResult) -> Void) {
        if let t = intent.temperature {
            print("Intents: Obtained temperature \(t.stringValue)")
            DispatchQueue.main.async {
                self.obtainCookiesConfig { config in
                    print("Intents: Loaded WKWebView Config")
                    if !cookieMissing {
                        webViewInjector = WebViewInjector(WKWebView(frame: .init(x: 0, y: 0, width: 1280, height: 800), configuration: config), nil, nil)
                        WebViewInjector.clearCachedSnapshot()
                        print("Intents: Loaded WKWebView")
                        
                        webViewInjector?.performAutoSubmissionAll(temp: t.stringValue)
                        print("Intents: Started auto submission")
                    }
                    completion(.success(with: t.doubleValue))
                }
            }
        } else {
            print("Intents: Requesting temperature")
            completion(.needsValue())
        }
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
    let notifications =  UNUserNotificationCenter.current()
    notifications.removeAllDeliveredNotifications()
}
