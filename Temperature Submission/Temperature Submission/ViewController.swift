//
//  ViewController.swift
//  Temperature Submission
//
//  Created by Wern Jie Lim on 26/6/20.
//  Copyright © 2020 Wern Jie Lim. All rights reserved.
//

import UIKit
import WebKit
import AVFoundation
import IntentsUI

var homeVC: ViewController?
class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    let DEBUG = false
    
    //BOARDING FORM:
    var TARGET_LINK_1: String {
        if DEBUG {
            return "https://forms.office.com/Pages/ResponsePage.aspx?id=cnEq1_jViUiahddCR1FZKpO58bcqjRJKtv5Qyvw9ZyNUMFNJN0YwRFFUOTRBSExXWjk3WEFIOFlOUi4u"
        } else {
            return "https://forms.office.com/Pages/ResponsePage.aspx?Host=Teams&lang=%257Blocale%257D&groupId=%257BgroupId%257D&tid=%257Btid%257D&teamsTheme=%257Btheme%257D&upn=%257Bupn%257D&id=cnEq1_jViUiahddCR1FZKrSDtF2HnuNPvEDBSEyQ_DFUMktVVzUwT0NSVEVDRFJIR0tFUjE1TFY1MC4u"
        }
    }

    //SCHOOL FORM:
    var TARGET_LINK_2: String {
        if DEBUG {
            return "https://forms.office.com/Pages/ResponsePage.aspx?id=cnEq1_jViUiahddCR1FZKpO58bcqjRJKtv5Qyvw9ZyNURDFVUk5LV1FQR1NGRzFaNzNHRkJSTTdUVi4u"
        } else {
            return "https://forms.office.com/Pages/ResponsePage.aspx?id=cnEq1_jViUiahddCR1FZKi_YUnieBUBCi4vce5KjIHVUMkoxVUdBMVo2VUJTNFlSU1dFNEtNWUwxNS4u"
        }
    }
    
    //URL Description
    var urlDesc: [String: String] {
        return [
            TARGET_LINK_1: "Boarding",
            TARGET_LINK_2: "School"
        ]
    }
    
    //URL Scripts
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
    
    
    public var intent: SubmitTemperatureIntent {
        let intent = SubmitTemperatureIntent()
        intent.suggestedInvocationPhrase = "Submit Temperature"
        return intent
    }
    
    @IBOutlet var infoStackView: UIStackView!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var webpageOptionsButton: UIButton!
    @IBOutlet var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Setup UI elements
        infoLabel.text = "Manual Submission"
        
        webpageOptionsButton.layer.cornerRadius = 22
        webpageOptionsButton.clipsToBounds = true
        
        let addToSiriButton = INUIAddVoiceShortcutButton(style: .automaticOutline)
        addToSiriButton.shortcut = INShortcut(intent: intent)
        addToSiriButton.delegate = self
        infoStackView.addArrangedSubview(addToSiriButton)
        
        webView.layer.cornerRadius = 10
        webView.clipsToBounds = true
        
        // Load web view
        webView.backgroundColor = .clear
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.load(URLRequest(url: URL(string: TARGET_LINK_1)!))
        
        // Initalise reference
        homeVC = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !AGREES_TERMS {
            self.performSegue(withIdentifier: "showTerms", sender: self)
        }
    }
    
    @IBAction func openWebpageOptions() {
        let a = UIAlertController(title: "App Options", message: "\(webView.url?.absoluteString ?? "")\n\nSelect an action:", preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "Refresh Webpage", style: .default, handler: { (action) in
            self.webView.reload()
        }))
        a.addAction(UIAlertAction(title: "Abort Webpage", style: .destructive, handler: { (action) in
            self.webView.loadHTMLString("<html><style>*{font-family:sans-serif;}</style><body>Webpage aborted</body></html>", baseURL: URL(string: "http://example.com/")!)
        }))
        for link in [TARGET_LINK_1,TARGET_LINK_2] {
            a.addAction(UIAlertAction(title: "Load \(urlDesc[link] ?? "<unknown>") Form", style: .default, handler: { (action) in
                self.webView.load(URLRequest(url: URL(string: link)!))
            }))
        }
        a.addAction(UIAlertAction(title: "Show Terms of Use", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "showTerms", sender: self)
        }))
        
        a.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(a, animated: false, completion: nil)
    }
    
    func waitForKeyword(_ keyword: String, timeout: Int = 10, completion: @escaping (Bool) -> ()) {
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
                
                self.waitForKeyword(keyword, timeout: timeout - 1, completion: completion)
            }
        }
    }
    
    func alert(_ title: String?, _ message: String?) -> UIAlertController {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(a, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            a.dismiss(animated: true, completion: nil)
        }
        return a
    }
    
    func performAutoSubmissionAll(temp: String) {
        self.performAutoSubmission(url: self.TARGET_LINK_1, temp: temp) { (success) in
            if success {
                let date = Date()
                let calendar = Calendar.current
                
                let y = calendar.component(.year, from: date)
                let m = calendar.component(.month, from: date)
                let d = calendar.component(.day, from: date)
                let h = calendar.component(.hour, from: date)
                
                if y == 2020 && m == 11 && h < 12 && ([12,13,16,17,18,19,20].contains(d) || self.DEBUG) {
                    self.performAutoSubmission(url: self.TARGET_LINK_2, temp: temp)
                }
            }
        }
    }
    
    func performAutoSubmission(url: String? = nil, temp: String, completion: ((Bool) -> ())? = nil) {
        
        if !AGREES_TERMS {
            postNotification(message: "You do not agree to the Terms of Use for the app.", title: "Submission FAILED!")
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
            postNotification(message: "\(temp)°C is not a valid temperature.", title: "Submission FAILED!")
            completion?(false)
            return
        }
        
        //prepare to run in the background
        let bgTask = UIApplication.shared.beginBackgroundTask {
            postNotification(message: "Unable to run in the background for long enough.", title: "Submission FAILED!")
            UIApplication.shared.isIdleTimerDisabled = false
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
        
        postNotification(message: "Submitting \(temp)°C...", title: "In Progress", id: "IN_PROGRESS_NOTIF")
        
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = true
            self.infoLabel.text = AUTO
            print("waiting for temp keyword")
            
            self.waitForKeyword("temperature") { success in
                if !success {
                    print("aaaaaaaaa")
                    _ = self.alert("Failed", "We can't load the form.")
                    clearNotifications(id: "IN_PROGRESS_NOTIF")
                    postNotification(message: "The form couldn't be loaded.", title: "Submission to \(EXEC_DESC) FAILED!", count: 1)
                    self.infoLabel.text = FAIL
                    UIApplication.shared.isIdleTimerDisabled = false
                    completion?(false)
                    UIApplication.shared.endBackgroundTask(bgTask)
                    return
                }
                
                print("executed injection")
                self.webView.evaluateJavaScript(EXEC_JS) { (res, err) in
                    if let err = err {
                        print("aaaaaaaaa")
                        _ = self.alert("Failed", "Couldn't inject.\n\n\(err)")
                        clearNotifications(id: "IN_PROGRESS_NOTIF")
                        postNotification(message: "There was a JavaScript error during injection:\n\(err)", title: "Submission to \(EXEC_DESC) FAILED!", count: 1)
                        self.infoLabel.text = FAIL
                        UIApplication.shared.isIdleTimerDisabled = false
                        completion?(false)
                        UIApplication.shared.endBackgroundTask(bgTask)
                        return
                    }
                    
                    print("waiting for thanks keyword")
                    
                    self.waitForKeyword("Thanks!", timeout: 30) { success in
                        if success {
                            DispatchQueue.main.async {
                                self.infoLabel.text = AUTO_DONE
                                clearNotifications(id: "IN_PROGRESS_NOTIF")
                                postNotification(message: "Your temperature, \(temp)°C, has been submitted to \(EXEC_DESC).", title: "Submitted to \(EXEC_DESC)!")
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                                self.infoLabel.text = MANU
                            }
                            completion?(true)
                        } else {
                            print("aaaaaaaaa")
                            _ = self.alert("Failed", "Didn't see the 'Thanks!' remark.")
                            clearNotifications(id: "IN_PROGRESS_NOTIF")
                            postNotification(message: "We couldn't auto-detect the 'Thanks!' keyword in the form.", title: "Submission to \(EXEC_DESC) FAILED!", count: 1)
                            self.infoLabel.text = FAIL
                            completion?(false)
                        }
                        UIApplication.shared.isIdleTimerDisabled = false
                        UIApplication.shared.endBackgroundTask(bgTask)
                    }
                }
            }
            
        }
    }


}


extension ViewController: INUIAddVoiceShortcutButtonDelegate {
    func present(_ addVoiceShortcutViewController: INUIAddVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        addVoiceShortcutViewController.delegate = self
        addVoiceShortcutViewController.modalPresentationStyle = .formSheet
        present(addVoiceShortcutViewController, animated: true, completion: nil)
    }
    
    func present(_ editVoiceShortcutViewController: INUIEditVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        editVoiceShortcutViewController.delegate = self
        editVoiceShortcutViewController.modalPresentationStyle = .formSheet
        present(editVoiceShortcutViewController, animated: true, completion: nil)
    }
}

extension ViewController: INUIAddVoiceShortcutViewControllerDelegate {
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: INUIEditVoiceShortcutViewControllerDelegate {
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
