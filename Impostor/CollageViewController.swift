//
//  CollageViewController.swift
//  Impostor
//
//  Created by Full Decent on 6/20/16.
//  Copyright © 2016 William Entriken. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class CollageViewController: UIViewController {
    fileprivate var game = ImpostorGameModel.game
    fileprivate var audioPlayer: AVAudioPlayer = {
        let url = Bundle.main.url(forResource: "camera", withExtension: "mp3")!
        return try! AVAudioPlayer(contentsOf: url)
    }()
    
    @IBOutlet weak var playerPhotoCollectionView: UICollectionView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func flashScreen() {
        DispatchQueue.main.async(execute: {
            self.audioPlayer.play()
            let flashView = UIView(frame: self.view.frame)
            flashView.backgroundColor = UIColor.white
            self.view!.window!.addSubview(flashView)
            UIView.animate(withDuration: 0.7, animations: {
                flashView.alpha = 0.0
                }, completion: {
                    _ in
                    flashView.removeFromSuperview()
            })
        })
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        view!.setNeedsLayout()
    }
    
    @IBAction func wantToShare() {
        self.perform(#selector(CollageViewController.flashScreen), with: nil, afterDelay: 0.1)
        self.perform(#selector(CollageViewController.showShareBox), with: nil, afterDelay: 0.4)
    }
    
    @objc func showShareBox() {
        // Create the item to share (in this example, a url)
        // http://stackoverflow.com/a/25837053/300224
        let mainBundle = Bundle.main
        let displayName = mainBundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        let name = mainBundle.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String
        let appName = displayName ?? name ?? "Unknown"
        let url = URL(string: "https://itunes.apple.com/us/app/whos-the-impostor/id784258202")!
        let title = String(format: NSLocalizedString("I am playing the party game %@", comment:"Number of players in the game"), appName)
        UIGraphicsBeginImageContext(self.view.frame.size)
        for subView in self.view.subviews {
            if subView is UIButton {
                subView.isHidden = true
            }
        }
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        for subView in self.view.subviews {
            if subView is UIButton {
                subView.isHidden = false
            }
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let itemsToShare: [AnyObject] = [image!, title as AnyObject, url as AnyObject]
        let activityVC: UIActivityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.print, UIActivity.ActivityType.assignToContact]
        activityVC.completionWithItemsHandler = {
            activityType, completed, returnedItems, activityError in
        }
        self.present(activityVC, animated: true, completion: nil)
    }

    @IBAction func returnToMainScreen() {
        self.navigationController!.popToRootViewController(animated: true)
    }
}

extension CollageViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.game.numberOfPlayers
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = playerPhotoCollectionView.dequeueReusableCell(withReuseIdentifier: "playerCell", for: indexPath)
        let imageView = cell.viewWithTag(1) as! UIImageView
        let imageName = "\(Int((indexPath as NSIndexPath).row))"
        if let photo = CachedPersistentJPEGImageStore.sharedStore.imageWithName(imageName) {
            imageView.image = photo
        } else {
            imageView.image = UIImage(named: "defaultHeadshot.png")!
        }
        
        let degrees = Double.random(in: 15...15)
        let radians = CGFloat(degrees * Double.pi / 180)
        imageView.transform = CGAffineTransform(rotationAngle: radians)
        let bounceAnimation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        bounceAnimation.values = [0, radians * 0.5, -radians * 2, radians]
        bounceAnimation.duration = Double.random(in: 0...1)
        bounceAnimation.isRemovedOnCompletion = true
        bounceAnimation.repeatCount = 0
        bounceAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        imageView.layer.add(bounceAnimation, forKey: "spin")
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
        let size = CGSize(width: CGFloat(highestWorking), height: CGFloat(highestWorking))
        (self.playerPhotoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = size
        super.viewDidLayoutSubviews()
    }
    
    func makeItBounce(_ view: UIView) {
        let bounceAnimation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0, 1.2]
        bounceAnimation.duration = 0.15
        bounceAnimation.isRemovedOnCompletion = false
        bounceAnimation.repeatCount = 2
        bounceAnimation.autoreverses = true
        bounceAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        view.layer.add(bounceAnimation, forKey: "bounce")
    }
}
