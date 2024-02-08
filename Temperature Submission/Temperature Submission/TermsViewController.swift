//
//  TermsViewController.swift
//  Temperature Submission
//
//  Created by Wern on 11/11/20.
//  Copyright © 2020 Wern. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController {

    @IBOutlet var headingLabel : UILabel!
    @IBOutlet var textLabel : UILabel!
    @IBOutlet var agreeButton : UIButton!
    

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
            self.textLabel.text = termsList[self.idx]
            self.headingLabel.text = "Terms of Use (\(self.idx+1)/\(termsList.count))"
        }
        let time = Double(termsList[self.idx].count+20)/35
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
