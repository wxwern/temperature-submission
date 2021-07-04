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
    
    @IBOutlet var imageView: UIImageView!
    
    var imageViewTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        imageViewTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { t in
            if self.imageView != nil {
                self.imageView.image = WebViewInjector.retrieveCachedSnapshot()
            }
        })
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

func postNotification(message: String, title: String, timeInterval: TimeInterval = 0.5, count: Int = 0, critical: Bool = false, id: String? = nil) {
    //stub. incompatible
}

func clearNotifications(id: String) {
    //stub. incompatible
}
func clearNotifications() {
    //stub. incompatible
}
