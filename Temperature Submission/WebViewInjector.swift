//
//  WebViewInjector.swift
//  Temperature Submission
//
//  Created by Wern Jie Lim on 4/7/21.
//  Copyright © 2021 Wern Jie Lim. All rights reserved.
//

import Foundation
import UIKit
import WebKit


// MARK: - Global References
public var universalStorage: UserDefaults? {
    return UserDefaults.init(suiteName: "group.com.limwernjie.TempSubmission")
}
public var AGREES_TERMS: Bool {
    set (x) {
        universalStorage?.set(TERMS_KEY, forKey: "AGREES_TERMS")
    }
    get {
        return universalStorage?.string(forKey: "AGREES_TERMS") == TERMS_KEY
    }
}

fileprivate let TERMS_KEY = "2LigGKDa" // modify this key when the terms are modified
public let termsList = [
    "You must be an\nNUS High BOARDER\nto use the app.",
    "You must also be an\nNUS High STUDENT\nto use the app.",
    "You will only use automations provided by the app when you are not sick.\n\nThis means you do not have cough or runny nose symptoms at the time of automation.",
    "You must not provide a fake temperature when using the automations provided by the app.",
    "You must perform SafeEntry every morning as per requirements for staying in boarding.\n\nThis can be done with a combined automation (e.g. using TraceTogether and this app's Siri Shortcuts together) or manually otherwise.",
    "The developer is not liable against any misconduct in conjunction with the app, especially due to code modifications or disagreeing with the Terms of Use of this app.",
]

// MARK: - WebViewInjector helper class
class WebViewInjector {
    
    let DEBUG = false
    
    // MARK: Initialisation
    let webView: WKWebView
    var infoLabel: UILabel?
    var uiDelegate: WKUIDelegate? { didSet {webView.uiDelegate = uiDelegate} }
    var navigationDelegate: WKNavigationDelegate?  { didSet {webView.navigationDelegate = navigationDelegate} }
    var alertOverViewController: UIViewController?
    var application: UIApplication?
    
    init(_ webView: WKWebView, _ infoLabel: UILabel?, _ application: UIApplication?) {
        self.webView = webView
        self.infoLabel = infoLabel
        self.application = application
        
        uiDelegate = webView.uiDelegate
        navigationDelegate = webView.navigationDelegate
        
        webView.load(URLRequest(url: URL(string: TARGET_LINK_1)!))
    }
    
    // MARK: Injection information
    // Boarding Form
    var TARGET_LINK_1: String {
        if DEBUG {
            return "https://forms.office.com/Pages/ResponsePage.aspx?id=cnEq1_jViUiahddCR1FZKpO58bcqjRJKtv5Qyvw9ZyNUMFNJN0YwRFFUOTRBSExXWjk3WEFIOFlOUi4u"
        } else {
            return "https://forms.office.com/Pages/ResponsePage.aspx?Host=Teams&lang=%257Blocale%257D&groupId=%257BgroupId%257D&tid=%257Btid%257D&teamsTheme=%257Btheme%257D&upn=%257Bupn%257D&id=cnEq1_jViUiahddCR1FZKrSDtF2HnuNPvEDBSEyQ_DFUMktVVzUwT0NSVEVDRFJIR0tFUjE1TFY1MC4u"
        }
    }

    // School form
    var TARGET_LINK_2: String {
        if DEBUG {
            return "https://forms.office.com/Pages/ResponsePage.aspx?id=cnEq1_jViUiahddCR1FZKpO58bcqjRJKtv5Qyvw9ZyNURDFVUk5LV1FQR1NGRzFaNzNHRkJSTTdUVi4u"
        } else {
            return "https://forms.office.com/Pages/ResponsePage.aspx?id=cnEq1_jViUiahddCR1FZKi_YUnieBUBCi4vce5KjIHVUMkoxVUdBMVo2VUJTNFlSU1dFNEtNWUwxNS4u"
        }
    }
    
