//
//  GameConfigurationViewController.swift
//  Impostor
//
//  Created by Full Decent on 6/20/16.
//  Copyright © 2016 William Entriken. All rights reserved.
//

import Foundation
import AVFoundation
import AudioToolbox
import MessageUI
import FirebaseAnalytics
import RMStore

class GameConfigurationViewController: UIViewController {
    private var playerCount = 3
    private var game = ImpostorGameModel.game
    private var audioPlayer: AVAudioPlayer = {
        let url = NSBundle.mainBundle().URLForResource("intro", withExtension: "mp3")!
        return try! AVAudioPlayer(contentsOfURL: url)
    }()
    private var buttonPress: SystemSoundID = {
        let url = NSBundle.mainBundle().URLForResource("buttonPress", withExtension: "mp3")!
        var soundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(url, &soundID)
        return soundID
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        playerPhotoCollectionView.dataSource = self
        playerPhotoCollectionView.delegate = self
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let savedPlayerCount = defaults.integerForKey("playerCount")
        if savedPlayerCount != 0 {
            setPlayerCount(savedPlayerCount)
        } else {
            setPlayerCount(3)
        }
        (self.playerPhotoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).minimumInteritemSpacing = 10
        (self.playerPhotoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).minimumLineSpacing = 10
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        FIRAnalytics.logEventWithName(kFIREventViewItem, parameters: [
            kFIRParameterContentType:"view",
            kFIRParameterItemID:NSStringFromClass(self.dynamicType)
            ])
        // https://stackoverflow.com/questions/3460694/uibutton-wont-go-to-aspect-fit-in-iphone/3995820#3995820
        for view in self.view.subviews {
            if let button = view as? UIButton {
                button.imageView!.contentMode = .ScaleAspectFit
            }
        }
        let defaults = NSUserDefaults.standardUserDefaults()
        let didIAP = defaults.integerForKey("didIAP")
        if didIAP != 0 {
            buyButton.imageView!.image = UIImage(named: "money-paid")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        audioPlayer.play()
        if !NSUserDefaults.standardUserDefaults().boolForKey("didShowInstructions") {
            showInstructions()
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "didShowInstructions")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

    @IBOutlet weak var numberOfPlayersLabel: UILabel!
    
    @IBOutlet weak var playerPhotoCollectionView: UICollectionView!
    
    @IBOutlet weak var buyButton: UIButton!
    
    @IBAction func decrementPlayerCount(sender: UIButton) {
        setPlayerCount(playerCount - 1)
        AudioServicesPlaySystemSound(self.buttonPress)
    }
    
    @IBAction func incrementPlayerCount(sender: AnyObject) {
        setPlayerCount(playerCount + 1)
        AudioServicesPlaySystemSound(self.buttonPress)
    }
    
    @IBAction func startGame(sender: UIButton) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(self.playerCount, forKey: "playerCount")
        defaults.synchronize()
        game.startGameWithNumberOfPlayers(self.playerCount)
    }
    
    @IBAction func showInstructions() {
        FIRAnalytics.logEventWithName(kFIREventViewItem, parameters: [
            kFIRParameterContentType:"view",
            kFIRParameterItemID:"Instructions"
            ])
        AudioServicesPlaySystemSound(self.buttonPress)
        
        var introViewPages = [KxIntroViewPage]()
        introViewPages.append(KxIntroViewPage(
            title: NSLocalizedString("A party game", comment: "Intro screen 1 title"),
            withDetail: NSLocalizedString("For 3 to 12 players", comment: "Intro screen 1 detail"),
            withImage: UIImage(named: "help1")))
        introViewPages.append(KxIntroViewPage(
            title: NSLocalizedString("Everyone sees their secret word", comment: "Intro screen 2 title"),
            withDetail: NSLocalizedString("But the impostor's word is different", comment: "Intro screen 2 detail"),
            withImage: UIImage(named: "help2")))
        introViewPages.append(KxIntroViewPage(
            title: NSLocalizedString("Each round players describe their word", comment: "Intro screen 3 title"),
            withDetail: NSLocalizedString("then vote to eliminate one player (can't use word to describe itself or repeat other players, break ties with a revote)", comment: "Intro screen 3 detail"),
            withImage: UIImage(named: "help3")))
        introViewPages.append(KxIntroViewPage(
            title: NSLocalizedString("To win", comment: "Intro screen 4 title"),
            withDetail: NSLocalizedString("the impostor must survive with one other player", comment: "Intro screen 4 detail"),
            withImage: UIImage(named: "help4")))
        let introView = KxIntroViewController(pages: introViewPages)
        introView.presentInViewController(self, fullScreenLayout: true)
    }
    
    @IBAction func clearPhotos(sender: UIButton) {
        FIRAnalytics.logEventWithName("action", parameters: [
            "viewController":NSStringFromClass(self.dynamicType),
            "function":#function
            ])
        AudioServicesPlaySystemSound(self.buttonPress)
        CachedPersistentJPEGImageStore.sharedStore.deleteAllImages()
        playerPhotoCollectionView.reloadData()
    }
    
    @IBAction func seeWeixin(sender: UIButton) {
        FIRAnalytics.logEventWithName("action", parameters: [
            "viewController":NSStringFromClass(self.dynamicType),
            "function":#function
            ])
        AudioServicesPlaySystemSound(self.buttonPress)
        let wxUrl = NSURL(string: "weixin://contacts/profile/fulldecent")!
        let backupUrl = NSURL(string: "http://user.qzone.qq.com/858772059")!
        if UIApplication.sharedApplication().canOpenURL(wxUrl) {
            UIApplication.sharedApplication().openURL(wxUrl)
        } else {
            UIApplication.sharedApplication().openURL(backupUrl)
        }
    }
    
    @IBAction func giveFeedback(sender: UIButton) {
        FIRAnalytics.logEventWithName("action", parameters: [
            "viewController": NSStringFromClass(self.dynamicType),
            "function": #function
            ])
        AudioServicesPlaySystemSound(self.buttonPress)
        let url = NSURL(string: "http://phor.net/apps/impostor/newWords.php")!
        UIApplication.sharedApplication().openURL(url)
    }
    
    @IBAction func buyUpgrade(sender: UIButton) {
        FIRAnalytics.logEventWithName("action", parameters: [
            "viewController": NSStringFromClass(self.dynamicType),
            "function": #function
            ])
        FIRAnalytics.logEventWithName(kFIREventBeginCheckout, parameters: [
            kFIRParameterItemCategory: "In-App Purchase",
            kFIRParameterItemName: "Unlock words"
            ])
        AudioServicesPlaySystemSound(self.buttonPress)
        let url = NSURL(string: "http://phor.net/apps/impostor/newWords.php")!
        UIApplication.sharedApplication().openURL(url)
        
        // Check if they already have it
        if NSUserDefaults.standardUserDefaults().integerForKey("didIAP") != 0 {
            FIRAnalytics.logEventWithName("action", parameters: [
                "viewController": NSStringFromClass(self.dynamicType),
                "function": #function,
                "extra": "Already had IAP"
                ])
            let alert = UIAlertView(title: NSLocalizedString("Your previous purchase was restored", comment: "In-app purchase"), message: nil, delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: "Dismiss the popup"))
            alert.show()
            return
        }
        
        // Try to unlock past sale
        RMStore.defaultStore().restoreTransactionsOnSuccess({
            transactions in
            if transactions.count > 0 {
                FIRAnalytics.logEventWithName("action", parameters: [
                    "viewController": NSStringFromClass(self.dynamicType),
                    "function": #function,
                    "extra": "Restored IAP"
                    ])
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setInteger(1, forKey: "didIAP")
                defaults.synchronize()
                let alert = UIAlertView(title: NSLocalizedString("Your previous purchase was restored", comment: "In-app purchase"), message: nil, delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: "Dismiss the popup"))
                alert.show()
            }
            return
        }, failure: {
                error in
        })
        
