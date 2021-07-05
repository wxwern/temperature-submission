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

    var handlerObj = SubmitTemperatureIntentHandler()
    override func handler(for intent: INIntent) -> Any {
        guard intent is SubmitTemperatureIntent else {
            fatalError("Unhandled Intent error : \(intent)")
        }
        return handlerObj
    }
    
}

fileprivate var webViewInjector: WebViewInjector?
class SubmitTemperatureIntentHandler: NSObject, SubmitTemperatureIntentHandling {
    
    var initAttemptComplete = false
    override init() {
        super.init()
        print("Intents: Initialised")
        
        DispatchQueue.main.async {
            WebViewInjector.initHeadless(requireCookies: true) { result in
                print("Intents: Loaded WebViewInjector")
                if let result = result {
                    webViewInjector = result
                    WebViewInjector.clearCachedSnapshot()
                }
                
                print("Intents: Init complete")
                self.initAttemptComplete = true
            }
        }
    }
    
    func handle(intent: SubmitTemperatureIntent, completion: @escaping (SubmitTemperatureIntentResponse) -> Void) {
        guard let webViewInjector = webViewInjector else {
            print("Intents: Continuing in app due to limited access...")
            completion(.init(code: .continueInApp, userActivity: nil))
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
                let resp = SubmitTemperatureIntentResponse(code: .failureRequiringAppLaunch, userActivity: nil)
                resp.temperature = intent.temperature
                completion(resp)
                
            default:
                print("Intents: Auto-submitting requested")
                if let t = intent.temperature?.stringValue, webViewInjector.canSubmit {
                    print("Intents: Calling function")
                    DispatchQueue.main.async { webViewInjector.performAutoSubmissionAll(temp: t) }
                }
                print("Intents: Returning in progress response")
                let resp = SubmitTemperatureIntentResponse(code: .successInProgress, userActivity: nil)
                resp.temperature = intent.temperature
                completion(resp)
        }
    }
    
    func resolveTemperature(for intent: SubmitTemperatureIntent, with completion: @escaping (SubmitTemperatureTemperatureResolutionResult) -> Void) {
        if let t = intent.temperature {
            if initAttemptComplete {
                print("Intents: Init wait complete, temperature \(t.stringValue)")
                completion(.success(with: t.doubleValue))
            } else {
                print("Intents: Obtained temperature \(t.stringValue), waiting for init")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.resolveTemperature(for: intent, with: completion)
                }
            }
        } else {
            print("Intents: Requesting temperature")
            completion(.needsValue())
        }
    }
    
    
}
