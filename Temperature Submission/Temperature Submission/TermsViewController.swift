//
//  TermsViewController.swift
//  Temperature Submission
//
//  Created by Wern Jie Lim on 11/11/20.
//  Copyright © 2020 Wern Jie Lim. All rights reserved.
//

import UIKit

fileprivate let TERMS_KEY = "2LigGKDa"
var AGREES_TERMS: Bool {
    set (x) {
        UserDefaults.standard.set(TERMS_KEY, forKey: "AGREES_TERMS")
    }
    get {
        return UserDefaults.standard.string(forKey: "AGREES_TERMS") == TERMS_KEY
    }
}
class TermsViewController: UIViewController {

    @IBOutlet var headingLabel : UILabel!
    @IBOutlet var textLabel : UILabel!
    @IBOutlet var agreeButton : UIButton!
    
    let termsList = [
        "You must be an\nNUS High BOARDER\nto use the app.",
        "You must also be an\nNUS High STUDENT\nto use the app.",
        "You will only use automations provided by the app when you are not sick.\n\nThis means you do not have cough or runny nose symptoms at the time of automation.",
        "You must not provide a fake temperature when using the automations provided by the app.",
        "You must perform SafeEntry every morning as per requirements for staying in boarding.\n\nThis can be done with a combined automation (e.g. using TraceTogether and this app's Siri Shortcuts together) or manually otherwise.",
        "The developer is not liable against any misconduct in conjunction with the app, especially due to code modifications or disagreeing with the Terms of Use of this app.",
    ]
    var idx = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        headingLabel.text = "Terms of Use (1/\(termsList.count))"
        textLabel.alpha = 0
        textLabel.text = ""
        agreeButton.isEnabled = false
        agreeButton.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showTermsIdx()
    }
    
    func showTermsIdx() {
        if (idx >= termsList.count) {
            AGREES_TERMS = true
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        self.textLabel.alpha = 0
        self.agreeButton.alpha = 0
        self.agreeButton.isEnabled = false
        
        UIView.animate(withDuration: 0.5) {
            self.textLabel.alpha = 1
            self.textLabel.text = self.termsList[self.idx]
            self.headingLabel.text = "Terms of Use (\(self.idx+1)/\(self.termsList.count))"
        }
        let time = Double(self.termsList[self.idx].count+20)/35
        Timer.scheduledTimer(withTimeInterval: time, repeats: false) { (timer) in
            UIView.animate(withDuration: 0.5) {
                self.agreeButton.isEnabled = true
                self.agreeButton.alpha = 1
            }
        }
    }
    
    @IBAction func agreeButtonPressed() {
        idx += 1
        showTermsIdx()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