    // URL Description
    var urlDesc: [String: String] {
        return [
            TARGET_LINK_1: "Boarding",
            TARGET_LINK_2: "School"
        ]
    }
    
    // URL Scripts
    var scripts: [String: String] {
        return [
            TARGET_LINK_1:
        """
        window.setNativeValue = function(input, newValue) {
            /** see: https://github.com/facebook/react/issues/11488#issuecomment-347775628 **/
            let lastValue = input.value;
            input.value = newValue;
            let event = new Event('input', { bubbles: true });
            // hack React15
            event.simulated = true;
            // hack React16 内部定义了descriptor拦截value，此处重置状态
            let tracker = input._valueTracker;
            if (tracker) {
                tracker.setValue(lastValue);
            }
            input.dispatchEvent(event);
        }
        window.simulateMouseClick = function(element){
            const mouseClickEvents = ['mousedown', 'click', 'mouseup'];
            mouseClickEvents.forEach(mouseEventType =>
                element.dispatchEvent(
                    new MouseEvent(mouseEventType, {
                        view: window,
                        bubbles: true,
                        cancelable: true,
                        buttons: 1
                    })
                )
            );
        }
        setTimeout(function() {
            console.log('filling in time measured')
            let questions = document.getElementsByClassName('__question__');
            questions[0].getElementsByTagName('input')[0].click(); //temperature taken 5 minutes ago
        }, 500);
        setTimeout(function() {
            console.log('filling in temp and symptoms')
            let questions = document.getElementsByClassName('__question__');

            setNativeValue(questions[1].getElementsByTagName('input')[0], TEMPERATURE_PLACEHOLDER); //fill in temperature
            questions[2].getElementsByTagName('input')[1].click(); //no cough
            questions[3].getElementsByTagName('input')[1].click(); //no runny nose
        }, 1000);
        setTimeout(function() {
            console.log('attempting to go to next page')
            let nextButton = Array.from(
                document.getElementsByClassName('office-form-body')[0]
                        .getElementsByTagName('button')
            ).find(ele => ele.ariaLabel == 'Next');
            simulateMouseClick(nextButton); //click next button
        }, 2000);
        setTimeout(function() {
            console.log('filling in last page')
            let questions = document.getElementsByClassName('__question__');
            questions[0].getElementsByTagName('input')[0].click(); //yes

            console.log('submitting')
            let submit = document.querySelector('button.__submit-button__');
            submit.click();
        }, 2500);
        """,
            TARGET_LINK_2:
        """
        window.setNativeValue = function(input, newValue) {
            /** see: https://github.com/facebook/react/issues/11488#issuecomment-347775628 **/
            let lastValue = input.value;
            input.value = newValue;
            let event = new Event('input', { bubbles: true });
            // hack React15
            event.simulated = true;
            // hack React16 内部定义了descriptor拦截value，此处重置状态
            let tracker = input._valueTracker;
            if (tracker) {
                tracker.setValue(lastValue);
            }
            input.dispatchEvent(event);
        }
        window.simulateMouseClick = function(element){
            const mouseClickEvents = ['mousedown', 'click', 'mouseup'];
            mouseClickEvents.forEach(mouseEventType =>
                element.dispatchEvent(
                    new MouseEvent(mouseEventType, {
                        view: window,
                        bubbles: true,
                        cancelable: true,
                        buttons: 1
                    })
                )
            );
        }
        setTimeout(function() {
            // temperature field
            let qn = document.querySelector('div.office-form-question-content');
            let input = qn.querySelector('input');
            console.log('filling in temp')
            setNativeValue(input,TEMPERATURE_PLACEHOLDER);

            // check the email receipt box as well
            console.log('lets have an email receipt shall we')
            let checkbox = document.querySelector('div.office-form-email-receipt-checkbox input[type="checkbox"]');
            checkbox.click();
        }, 500);
        setTimeout(function() {
            // alright, submit!
            console.log('submitting')
            let btn = document.querySelector('button[title="Submit"]');
            btn.click();
        }, 1500);
        """
        ]
    }
    
