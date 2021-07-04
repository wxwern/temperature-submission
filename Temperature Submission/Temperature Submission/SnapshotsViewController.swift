//
//  SnapshotsViewController.swift
//  Temperature Submission
//
//  Created by Wern Jie Lim on 4/7/21.
//  Copyright © 2021 Wern Jie Lim. All rights reserved.
//

import UIKit

class SnapshotsViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var dateWatermarkLabel: UILabel!
    var imageViewTimer: Timer?
    
    func updateUI() {
        // Snapshot image update
        self.imageView.image = WebViewInjector.retrieveCachedSnapshot()
        
        // Snapshot date update
        if let date = WebViewInjector.retrieveCachedSnapshotDate() {
            var str: String?
            if #available(iOS 13.0, *) {
                let rdtf = RelativeDateTimeFormatter()
                rdtf.dateTimeStyle = .named
                str = rdtf.string(for: date)
                
            } else {
                // Fallback on earlier versions
                let df = DateFormatter()
                df.dateStyle = .short
                df.timeStyle = .short
                str = df.string(for: date)
            }
            self.dateWatermarkLabel.text = "Snapshot as of " + (str ?? "\(date)")
        } else {
            self.dateWatermarkLabel.text = "No snapshot date info"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        updateUI()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        imageViewTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { t in
            
            self.updateUI()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        imageViewTimer?.invalidate()
    }
    
    @IBAction func dismiss() {
        self.dismiss(animated: true, completion: nil)
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
