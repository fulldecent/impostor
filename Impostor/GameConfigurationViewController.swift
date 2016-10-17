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
import SafariServices

class GameConfigurationViewController: UIViewController {
    fileprivate var playerCount = 3
    fileprivate var game = ImpostorGameModel.game
    fileprivate var audioPlayer: AVAudioPlayer = {
        let url = Bundle.main.url(forResource: "intro", withExtension: "mp3")!
        return try! AVAudioPlayer(contentsOf: url)
    }()
    fileprivate var buttonPress: SystemSoundID = {
        let url = Bundle.main.url(forResource: "buttonPress", withExtension: "mp3")!
        var soundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
        return soundID
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        playerPhotoCollectionView.dataSource = self
        playerPhotoCollectionView.delegate = self
        
        let defaults = UserDefaults.standard
        let savedPlayerCount = defaults.integer(forKey: "playerCount")
        if savedPlayerCount != 0 {
            setPlayerCount(savedPlayerCount)
        } else {
            setPlayerCount(3)
        }
        (self.playerPhotoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).minimumInteritemSpacing = 10
        (self.playerPhotoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).minimumLineSpacing = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FIRAnalytics.logEvent(withName: kFIREventViewItem, parameters: [
            kFIRParameterContentType:"view" as NSObject,
            kFIRParameterItemID:NSStringFromClass(type(of: self)) as NSObject
            ])
        // https://stackoverflow.com/questions/3460694/uibutton-wont-go-to-aspect-fit-in-iphone/3995820#3995820
        for view in self.view.subviews {
            if let button = view as? UIButton {
                button.imageView!.contentMode = .scaleAspectFit
            }
        }
        let defaults = UserDefaults.standard
        let didIAP = defaults.integer(forKey: "didIAP")
        if didIAP != 0 {
            buyButton.imageView!.image = UIImage(named: "money-paid")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        audioPlayer.play()
        if !UserDefaults.standard.bool(forKey: "didShowInstructions") {
            showInstructions()
            UserDefaults.standard.set(true, forKey: "didShowInstructions")
            UserDefaults.standard.synchronize()
        }
    }

    @IBOutlet weak var numberOfPlayersLabel: UILabel!
    
    @IBOutlet weak var playerPhotoCollectionView: UICollectionView!
    
    @IBOutlet weak var buyButton: UIButton!
    
    @IBAction func decrementPlayerCount(_ sender: UIButton) {
        setPlayerCount(playerCount - 1)
        AudioServicesPlaySystemSound(self.buttonPress)
    }
    
    @IBAction func incrementPlayerCount(_ sender: AnyObject) {
        setPlayerCount(playerCount + 1)
        AudioServicesPlaySystemSound(self.buttonPress)
    }
    
    @IBAction func startGame(_ sender: UIButton) {
        let defaults = UserDefaults.standard
        defaults.set(self.playerCount, forKey: "playerCount")
        defaults.synchronize()
        game.startGameWithNumberOfPlayers(self.playerCount)
    }
    
    @IBAction func showInstructions() {
        FIRAnalytics.logEvent(withName: kFIREventViewItem, parameters: [
            kFIRParameterContentType:"view" as NSObject,
            kFIRParameterItemID:"Instructions" as NSObject
            ])
        AudioServicesPlaySystemSound(self.buttonPress)
        
        var introViewPages = [KxIntroViewPage]()
        introViewPages.append(KxIntroViewPage(
            title: NSLocalizedString("A party game", comment: "Intro screen 1 title"),
            withDetail: NSLocalizedString("For 3 to 12 players", comment: "Intro screen 1 detail"),
            with: UIImage(named: "help1")))
        introViewPages.append(KxIntroViewPage(
            title: NSLocalizedString("Everyone sees their secret word", comment: "Intro screen 2 title"),
            withDetail: NSLocalizedString("But the impostor's word is different", comment: "Intro screen 2 detail"),
            with: UIImage(named: "help2")))
        introViewPages.append(KxIntroViewPage(
            title: NSLocalizedString("Each round players describe their word", comment: "Intro screen 3 title"),
            withDetail: NSLocalizedString("then vote to eliminate one player (can't use word to describe itself or repeat other players, break ties with a revote)", comment: "Intro screen 3 detail"),
            with: UIImage(named: "help3")))
        introViewPages.append(KxIntroViewPage(
            title: NSLocalizedString("To win", comment: "Intro screen 4 title"),
            withDetail: NSLocalizedString("the impostor must survive with one other player", comment: "Intro screen 4 detail"),
            with: UIImage(named: "help4")))
        let introView = KxIntroViewController(pages: introViewPages)
        introView?.present(in: self, fullScreenLayout: true)
    }
    
    @IBAction func clearPhotos(_ sender: UIButton) {
        FIRAnalytics.logEvent(withName: "action", parameters: [
            "viewController":NSStringFromClass(type(of: self)) as NSObject,
            "function":#function as NSObject
            ])
        AudioServicesPlaySystemSound(self.buttonPress)
        CachedPersistentJPEGImageStore.sharedStore.deleteAllImages()
        playerPhotoCollectionView.reloadData()
    }
    
    @IBAction func seeWeixin(_ sender: UIButton) {
        FIRAnalytics.logEvent(withName: "action", parameters: [
            "viewController":NSStringFromClass(type(of: self)) as NSObject,
            "function":#function as NSObject
            ])
        AudioServicesPlaySystemSound(self.buttonPress)
        let wxUrl = URL(string: "weixin://contacts/profile/fulldecent")!
        let backupUrl = URL(string: "http://user.qzone.qq.com/858772059")!
        if UIApplication.shared.canOpenURL(wxUrl) {
            UIApplication.shared.openURL(wxUrl)
        } else {
            if #available(iOS 9.0, *) {
                let svc = SFSafariViewController(url: backupUrl, entersReaderIfAvailable: true)
                svc.delegate = self
                self.present(svc, animated: true, completion: nil)
            } else {
                UIApplication.shared.openURL(backupUrl)
            }
        }
    }
    
