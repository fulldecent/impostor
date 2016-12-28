//
//  EliminationViewController.swift
//  Impostor
//
//  Created by Full Decent on 6/20/16.
//  Copyright © 2016 William Entriken. All rights reserved.
//

import Foundation
import AudioToolbox
import CDAlertView
import Firebase

class EliminationViewController: UIViewController {
    fileprivate let game = ImpostorGameModel.game
    fileprivate var accentSoundId: SystemSoundID = {
        let url = Bundle.main.url(forResource: "eliminate", withExtension: "mp3")!
        var soundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
        return soundID
    }()

    @IBOutlet weak var playerPhotoCollectionView: UICollectionView!
    
    @IBAction func eliminatePlayer(_ sender: UIButton) {
        let center = sender.center
        let rootViewPoint = sender.superview!.convert(center, to: self.playerPhotoCollectionView)
        let indexPath = playerPhotoCollectionView.indexPathForItem(at: rootViewPoint)!
        guard !game.playerEliminated[(indexPath as NSIndexPath).row] else {
            return
        }
        AudioServicesPlaySystemSound(accentSoundId)
        game.eliminatePlayer((indexPath as NSIndexPath).row)
        playerPhotoCollectionView.reloadData()
        
        switch game.gameStatus {
        case .theImpostorRemains:
            let title = NSLocalizedString("The impostor remains", comment: "After someone was killed")
            let message = String(format: NSLocalizedString("Player #%ld starts this round",
                                                           comment: "After someone killed"))
            let alertView = CDAlertView(title: title,
                                        message: message,
                                        type: .custom(image: UIImage(named:"AppIcon60x60")!))
            alertView.alertBackgroundColor = UIColor.black
            alertView.titleTextColor = UIColor.white
            alertView.messageTextColor = UIColor.white
            alertView.titleFont = UIFont(name: "AmericanTypewriter", size: 20.0)!
            alertView.messageFont = UIFont(name: "AmericanTypewriter-Bold", size: 20.0)!
            
            let action = CDAlertViewAction(title: NSLocalizedString("OK", comment: "Dismiss the popup"))
            alertView.add(action: action)
            alertView.show()
        case .theImpostorWasDefeated:
            navigationController!.popViewController(animated: true)
        case .theImpostorWon:
            navigationController!.popViewController(animated: true)
        default:
            return
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playerPhotoCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FIRAnalytics.logEvent(withName: kFIREventViewItem, parameters: [
            kFIRParameterContentType:"view" as NSObject,
            kFIRParameterItemID:NSStringFromClass(type(of: self)) as NSObject
            ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let title: String? = nil
        let message = String(format: NSLocalizedString("Player #%ld was randomly selected to start the first round",
                                                       comment: "When the game starts"), game.playerNumberToStartRound+1)
        let alertView = CDAlertView(title: title,
                                    message: message,
                                    type: .custom(image: UIImage(named:"AppIcon60x60")!))
        alertView.alertBackgroundColor = UIColor.black
        alertView.titleTextColor = UIColor.white
        alertView.messageTextColor = UIColor.white
        alertView.titleFont = UIFont(name: "AmericanTypewriter", size: 20.0)!
        alertView.messageFont = UIFont(name: "AmericanTypewriter-Bold", size: 20.0)!
        
        let action = CDAlertViewAction(title: NSLocalizedString("OK", comment: "Dismiss the popup"))
        alertView.add(action: action)
        alertView.show()
        let root = navigationController!.viewControllers.first as! GameConfigurationViewController
        root.fadeOutMusic()
    }
    
}

extension EliminationViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return game.numberOfPlayers
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
}