    // MARK: Internal Helper Functions
    private func hasKeyword(_ keyword: String, completion: @escaping (Bool) -> ()) {
        
        let js_str = "[document.body.innerText.toLowerCase().includes('" +  keyword.lowercased().replacingOccurrences(of: "'", with: "\\'").replacingOccurrences(of: "\\", with: "\\\\") + "')]"
        
        self.webView.evaluateJavaScript(js_str) { (res, err) in
            
            if let res = res as? [Any],
               let ans = res.first as? Bool,
               ans {
                
                completion(true)
                return
            } else if let err = err {
                print("JS ERROR")
                print(err)
                completion(false)
            } else {
                completion(false)
            }
        }
        
    }
    private func hasAnyOfKeywords(_ keywords: [String], completion: @escaping (Bool) -> ()) {
        if keywords.count == 0 {
            completion(false)
            return
        }
        
        self.hasKeyword(keywords.first!) { success in
            if success {
                completion(true)
                return
            }
            self.hasAnyOfKeywords(Array<String>(keywords.dropFirst()), completion: completion)
        }
    }
    
    private func waitForKeyword(_ keyword: String, terminateIfKeywords terminationKeywords: [String] = [], timeout: Int = 15, completion: @escaping (Bool) -> ()) {
        if timeout <= 0 {
            completion(false)
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let js_str = "[document.body.innerText.toLowerCase().includes('" +  keyword.lowercased().replacingOccurrences(of: "'", with: "\\'").replacingOccurrences(of: "\\", with: "\\\\") + "')]"
            
            self.webView.evaluateJavaScript(js_str) { (res, err) in
                
                if let res = res as? [Any],
                    let ans = res.first as? Bool,
                    ans {
                    
                    completion(true)
                    return
                } else if let err = err {
                    print("JS ERROR")
                    print(err)
                    if (timeout - 1) <= 0 {
                        _ = self.alert("JS ERROR (keyword \(keyword))",js_str + "\n\(err)")
                        completion(false)
                        return
                    }
                    print("retrying...")
                }
                
                self.hasAnyOfKeywords(terminationKeywords) { (shouldTerminate) in
                    if shouldTerminate {
                        completion(false)
                    } else {
                        self.waitForKeyword(keyword,
                                            terminateIfKeywords: terminationKeywords,
                                            timeout: timeout - 1,
                                            completion: completion)
                    }
                }
            }
        }
    }
    
