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
class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, UITextFieldDelegate {
    
    public var intent: SubmitTemperatureIntent {
        let intent = SubmitTemperatureIntent()
        intent.suggestedInvocationPhrase = "Submit Temperature"
        return intent
    }
    
    var addToSiriButton: INUIAddVoiceShortcutButton?
    
    @IBOutlet var bottomHeightConstraint: NSLayoutConstraint!
    @IBOutlet var infoStackView: UIStackView!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var webpageOptionsButton: UIButton!
    @IBOutlet var webView: WKWebView!
    
    var webViewInjector: WebViewInjector?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Setup UI elements
        infoLabel.text = "Manual Submission"
        
        webpageOptionsButton.layer.cornerRadius = 22
        webpageOptionsButton.clipsToBounds = true
        
        if #available(iOS 13.0, *) {
            addToSiriButton = INUIAddVoiceShortcutButton(style: .automaticOutline)
            addToSiriButton!.shortcut = INShortcut(intent: intent)
            addToSiriButton!.delegate = self
            addToSiriButton!.isHidden = true
            infoStackView.addArrangedSubview(addToSiriButton!)
        }
        bottomHeightConstraint.constant = 80
        
        webView.layer.cornerRadius = 16
        webView.clipsToBounds = true
        
        // Load web view
        webView.backgroundColor = .clear
        webView?.uiDelegate = self
        webView?.navigationDelegate = self
        
        webViewInjector = WebViewInjector(webView, self.infoLabel, UIApplication.shared)
        webViewInjector?.alertOverViewController = self
        
        // Initalise reference
        homeVC = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !AGREES_TERMS {
            self.performSegue(withIdentifier: "showTerms", sender: self)
        } else {
            self.webView.reload()
        }
    }
    
    var manualSubmitPromptAlert: UIAlertController?
    @IBAction func promptSubmit() {
        let a = UIAlertController(title: "Submit Temperature", message: "Key in temperature to try to submit now.", preferredStyle: .alert)
        var t: UITextField?
        a.addTextField { (textField) in
            textField.placeholder = "36.9"
            textField.keyboardType = .decimalPad
            textField.delegate = self
            t = textField
        }
        a.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (action) in
            if let t = t?.text {
                self.webViewInjector?.performAutoSubmissionAll(temp: t)
            }
            self.manualSubmitPromptAlert = nil
        }))
        a.addAction(UIAlertAction(title: "Not Now", style: .cancel, handler: { (action) in
            self.manualSubmitPromptAlert = nil
        }))
        manualSubmitPromptAlert = a
        self.present(a, animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if Int(string) == nil && string != "." && string != "" {
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if manualSubmitPromptAlert?.textFields?.first == textField {
            if let t = textField.text {
                self.webViewInjector?.performAutoSubmissionAll(temp: t)
                self.manualSubmitPromptAlert?.dismiss(animated: true, completion: {
                    self.manualSubmitPromptAlert = nil
                })
            }
        }
        return true
    }
    
    @IBAction func openWebpageOptions() {
        let a = UIAlertController(title: "App Options", message: "\(webView.url?.absoluteString ?? "")\n\nSelect an action:", preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "Refresh Webpage", style: .default, handler: { (action) in
            self.webView.reload()
        }))
        a.addAction(UIAlertAction(title: "Abort Webpage", style: .destructive, handler: { (action) in
            self.webView.loadHTMLString("<html><style>*{font-family:sans-serif;}</style><body>Webpage aborted</body></html>", baseURL: URL(string: "http://example.com/")!)
        }))
        for link in [webViewInjector?.TARGET_LINK_1, webViewInjector?.TARGET_LINK_2] {
            if let link = link {
                a.addAction(UIAlertAction(title: "Load \(webViewInjector?.urlDesc[link] ?? "<unknown>") Form", style: .default, handler: { (action) in
                    self.webView.load(URLRequest(url: URL(string: link)!))
                }))
            }
        }
        a.addAction(UIAlertAction(title: "Logout from MS Forms", style: .destructive, handler: { action in
            self.webView.load(URLRequest(url: URL(string: "https://www.office.com/estslogout?ru=%2F%3Fref%3Dlogout")!))
        }))
        
        #if !targetEnvironment(macCatalyst)
        if self.addToSiriButton?.isHidden == true {
            a.addAction(UIAlertAction(title: "Show 'Add to Siri' button", style: .default, handler: { (action) in
                self.addToSiriButton?.isHidden = false
                self.bottomHeightConstraint.constant = 128
            }))
        }
        #endif
        
        a.addAction(UIAlertAction(title: "Show Submission Snapshot", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "showSubmissionSnapshot", sender: self)
        }))
        
        a.addAction(UIAlertAction(title: "Show Terms of Use", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "showTerms", sender: self)
        }))
        
        a.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(a, animated: false, completion: nil)
    }
    
    func showSubmissionSnapshot() {
        self.performSegue(withIdentifier: "showSubmissionSnapshot", sender: self)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView.url?.absoluteString.contains("forms.office.com") == true {
            print("Saving cookies for Siri Extension use")
            webViewInjector?.saveCookies()
        }
        
        webViewInjector?.hasKeyword("you signed out", completion: { signedOut in
            if signedOut {
                self.webViewInjector?.eraseCookies()
            }
        })
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