    @IBAction func giveFeedback(_ sender: UIButton) {
        FIRAnalytics.logEvent(withName: "action", parameters: [
            "viewController": NSStringFromClass(type(of: self)) as NSObject,
            "function": #function as NSObject
            ])
        AudioServicesPlaySystemSound(self.buttonPress)
        let url = URL(string: "http://phor.net/apps/impostor/newWords.php")!
        UIApplication.shared.openURL(url)
    }
    
    @IBAction func buyUpgrade(_ sender: UIButton) {
        FIRAnalytics.logEvent(withName: "action", parameters: [
            "viewController": NSStringFromClass(type(of: self)) as NSObject,
            "function": #function as NSObject
            ])
        FIRAnalytics.logEvent(withName: kFIREventBeginCheckout, parameters: [
            kFIRParameterItemCategory: "In-App Purchase" as NSObject,
            kFIRParameterItemName: "Unlock words" as NSObject
            ])
        AudioServicesPlaySystemSound(self.buttonPress)
        
        // Check if they already have it
        if UserDefaults.standard.integer(forKey: "didIAP") != 0 {
            FIRAnalytics.logEvent(withName: "action", parameters: [
                "viewController": NSStringFromClass(type(of: self)) as NSObject,
                "function": #function as NSObject,
                "extra": "Already had IAP" as NSObject
                ])
            let alert = UIAlertView(title: NSLocalizedString("Your previous purchase was restored", comment: "In-app purchase"), message: nil, delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: "Dismiss the popup"))
            alert.show()
            return
        }
        
