//
//  SecretWordViewController.swift
//  Impostor
//
//  Created by William Entriken on 4/24/16.
//  Copyright © 2016 William Entriken. All rights reserved.
//

import UIKit
import AudioToolbox
import SCLAlertView_Objective_C
import FirebaseAnalytics

class SecretWordViewController: UIViewController {
    @IBOutlet weak var playerLabel: UILabel!
    @IBOutlet weak var playerImage: UIImageView!
    @IBOutlet weak var topSecretLabel: UILabel!
    var playerNumber: Int!
    
    private var game: ImpostorGameModel!
    private var sclAlertView = SCLAlertView()
    private var imagePickerController: UIImagePickerController!
    private var imagePopoverController: UIPopoverController!
    private var wantsToTakePhoto: Bool!
    private var photoDenied: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        game = ImpostorGameModel.game
        topSecretLabel.transform = CGAffineTransformMakeRotation(-10 * CGFloat(M_PI) / 180.0)
        topSecretLabel.clipsToBounds = false
    }
    
    @IBAction func showSecretWord(sender: AnyObject) {
        let url = NSBundle.mainBundle().URLForResource("peek", withExtension: "mp3")!
        var mySound: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(url, &mySound)
        AudioServicesPlaySystemSound(mySound);

        let theWord = game.playerWords[playerNumber]
        sclAlertView.shouldDismissOnTapOutside = true
        sclAlertView.backgroundType = .Blur
        sclAlertView.labelTitle.font = UIFont(name: "Chalkboard SE", size: 20.0)
        sclAlertView.viewText.font = UIFont(name: "Chalkboard SE", size: 16.0)
        let appIcon = UIImage(named: "AppIcon60x60")
        sclAlertView.showCustom(self,
                                image: appIcon,
                                color: UIColor.blackColor(),
                                title: NSLocalizedString("Your secret word is", comment: "On the secret word screen"),
                                subTitle: theWord,
                                closeButtonTitle: NSLocalizedString("OK", comment: "Dismiss the popup"),
                                duration: 0.0)
        sclAlertView.alertIsDismissed {
            if self.playerNumber == self.game.numberOfPlayers - 1 {
                self.game.doneShowingSecretWords()
                var viewControllers: [AnyObject] = self.navigationController!.viewControllers
                self.navigationController!.popToViewController(viewControllers[1] as! UIViewController, animated: true)
                return
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let newController = storyboard.instantiateViewControllerWithIdentifier("secretWord") as! SecretWordViewController
            newController.playerNumber = self.playerNumber + 1
            self.navigationController!.pushViewController(newController, animated: true)
        }
    }
    
    @IBAction func stopGame(sender: AnyObject) {
        self.navigationController!.popToRootViewControllerAnimated(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        FIRAnalytics.logEventWithName(kFIREventViewItem, parameters: [
            kFIRParameterContentType:"view",
            kFIRParameterItemID:NSStringFromClass(self.dynamicType)
            ])
        
        self.playerLabel.text = String(format: NSLocalizedString("Player #%ld", comment: "Current player"), Int(self.playerNumber) + 1)
        
        let imageName = "\(Int(self.playerNumber))"
        if let photo = CachedPersistentJPEGImageStore.sharedStore.imageWithName(imageName) {
            self.playerImage.image = photo
            self.wantsToTakePhoto = false
        } else {
            self.playerImage.image = UIImage(named: "defaultHeadshot.png")!
            self.wantsToTakePhoto = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        guard self.wantsToTakePhoto && !self.photoDenied else {
            return
        }
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            self.imagePickerController = UIImagePickerController()
            self.imagePickerController.delegate = self
            self.imagePickerController.sourceType = .Camera
            self.imagePickerController.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.Camera) ?? []
            if UIImagePickerController.isCameraDeviceAvailable(.Front) {
                self.imagePickerController.cameraDevice = .Front
            }
            self.presentViewController(self.imagePickerController, animated: true, completion: { _ in })
        }
    }
    
}

extension SecretWordViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var photo = info[UIImagePickerControllerOriginalImage] as! UIImage
        photo = photo.normalizedImage().cropBiggestCenteredSquareImage(withSide: 800)
        let imageName: String = "\(Int(self.playerNumber))"
        CachedPersistentJPEGImageStore.sharedStore.saveImage(photo, withName: imageName)
        self.playerImage.image = photo
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.photoDenied = true
        picker.dismissViewControllerAnimated(true, completion: { _ in })
    }
}

private extension UIImage {
    func normalizedImage() -> UIImage {
        if (self.imageOrientation == UIImageOrientation.Up) {
            return self;
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self.drawInRect(rect)
        
        let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return normalizedImage;
    }
    
    func cropBiggestCenteredSquareImage(withSide side: CGFloat) -> UIImage {
        if self.size.height == side && self.size.width == side {
            return self
        }
        let newSize = CGSizeMake(side, side)
        let ratio: CGFloat
        let delta: CGFloat
        let offset: CGPoint
        if self.size.width > self.size.height {
            ratio = newSize.height / self.size.height
            delta = ratio * (self.size.width - self.size.height)
            offset = CGPointMake(delta / 2, 0)
        }
        else {
            ratio = newSize.width / self.size.width
            delta = ratio * (self.size.height - self.size.width)
            offset = CGPointMake(0, delta / 2)
        }
        let clipRect = CGRectMake(-offset.x, -offset.y, ratio * self.size.width, ratio * self.size.height)
        if UIScreen.mainScreen().respondsToSelector(#selector(NSDecimalNumberBehaviors.scale)) {
            UIGraphicsBeginImageContextWithOptions(newSize, true, 0.0)
        } else {
            UIGraphicsBeginImageContext(newSize);
        }
        UIRectClip(clipRect)
        self.drawInRect(clipRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}