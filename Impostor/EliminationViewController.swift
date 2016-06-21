//
//  EliminationViewController.swift
//  Impostor
//
//  Created by Full Decent on 6/20/16.
//  Copyright © 2016 William Entriken. All rights reserved.
//

import Foundation
import AudioToolbox
import SCLAlertView_Objective_C
import Firebase

class EliminationViewController: UIViewController {
    private let game = ImpostorGameModel.game
    private var sclAlertView: SCLAlertView? = nil
    private var eliminationSoundId: SystemSoundID = {
        let url = NSBundle.mainBundle().URLForResource("eliminate", withExtension: "mp3")!
        var soundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(url, &soundID)
        return soundID
    }()

    
    @IBOutlet weak var playerPhotoCollectionView: UICollectionView!
    
    @IBAction func eliminatePlayer(sender: UIButton) {
        let center = sender.center
        let rootViewPoint = sender.superview!.convertPoint(center, toView: self.playerPhotoCollectionView)
        let indexPath = playerPhotoCollectionView.indexPathForItemAtPoint(rootViewPoint)!
        guard !game.playerEliminated[indexPath.row] else {
            return
        }
        AudioServicesPlaySystemSound(eliminationSoundId)
        game.eliminatePlayer(indexPath.row)
        playerPhotoCollectionView.reloadData()
        switch game.gameStatus {
        case .TheImpostorRemains:
            let sclAlertView = SCLAlertView()
            sclAlertView.shouldDismissOnTapOutside = true
            sclAlertView.backgroundType = .Blur
            sclAlertView.labelTitle.font = UIFont(name: "Chalkboard SE", size: 20.0)
            sclAlertView.viewText.font = UIFont(name: "Chalkboard SE", size: 16.0)
            let appIcon = UIImage(named: "AppIcon60x60")!
            sclAlertView.showCustom(self,
                                    image: appIcon,
                                    color: UIColor.blackColor(),
                                    title: NSLocalizedString("The impostor remains", comment: "After someone was killed"),
                                    subTitle: String(format: NSLocalizedString("Player #%ld starts this round",
                                        comment: "After someone killed"), game.playerNumberToStartRound+1),
                                    closeButtonTitle: NSLocalizedString("OK", comment: "Dismiss the popup"),
                                    duration: 0.0)
            self.sclAlertView = sclAlertView
        case .TheImpostorWasDefeated:
            navigationController!.popViewControllerAnimated(true)
        case .TheImpostorWon:
            navigationController!.popViewControllerAnimated(true)
        default:
            return
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playerPhotoCollectionView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        FIRAnalytics.logEventWithName(kFIREventViewItem, parameters: [
            kFIRParameterContentType:"view",
            kFIRParameterItemID:NSStringFromClass(self.dynamicType)
            ])
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let sclAlertView = SCLAlertView()
        sclAlertView.shouldDismissOnTapOutside = true
        sclAlertView.backgroundType = .Blur
        sclAlertView.labelTitle.font = UIFont(name: "Chalkboard SE", size: 20.0)
        sclAlertView.viewText.font = UIFont(name: "Chalkboard SE", size: 16.0)
        let appIcon = UIImage(named: "AppIcon60x60")!
        sclAlertView.showCustom(self,
                                image: appIcon,
                                color: UIColor.blackColor(),
                                title: nil,
                                subTitle: String(format: NSLocalizedString("Player #%ld was randomly selected to start the first round", comment: "When the game starts"), game.playerNumberToStartRound+1),
                                closeButtonTitle: NSLocalizedString("OK", comment: "Dismiss the popup"),
                                duration: 0.0)
        self.sclAlertView = sclAlertView
        let root = navigationController!.viewControllers.first as! GameConfigurationViewController
        root.fadeOutMusic()
    }
    
}

extension EliminationViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return game.numberOfPlayers
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
}