        // Try to unlock past sale
        RMStore.default().restoreTransactions(onSuccess: {
            transactions in
            if (transactions?.count)! > 0 {
                FIRAnalytics.logEvent(withName: "action", parameters: [
                    "viewController": NSStringFromClass(type(of: self)) as NSObject,
                    "function": #function as NSObject,
                    "extra": "Restored IAP" as NSObject
                    ])
                let defaults = UserDefaults.standard
                defaults.set(1, forKey: "didIAP")
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
        RMStore.default().requestProducts(products, success: {
            products, invalidProductIdentifiers in
            NSLog("Products loaded")
            RMStore.default().addPayment("words0001", success: {
                transaction in
                FIRAnalytics.logEvent(withName: "action", parameters: [
                    "viewController": NSStringFromClass(type(of: self)) as NSObject,
                    "function": #function as NSObject,
                    "extra": "Successful IAP" as NSObject
                    ])
                let defaults = UserDefaults.standard
                defaults.set(1, forKey: "didIAP")
                defaults.synchronize()
                let alert = UIAlertView(title: NSLocalizedString("Thank you for your purchase!", comment: "In-app purchase"), message: nil, delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: "Dismiss the popup"))
                alert.show()
            }, failure: {
                transaction, error in
                FIRAnalytics.logEvent(withName: "action", parameters: [
                    "viewController": NSStringFromClass(type(of: self)) as NSObject,
                    "function": #function as NSObject,
                    "extra": "Error with IAP" as NSObject
                    ])
                let alert = UIAlertView(title: NSLocalizedString("There was a problem with your purchase!", comment: "In-app purchase"), message: nil, delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: "Dismiss the popup"))
                alert.show()
            })
        }, failure: {
            error in
            FIRAnalytics.logEvent(withName: "action", parameters: [
                "viewController": NSStringFromClass(type(of: self)) as NSObject,
                "function": #function as NSObject,
                "extra": "Error with IAP, requesting products" as NSObject
                ])
            NSLog("Something went wrong")
            let alert = UIAlertView(title: NSLocalizedString("There was a problem with your purchase!", comment: "In-app purchase"), message: nil, delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: "Dismiss the popup"))
            alert.show()
        })
    }
    
    func setPlayerCount(_ count: Int) {
        if count < 3 {
            playerCount = 3
        } else if count > 12 {
            playerCount = 12
        } else {
            playerCount = count
        }
        
        numberOfPlayersLabel.text = String(format: NSLocalizedString("%ld players", comment:"Number of players in the game"), self.playerCount)
        
        while playerPhotoCollectionView.numberOfItems(inSection: 0) < playerCount {
            let nextItem = playerPhotoCollectionView.numberOfItems(inSection: 0)
            playerPhotoCollectionView.insertItems(at: [IndexPath(item: nextItem, section: 0)])
        }
        while playerPhotoCollectionView.numberOfItems(inSection: 0) > playerCount {
            let lastItem = playerPhotoCollectionView.numberOfItems(inSection: 0) - 1
            playerPhotoCollectionView.deleteItems(at: [IndexPath(item: lastItem, section: 0)])
        }
        view!.setNeedsLayout()
    }

    func fadeOutMusic() {
        // http://stackoverflow.com/questions/1216581/avaudioplayer-fade-volume-out
        if self.audioPlayer.volume > 0.1 {
            self.audioPlayer.volume -= 0.1
            self.perform(#selector(GameConfigurationViewController.fadeOutMusic), with: nil, afterDelay: 0.1)
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
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playerCount
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        view.setNeedsLayout()
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
        let size = CGSize(width: CGFloat(highestWorking), height: CGFloat(highestWorking))
        (self.playerPhotoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = size
        super.viewDidLayoutSubviews()
    }
}

extension GameConfigurationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.makeItBounce(cell)
    }
    
    func makeItBounce(_ view: UIView) {
        let bounceAnimation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0, 1.2]
        bounceAnimation.duration = 0.15
        bounceAnimation.isRemovedOnCompletion = false
        bounceAnimation.repeatCount = 2
        bounceAnimation.autoreverses = true
        bounceAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        view.layer.add(bounceAnimation, forKey: "bounce")
    }
}

@available(iOS 9.0, *)
extension GameConfigurationViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController)
    {
        controller.dismiss(animated: true, completion: nil)
    }
}
