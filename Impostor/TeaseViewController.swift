//
//  TeaseViewController.swift
//  Impostor
//
//  Created by Full Decent on 2/20/16.
//  Copyright © 2016 William Entriken. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class TeaseViewController: UIViewController {
    @IBOutlet weak var spy: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        FIRAnalytics.logEventWithName(kFIREventViewItem, parameters: [
            kFIRParameterContentType:"view",
            kFIRParameterItemID:NSStringFromClass(self.dynamicType)
            ])
        
        let bounceAnimation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        bounceAnimation.values = [0, M_PI * 8]
        bounceAnimation.duration = 3
        bounceAnimation.removedOnCompletion = true
        bounceAnimation.repeatCount = 0
        bounceAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        self.spy.layer.addAnimation(bounceAnimation, forKey: "spin")
        self.performSelector(#selector(TeaseViewController.close), withObject: self, afterDelay: 5)
    }
    
    func close() {
        self.navigationController!.popToRootViewControllerAnimated(true)
    }
}