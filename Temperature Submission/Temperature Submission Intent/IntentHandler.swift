//
//  IntentHandler.swift
//  Temperature Submission Intent
//
//  Created by Wern Jie Lim on 26/6/20.
//  Copyright © 2020 Wern Jie Lim. All rights reserved.
//

import Foundation
import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        guard intent is SubmitTemperatureIntent else {
            fatalError("Unhandled Intent error : \(intent)")
        }
        return SubmitTemperatureIntentHandler()
    }
    
}

class SubmitTemperatureIntentHandler: NSObject, SubmitTemperatureIntentHandling {
    func handle(intent: SubmitTemperatureIntent, completion: @escaping (SubmitTemperatureIntentResponse) -> Void) {
        completion(.init(code: .continueInApp, userActivity: nil))
    }
    
    func resolveTemperature(for intent: SubmitTemperatureIntent, with completion: @escaping (SubmitTemperatureTemperatureResolutionResult) -> Void) {
        if let t = intent.temperature {
            completion(.success(with: t.doubleValue))
        } else {
            completion(.needsValue())
        }
    }
    
    
}
