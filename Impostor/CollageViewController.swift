//
//  CollageViewController.swift
//  Impostor
//
//  Created by Full Decent on 6/20/16.
//  Copyright © 2016 William Entriken. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import AudioToolbox

class CollageViewController: UIViewController {
    private var game = ImpostorGameModel.game
    private var audioPlayer: AVAudioPlayer = {
        let url = NSBundle.mainBundle().URLForResource("camera", withExtension: "mp3")!
        return try! AVAudioPlayer(contentsOfURL: url)
    }()
    
    @IBOutlet weak var playerPhotoCollectionView: UICollectionView!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        FIRAnalytics.logEventWithName(kFIREventViewItem, parameters: [
            kFIRParameterContentType:"view",
            kFIRParameterItemID:NSStringFromClass(self.dynamicType)
            ])
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let root = navigationController!.viewControllers.first as! GameConfigurationViewController
        root.fadeOutMusic()
    }
    
    func flashScreen() {
        dispatch_async(dispatch_get_main_queue(), {
            self.audioPlayer.play()
            let flashView = UIView(frame: self.view.frame)
            flashView.backgroundColor = UIColor.whiteColor()
            self.view!.window!.addSubview(flashView)
            UIView.animateWithDuration(0.7, animations: {
                flashView.alpha = 0.0
                }, completion: {
                    _ in
                    flashView.removeFromSuperview()
            })
        })
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        view!.setNeedsLayout()
    }
    
    @IBAction func wantToShare() {
        self.performSelector(#selector(CollageViewController.flashScreen), withObject: nil, afterDelay: 0.1)
        self.performSelector(#selector(CollageViewController.showShareBox), withObject: nil, afterDelay: 0.4)
    }
    
    func showShareBox() {
        // Create the item to share (in this example, a url)
        // http://stackoverflow.com/a/25837053/300224
        let mainBundle = NSBundle.mainBundle()
        let displayName = mainBundle.objectForInfoDictionaryKey("CFBundleDisplayName") as? String
        let name = mainBundle.objectForInfoDictionaryKey(kCFBundleNameKey as String) as? String
        let appName = displayName ?? name ?? "Unknown"
        let url = NSURL(string: "https://itunes.apple.com/us/app/whos-the-impostor/id784258202")!
        let title = String(format: NSLocalizedString("I am playing the party game %@", comment:"Number of players in the game"), appName)
        UIGraphicsBeginImageContext(self.view.frame.size)
        for subView in self.view.subviews {
            if subView is UIButton {
                subView.hidden = true
            }
        }
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        for subView in self.view.subviews {
            if subView is UIButton {
                subView.hidden = false
            }
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let itemsToShare: [AnyObject] = [image, title, url]
        let activityVC: UIActivityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypeAssignToContact]
        activityVC.completionWithItemsHandler = {
            activityType, completed, returnedItems, activityError in
            FIRAnalytics.logEventWithName("action", parameters: [
                "viewController":NSStringFromClass(self.dynamicType),
                "function":#function,
                "extra": "Success"
                ])
        }
        self.presentViewController(activityVC, animated: true, completion: { _ in })
    }

    @IBAction func returnToMainScreen() {
        self.navigationController!.popToRootViewControllerAnimated(true)
    }
}

extension CollageViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.game.numberOfPlayers
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = playerPhotoCollectionView.dequeueReusableCellWithReuseIdentifier("playerCell", forIndexPath: indexPath)
        let imageView = cell.viewWithTag(1) as! UIImageView
        let imageName = "\(Int(indexPath.row))"
        if let photo = CachedPersistentJPEGImageStore.sharedStore.imageWithName(imageName) {
            imageView.image = photo
        } else {
            imageView.image = UIImage(named: "defaultHeadshot.png")!
        }
        
        let degrees = Double(Int(arc4random_uniform(31)) - 15)
        let radians = CGFloat(degrees * M_PI / 180)
        imageView.transform = CGAffineTransformMakeRotation(radians)
        let bounceAnimation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        bounceAnimation.values = [0, radians * 0.5, -radians * 2, radians]
        bounceAnimation.duration = Double(arc4random_uniform(10) / 10)
        bounceAnimation.removedOnCompletion = true
        bounceAnimation.repeatCount = 0
        bounceAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        imageView.layer.addAnimation(bounceAnimation, forKey: "spin")
        self.makeItBounce(imageView)
        
        return cell
    }
    
    override func viewDidLayoutSubviews() {
        var highestWorking = 0
        var lowestNotWorking = 9999
        while lowestNotWorking > highestWorking + 1 {
            let currentTest = (highestWorking + lowestNotWorking) / 2
            let cols = Int(playerPhotoCollectionView.frame.size.width + 10) / (currentTest + 10)
            let rows = Int(playerPhotoCollectionView.frame.size.height + 10) / (currentTest + 10)
            if cols * rows >= game.numberOfPlayers {
                highestWorking = currentTest
            } else {
                lowestNotWorking = currentTest
            }
        }
        let size = CGSizeMake(CGFloat(highestWorking), CGFloat(highestWorking))
        (self.playerPhotoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = size
        super.viewDidLayoutSubviews()
    }
    
    func makeItBounce(view: UIView) {
        let bounceAnimation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0, 1.2]
        bounceAnimation.duration = 0.15
        bounceAnimation.removedOnCompletion = false
        bounceAnimation.repeatCount = 2
        bounceAnimation.autoreverses = true
        bounceAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        view.layer.addAnimation(bounceAnimation, forKey: "bounce")
    }
}
