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
import SafariServices
import Firebase
import SwiftyStoreKit
import EAIntroView

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

    override public func viewDidLoad() {
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
        Analytics.logEvent(AnalyticsEventViewItem, parameters: [
            AnalyticsParameterItemCategory: "Screen",
            AnalyticsParameterItemID:NSStringFromClass(type(of: self))
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
            if #available(iOS 13.0, *) {
                buyButton.imageView!.image = UIImage(systemName: "checkmark.seal.fill")
            } else {
                // Fallback on earlier versions
            }
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
        Analytics.logEvent(AnalyticsEventTutorialBegin, parameters: [:])
        AudioServicesPlaySystemSound(self.buttonPress)
        
        let page1 = EAIntroPage()
        page1.title = NSLocalizedString("A party game", comment: "Intro screen 1 title")
        page1.desc = NSLocalizedString("For 3 to 12 players", comment: "Intro screen 1 detail")
        page1.titleIconView = UIImageView(image: UIImage(named: "help1"))
        page1.bgColor = UIColor.gray
        let page2 = EAIntroPage()
        page2.title = NSLocalizedString("Everyone sees their secret word", comment: "Intro screen 2 title")
        page2.desc = NSLocalizedString("But the impostor's word is different", comment: "Intro screen 2 detail")
        page2.titleIconView = UIImageView(image: UIImage(named: "help2"))
        page2.bgColor = UIColor.gray
        let page3 = EAIntroPage()
        page3.title = NSLocalizedString("Each round players describe their word", comment: "Intro screen 3 title")
        page3.desc = NSLocalizedString("then vote to eliminate one player (can't use word to describe itself or repeat other players, break ties with a revote)", comment: "Intro screen 3 detail")
        page3.titleIconView = UIImageView(image: UIImage(named: "help3"))
        page3.bgColor = UIColor.gray
        let page4 = EAIntroPage()
        page4.title = NSLocalizedString("To win", comment: "Intro screen 4 title")
        page4.desc = NSLocalizedString("the impostor must survive with one other player", comment: "Intro screen 4 detail")
        page4.titleIconView = UIImageView(image: UIImage(named: "help4"))
        page4.bgColor = UIColor.gray

        let introView = EAIntroView(frame: view.bounds, andPages: [page1, page2, page3, page4])
        introView?.show(in: self.view, animateDuration: 0.6)
    }
    
    @IBAction func clearPhotos(_ sender: UIButton) {
        Analytics.logEvent("action", parameters: [
            "viewController":NSStringFromClass(type(of: self)) as NSObject,
            "function":#function as NSObject
            ])
        AudioServicesPlaySystemSound(self.buttonPress)
        CachedPersistentJPEGImageStore.sharedStore.deleteAllImages()
        playerPhotoCollectionView.reloadData()
    }
    
    @IBAction func giveFeedback(_ sender: UIButton) {
        Analytics.logEvent("action", parameters: [
            "viewController": NSStringFromClass(type(of: self)) as NSObject,
            "function": #function as NSObject
            ])
        AudioServicesPlaySystemSound(self.buttonPress)
        let url = URL(string: "https://apps.phor.net/imposter-new-words/")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func buyUpgrade(_ sender: UIButton) {
        Analytics.logEvent("action", parameters: [
            "viewController": NSStringFromClass(type(of: self)) as NSObject,
            "function": #function as NSObject
            ])
        Analytics.logEvent(AnalyticsEventBeginCheckout, parameters: [
            AnalyticsParameterItemCategory: "In-App Purchase" as NSObject,
            AnalyticsParameterItemName: "Unlock words" as NSObject
            ])
        AudioServicesPlaySystemSound(self.buttonPress)
        
        SwiftyStoreKit.purchaseProduct("words0001", quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                Analytics.logEvent(AnalyticsEventEcommercePurchase, parameters: [
                    AnalyticsParameterCurrency: "USD",
                    AnalyticsParameterValue: 1
                    ])
                let defaults = UserDefaults.standard
                defaults.set(1, forKey: "didIAP")
                defaults.synchronize()
                
                let alert = UIAlertController(title: NSLocalizedString("Thank you for your purchase!", comment: "In-app purchase"), message: nil, preferredStyle: .alert)
                let action = UIAlertAction(title: NSLocalizedString("OK", comment: "Dismiss the popup"), style: .cancel)
                alert.addAction(action)
                self.present(alert, animated: true)
                print("Purchase Success: \(purchase.productId)")
            case .error(let error):
                Analytics.logEvent(AnalyticsEventEcommercePurchase, parameters: [
                    AnalyticsParameterCurrency: "USD",
                    AnalyticsParameterValue: 1
                    ])
                
                let alert = UIAlertController(title: NSLocalizedString("There was a problem with your purchase!", comment: "In-app purchase"), message: nil, preferredStyle: .alert)
                let action = UIAlertAction(title: NSLocalizedString("OK", comment: "Dismiss the popup"), style: .cancel)
                alert.addAction(action)
                self.present(alert, animated: true)
                
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                case .privacyAcknowledgementRequired: print("Privacy acknowledgement required")
                case .unauthorizedRequestData: print("Privacy acknowledgement required")
                case .invalidOfferIdentifier: print("Invalid offer identifier")
                case .invalidSignature: print("Invalid signature")
                case .missingOfferParams: print("Missing offer paramaters")
                case .invalidOfferPrice: print("Invalid offer price")
//                @unknown default:
//                    fatalError()
                }
            }
        }
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
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
            if self.audioPlayer.volume > 0.1 {
                self.audioPlayer.volume -= 0.1
            } else {
                // Stop and get the sound ready for playing again
                self.audioPlayer.stop()
                self.audioPlayer.currentTime = 0
                self.audioPlayer.prepareToPlay()
                self.audioPlayer.volume = 1.0
                timer.invalidate();
            }
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
        bounceAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        view.layer.add(bounceAnimation, forKey: "bounce")
    }
}

extension GameConfigurationViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
