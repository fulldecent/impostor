//
//  ResultsViewController.swift
//  Impostor
//
//  Created by Full Decent on 6/21/16.
//  Copyright © 2016 William Entriken. All rights reserved.
//

import AudioToolbox
import Firebase
import QBFlatButton
import SCLAlertView
import SwiftyiRate

class ResultsViewController: UIViewController {
    private let alertAppearance = SCLAlertView.SCLAppearance(
        kTitleFont: UIFont(name: "Chalkboard SE", size: 20.0)!,
        kTextFont: UIFont(name: "Chalkboard SE", size: 16.0)!,
        kButtonFont: UIFont(name: "Chalkboard SE", size: 16.0)!,
        hideWhenBackgroundViewIsTapped: true,
        showCircularIcon: true,
        contentViewColor: UIColor.blackColor(),
        showCloseButton: false
    )    
    
    private let game = ImpostorGameModel.game
    
    private var resultsSoundId: SystemSoundID = {
        let url = NSBundle.mainBundle().URLForResource("results", withExtension: "mp3")!
        var soundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(url, &soundID)
        return soundID
    }()

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var collage: QBFlatButton!
    
    @IBOutlet weak var shim: NSLayoutConstraint!
    
    @IBAction func playAgain(sender: AnyObject) {
        navigationController!.popToRootViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        FIRAnalytics.logEventWithName(kFIREventViewItem, parameters: [
            kFIRParameterContentType:"view",
            kFIRParameterItemID:NSStringFromClass(self.dynamicType)
            ])
        var allPhotos = true
        for i in 0 ..< self.game.numberOfPlayers {
            let imageName = "\(Int(i))"
            if CachedPersistentJPEGImageStore.sharedStore.imageWithName(imageName) == nil {
                allPhotos = false
            }
        }
        if allPhotos {
            self.collage.hidden = false
            self.shim.constant = 8
        } else {
            self.collage.hidden = true
            self.shim.constant = -self.collage.frame.size.height
        }
        FIRAnalytics.logEventWithName("gameStats", parameters: [
            kFIRParameterContentType: "All Photos",
            kFIRParameterValue: "\(allPhotos)"
            ])
        FIRAnalytics.logEventWithName("gameStats", parameters: [
            kFIRParameterContentType: "Number of Players",
            kFIRParameterValue: "\(game.numberOfPlayers)"
            ])
        FIRAnalytics.logEventWithName("gameStats", parameters: [
            kFIRParameterContentType: "Impostor Won",
            kFIRParameterValue: "\(game.gameStatus == .TheImpostorWon)"
            ])
        FIRAnalytics.logEventWithName("gameStats", parameters: [
            kFIRParameterContentType: "Words",
            kFIRParameterValue: "\(self.game.normalWord) - \(self.game.impostorWord)"
            ])
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        AudioServicesPlaySystemSound(resultsSoundId)
        let alertView = SCLAlertView(appearance: alertAppearance)
        alertView.addButton(NSLocalizedString("OK", comment: "Dismiss the popup"), action: {})
        let alertViewIcon = UIImage(named: "AppIcon60x60")
        switch game.gameStatus {
        case .TheImpostorWasDefeated:
            alertView.showInfo("",
                               subTitle: NSLocalizedString("The impostor was defeated", comment: "After the game is over"),
                               circleIconImage: alertViewIcon)
        case .TheImpostorWon:
            alertView.showInfo("",
                               subTitle: NSLocalizedString("The impostor won", comment: "After the game is over"),
                               circleIconImage: alertViewIcon)
        default:
            break
        }
      
        //TODO: upstream bug, this API should be public
        // SwiftyiRate.logEvent(deferPrompt: false)
    }
}

extension ResultsViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.game.numberOfPlayers
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("resultCell")!
        cell.textLabel!.text = String(format: NSLocalizedString("Player #%ld", comment: "Current player"), indexPath.row + 1)
        cell.detailTextLabel!.text = self.game.playerWords[indexPath.row]
        cell.imageView!.alpha = game.playerEliminated[indexPath.row] ? 0.4 : 1.0
        let imageName = "\(Int(indexPath.row))"
        if let photo = CachedPersistentJPEGImageStore.sharedStore.imageWithName(imageName) {
            cell.imageView!.image = photo
        } else {
            cell.imageView!.image = UIImage(named: "defaultHeadshot.png")!
        }
        return cell
    }
}

extension ResultsViewController: UITableViewDelegate {
    
}