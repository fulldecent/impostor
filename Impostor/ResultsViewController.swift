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
//import SwiftyiRate

class ResultsViewController: UIViewController {
    fileprivate let game = ImpostorGameModel.game
    
    fileprivate var resultsSoundId: SystemSoundID = {
        let url = Bundle.main.url(forResource: "results", withExtension: "mp3")!
        var soundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
        return soundID
    }()

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var collage: QBFlatButton!
    
    @IBOutlet weak var shim: NSLayoutConstraint!
    
    @IBAction func playAgain(_ sender: AnyObject) {
        navigationController!.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FIRAnalytics.logEvent(withName: kFIREventViewItem, parameters: [
            kFIRParameterContentType:"view" as NSObject,
            kFIRParameterItemID:NSStringFromClass(type(of: self)) as NSObject
            ])
        var allPhotos = true
        for i in 0 ..< self.game.numberOfPlayers {
            let imageName = "\(Int(i))"
            if CachedPersistentJPEGImageStore.sharedStore.imageWithName(imageName) == nil {
                allPhotos = false
            }
        }
        if allPhotos {
            self.collage.isHidden = false
            self.shim.constant = 8
        } else {
            self.collage.isHidden = true
            self.shim.constant = -self.collage.frame.size.height
        }
        FIRAnalytics.logEvent(withName: "gameStats", parameters: [
            kFIRParameterContentType: "All Photos" as NSObject,
            kFIRParameterValue: "\(allPhotos)" as NSObject
            ])
        FIRAnalytics.logEvent(withName: "gameStats", parameters: [
            kFIRParameterContentType: "Number of Players" as NSObject,
            kFIRParameterValue: "\(game.numberOfPlayers)" as NSObject
            ])
        FIRAnalytics.logEvent(withName: "gameStats", parameters: [
            kFIRParameterContentType: "Impostor Won" as NSObject,
            kFIRParameterValue: "\(game.gameStatus == .theImpostorWon)" as NSObject
            ])
        FIRAnalytics.logEvent(withName: "gameStats", parameters: [
            kFIRParameterContentType: "Words" as NSObject,
            kFIRParameterValue: "\(self.game.normalWord) - \(self.game.impostorWord)" as NSObject
            ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AudioServicesPlaySystemSound(resultsSoundId)
        let alertView = SCLAlertView(appearance: impostorAppearance)
        alertView.addButton(NSLocalizedString("OK", comment: "Dismiss the popup"), action: {})
        let alertViewIcon = UIImage(named: "AppIcon60x60")
        switch game.gameStatus {
        case .theImpostorWasDefeated:
            alertView.showInfo("",
                               subTitle: NSLocalizedString("The impostor was defeated", comment: "After the game is over"),
                               circleIconImage: alertViewIcon)
        case .theImpostorWon:
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.game.numberOfPlayers
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell")!
        cell.textLabel!.text = String(format: NSLocalizedString("Player #%ld", comment: "Current player"), (indexPath as NSIndexPath).row + 1)
        cell.detailTextLabel!.text = self.game.playerWords[(indexPath as NSIndexPath).row]
        cell.imageView!.alpha = game.playerEliminated[(indexPath as NSIndexPath).row] ? 0.4 : 1.0
        let imageName = "\(Int((indexPath as NSIndexPath).row))"
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
