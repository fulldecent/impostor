//
//  TeaseViewController.swift
//  Impostor
//
//  Created by Full Decent on 2/20/16.
//  Copyright © 2016 William Entriken. All rights reserved.
//

import UIKit
import Firebase

class TeaseViewController: UIViewController {
    @IBOutlet weak var spy: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        Analytics.logEvent(AnalyticsEventViewItem, parameters: [
            AnalyticsParameterContentType:"view" as NSObject,
            AnalyticsParameterItemID:NSStringFromClass(type(of: self)) as NSObject
            ])
        
        let bounceAnimation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        bounceAnimation.values = [0, Double.pi * 8]
        bounceAnimation.duration = 3
        bounceAnimation.isRemovedOnCompletion = true
        bounceAnimation.repeatCount = 0
        bounceAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        self.spy.layer.add(bounceAnimation, forKey: "spin")
        self.perform(#selector(TeaseViewController.close), with: self, afterDelay: 5)
    }
    
    @objc func close() {
        self.navigationController!.popToRootViewController(animated: true)
    }
}
