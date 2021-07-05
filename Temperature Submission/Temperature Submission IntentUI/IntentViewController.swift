//
//  IntentViewController.swift
//  Temperature Submission IntentUI
//
//  Created by Wern Jie Lim on 4/7/21.
//  Copyright © 2021 Wern Jie Lim. All rights reserved.
//

import IntentsUI
import WebKit


class IntentViewController: UIViewController, INUIHostedViewControlling {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var infoLabel: UILabel!
    
    var imageViewTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.imageView.image = nil
        self.infoLabel.text = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        imageViewTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { t in
            if WebViewInjector.submissionTaskNotResponding {
                self.infoLabel.textColor = .systemRed
                self.infoLabel.text = "Not Responding\nTap to retry in app"
            } else {
                self.infoLabel.textColor = .systemGray
                self.infoLabel.text = nil
                if self.imageView != nil {
                    self.imageView.image = WebViewInjector.retrieveCachedSnapshot()
                    self.activityIndicator.color = .gray
                }
                
                if WebViewInjector.submitting {
                    self.activityIndicator.startAnimating()
                } else {
                    self.activityIndicator.stopAnimating()
                }
            }
        })
        
        imageViewTimer?.fire()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        imageViewTimer?.invalidate()
    }
        
    // MARK: - INUIHostedViewControlling
    
    // Prepare your view controller for the interaction to handle.
    func configureView(for parameters: Set<INParameter>, of interaction: INInteraction, interactiveBehavior: INUIInteractiveBehavior, context: INUIHostedViewContext, completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void) {
        // Do configuration here, including preparing views and calculating a desired size for presentation.
        
        print("configuration called")
        completion(true, parameters, self.desiredSize)
        return
    }
    
    var desiredSize: CGSize {
        let maxSize = self.extensionContext!.hostedViewMaximumAllowedSize
        let width = maxSize.width
        let height = min(maxSize.height, width/1.6)
        return CGSize(width: width, height: height)
    }
    
}