    private func alert(_ title: String?, _ message: String?) -> UIAlertController {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        alertOverViewController?.present(a, animated: true, completion: nil)
        return a
    }
    
    
    // MARK: Temperature Submission Functions
    public private(set) var submitting: Bool {
        get {
            return universalStorage?.bool(forKey: "submitting") == true
        }
        set(x) {
            universalStorage?.set(x, forKey: "submitting")
            universalStorage?.synchronize()
            if x {
                submittingCacheSnapshotTimer?.invalidate()
                submittingCacheSnapshotTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { t in
                    self.cacheSnapshot()
                })
            } else {
                submittingCacheSnapshotTimer?.fire()
                submittingCacheSnapshotTimer?.invalidate()
                submittingCacheSnapshotTimer = nil
            }
        }
    }
    public private(set) var success: Bool?
    private var submittingCacheSnapshotTimer: Timer?
    
    public func performAutoSubmissionAll(temp: String) {
        if submitting {
            let lastUpdate = retrieveCachedSnapshotDate()
            if lastUpdate == nil || -lastUpdate!.timeIntervalSinceNow >= 5 {
                
                print("bypassing possibly terminated submission with lurking lock, since no snapshot updates are present")
                submitting = false
                
            } else {
                
                print("submission in progress, ignoring attempt")
                return
            }
        }
        submitting = true
        success = nil
        self.performAutoSubmission(url: self.TARGET_LINK_1, temp: temp) { (success) in
            if success {
                let date = Date()
                let calendar = Calendar.current
                
                let y = calendar.component(.year, from: date)
                let m = calendar.component(.month, from: date)
                let d = calendar.component(.day, from: date)
                let h = calendar.component(.hour, from: date)
                
                //if y == 2021 && m == 5 && h < 12 && ([19,20,21,24,25,27,28].contains(d) || self.DEBUG) {
                if y == 2021 && h < 12 && ((d == 30 && m == 6) || (d == 1 && m == 7) || self.DEBUG) {
                    self.performAutoSubmission(url: self.TARGET_LINK_2, temp: temp) { success in
                        self.success = success
                        self.submitting = false
                    }
                } else {
                    self.success = success
                    self.submitting = false
                }
            } else {
                self.success = success
                self.submitting = false
            }
        }
    }
    
    private func performAutoSubmission(url: String? = nil, temp: String, completion: ((Bool) -> ())? = nil) {
        
        if !AGREES_TERMS {
            postNotification(message: "You do not agree to the Terms of Use for the app.", title: "Submission FAILED!", critical: true)
            completion?(false)
            return
        }
        
        let url = url ?? TARGET_LINK_1
        webView.load(URLRequest(url: URL(string: url)!))
        
        //To avoid any form of floating point error we're gonna parse temperature ourselves with ints
        let comps = temp.split(separator: ".")
        var valid = false
        if comps.count <= 2 {
            if let whole = Int(comps[0]) {
                if whole <= 37 && whole >= 36 {
                    if comps.count == 1 {
                        valid = true
                    } else {
                        if let decimal = Int(comps[1]) {
                            if whole == 37 && decimal < 5 {
                                valid = true
                            }
                            if whole == 36 {
                                valid = true
                            }
                        }
                    }
                }
            }
        }
        if !valid {
            _ = self.alert("Failed", "Invalid temperature \(temp)")
            postNotification(message: "\(temp)°C is not a valid temperature.", title: "Submission FAILED!", critical: true)
            completion?(false)
            return
        }
        
        //prepare to run in the background
        let bgTask = self.application?.beginBackgroundTask {
            postNotification(message: "Unable to run in the background for long enough.", title: "Submission FAILED!", critical: true)
            self.application?.isIdleTimerDisabled = false
            abort()
        }
        
        //Now we start the good stuff
        let AUTO = (DEBUG ? "[DEBUG] " : "") + "Auto Submitting... (" + temp + ")"
        let AUTO_DONE = (DEBUG ? "[DEBUG] " : "") + "Auto Submitted! (" + temp + ")"
        let MANU = (DEBUG ? "[DEBUG] " : "") + "Manual Submission"
        let FAIL = (DEBUG ? "[DEBUG] " : "") + "Auto Submission Failed"
        
        let EXEC_DESC = urlDesc[url]!
        var EXEC_JS = scripts[url]!

        EXEC_JS = EXEC_JS.replacingOccurrences(of: "TEMPERATURE_PLACEHOLDER", with: temp)
        
        //postNotification(message: "Submitting \(temp)°C...", title: "In Progress", id: "IN_PROGRESS_NOTIF")
        
        DispatchQueue.main.async {
            self.application?.isIdleTimerDisabled = true
            self.infoLabel?.text = AUTO
            print("waiting for temp keyword")
            
            self.waitForKeyword("temperature", terminateIfKeywords: ["not accepting responses", "has already been submitted"], timeout: 20) { success in
                if !success {
                    print("temp keyword not found")
                    self.webView.evaluateJavaScript("[document.body.innerHTML]", completionHandler: { x, e in
                        print((x as? [String])?.first ?? "")
                    })
                    clearNotifications(id: "IN_PROGRESS_NOTIF")
                    
                    self.hasAnyOfKeywords(["not accepting responses", "has already been submitted"], completion: { formClosed in
                        if formClosed {
                            _ = self.alert("Failed", "The form is not open.")
                            postNotification(message: "The form is not open.", title: "Submission to \(EXEC_DESC) FAILED!", count: 1, critical: true)
                        } else {
                            _ = self.alert("Failed", "We can't load the form.")
                            postNotification(message: "The form couldn't be loaded.", title: "Submission to \(EXEC_DESC) FAILED!", count: 1, critical: true)
                        }
                    })
                    self.infoLabel?.text = FAIL
                    self.application?.isIdleTimerDisabled = false
                    completion?(false)
                    if let bgTask = bgTask { self.application?.endBackgroundTask(bgTask) }
                    return
                }
                
                print("executed injection")
                self.webView.evaluateJavaScript(EXEC_JS) { (res, err) in
                    if let err = err {
                        print("execution failure")
                        _ = self.alert("Failed", "Couldn't inject.\n\n\(err)")
                        clearNotifications(id: "IN_PROGRESS_NOTIF")
                        postNotification(message: "There was a JavaScript error during injection:\n\(err)", title: "Submission to \(EXEC_DESC) FAILED!", count: 1, critical: true)
                        self.infoLabel?.text = FAIL
                        self.application?.isIdleTimerDisabled = false
                        completion?(false)
                        if let bgTask = bgTask { self.application?.endBackgroundTask(bgTask) }
                        return
                    }
                    
                    print("waiting for thanks keyword")
                    
                    self.waitForKeyword("Thanks!", timeout: 30) { success in
                        if success {
                            print("thanks keyword found! submission complete :D")
                            DispatchQueue.main.async {
                                self.infoLabel?.text = AUTO_DONE
                                clearNotifications(id: "IN_PROGRESS_NOTIF")
                                postNotification(message: "Your temperature, \(temp)°C, has been submitted to \(EXEC_DESC).", title: "Submitted to \(EXEC_DESC)!")
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                                self.infoLabel?.text = MANU
                            }
                            completion?(true)
                        } else {
                            print("couldn't find thanks keyword")
                            _ = self.alert("Failed", "Didn't see the 'Thanks!' remark.")
                            clearNotifications(id: "IN_PROGRESS_NOTIF")
                            postNotification(message: "We couldn't auto-detect the 'Thanks!' keyword in the form.", title: "Submission to \(EXEC_DESC) FAILED!", count: 1, critical: true)
                            self.infoLabel?.text = FAIL
                            completion?(false)
                        }
                        self.application?.isIdleTimerDisabled = false
                        if let bgTask = bgTask { self.application?.endBackgroundTask(bgTask) }
                    }
                }
            }
            
        }
    }
    
    // MARK: WebView Snapshot Caching Functions
    private func getWebViewSnapshot(completion: @escaping (UIImage?) -> ()) {
        webView.takeSnapshot(with: nil) { image, err in
            completion(image)
        }
    }
    public func clearCachedSnapshot() {
        WebViewInjector.clearCachedSnapshot()
    }
    public class func clearCachedSnapshot() {
        universalStorage?.removeObject(forKey: "webViewSnapshot")
        universalStorage?.removeObject(forKey: "webViewSnapshotDate")
    }
    public func cacheSnapshot() {
        getWebViewSnapshot() { image in
            universalStorage?.set(image?.pngData()?.base64EncodedString(), forKey: "webViewSnapshot")
            universalStorage?.set(Date().timeIntervalSince1970, forKey: "webViewSnapshotDate")
            universalStorage?.synchronize()
        }
    }
    public func retrieveCachedSnapshot() -> (UIImage?) {
        return WebViewInjector.retrieveCachedSnapshot()
    }
    public class func retrieveCachedSnapshot() -> UIImage? {
        if let base64 = universalStorage?.string(forKey: "webViewSnapshot"),
           let data  = Data(base64Encoded: base64),
           let image = UIImage(data: data) {
            return image
        }
        return nil
    }
    public func retrieveCachedSnapshotDate() -> Date? {
        return WebViewInjector.retrieveCachedSnapshotDate()
    }
    public class func retrieveCachedSnapshotDate() -> Date? {
        if let dateTI = universalStorage?.double(forKey: "webViewSnapshotDate"), dateTI != 0 {
           return Date(timeIntervalSince1970: dateTI)
        }
        return nil
    }
}