        // Try to make new sale
        let products = Set<String>(["words0001"])
        RMStore.defaultStore().requestProducts(products, success: {
            products, invalidProductIdentifiers in
            NSLog("Products loaded")
            RMStore.defaultStore().addPayment("words0001", success: {
                transaction in
                FIRAnalytics.logEventWithName("action", parameters: [
                    "viewController": NSStringFromClass(self.dynamicType),
                    "function": #function,
                    "extra": "Successful IAP"
                    ])
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setInteger(1, forKey: "didIAP")
                defaults.synchronize()
                let alert = UIAlertView(title: NSLocalizedString("Thank you for your purchase!", comment: "In-app purchase"), message: nil, delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: "Dismiss the popup"))
                alert.show()
            }, failure: {
                transaction, error in
                FIRAnalytics.logEventWithName("action", parameters: [
                    "viewController": NSStringFromClass(self.dynamicType),
                    "function": #function,
                    "extra": "Error with IAP"
                    ])
                let alert = UIAlertView(title: NSLocalizedString("There was a problem with your purchase!", comment: "In-app purchase"), message: nil, delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: "Dismiss the popup"))
                alert.show()
            })
        }, failure: {
            error in
            FIRAnalytics.logEventWithName("action", parameters: [
                "viewController": NSStringFromClass(self.dynamicType),
                "function": #function,
                "extra": "Error with IAP, requesting products"
                ])
            NSLog("Something went wrong")
            let alert = UIAlertView(title: NSLocalizedString("There was a problem with your purchase!", comment: "In-app purchase"), message: nil, delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: "Dismiss the popup"))
            alert.show()
        })
    }
    
    func setPlayerCount(count: Int) {
        if count < 3 {
            playerCount = 3
        } else if count > 12 {
            playerCount = 12
        } else {
            playerCount = count
        }
        
        numberOfPlayersLabel.text = String(format: NSLocalizedString("%ld players", comment:"Number of players in the game"), self.playerCount)
        
        while playerPhotoCollectionView.numberOfItemsInSection(0) < playerCount {
            let nextItem = playerPhotoCollectionView.numberOfItemsInSection(0)
            playerPhotoCollectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: nextItem, inSection: 0)])
        }
        while playerPhotoCollectionView.numberOfItemsInSection(0) > playerCount {
            let lastItem = playerPhotoCollectionView.numberOfItemsInSection(0) - 1
            playerPhotoCollectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: lastItem, inSection: 0)])
        }
        view!.setNeedsLayout()
    }

    func fadeOutMusic() {
        // http://stackoverflow.com/questions/1216581/avaudioplayer-fade-volume-out
        if self.audioPlayer.volume > 0.1 {
            self.audioPlayer.volume -= 0.1
            self.performSelector(#selector(GameConfigurationViewController.fadeOutMusic), withObject: nil, afterDelay: 0.1)
        }
        else {
            // Stop and get the sound ready for playing again
            self.audioPlayer.stop()
            self.audioPlayer.currentTime = 0
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.volume = 1.0
        }
    }
}

extension GameConfigurationViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playerCount
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        view.setNeedsLayout()
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
        return cell
    }
    
    // Make the cells fit
    // http://stackoverflow.com/a/20596880/300224
    override func viewDidLayoutSubviews() {
        var highestWorking = 0
        var lowestNotWorking = 9999
        while lowestNotWorking > highestWorking + 1 {
            let currentTest = (highestWorking + lowestNotWorking) / 2
            let cols = Int(playerPhotoCollectionView.frame.size.width + 10) / (currentTest + 10)
            let rows = Int(playerPhotoCollectionView.frame.size.height + 10) / (currentTest + 10)
            if cols * rows >= self.playerCount {
                highestWorking = currentTest
            } else {
                lowestNotWorking = currentTest
            }
        }
        let size = CGSizeMake(CGFloat(highestWorking), CGFloat(highestWorking))
        (self.playerPhotoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = size
        super.viewDidLayoutSubviews()
    }
}

extension GameConfigurationViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        self.makeItBounce(cell)
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
