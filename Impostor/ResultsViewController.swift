//
//  ResultsViewController.swift
//  Impostor
//
//  Created by Full Decent on 6/21/16.
//  Copyright © 2016 William Entriken. All rights reserved.
//

import UIKit
import AudioToolbox
import NKButton
import CDAlertView

class ResultsViewController: UIViewController {
    fileprivate let game = ImpostorGameModel.game
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var collage: NKButton!
    
    @IBOutlet weak var shim: NSLayoutConstraint!
    
    @IBAction func playAgain(_ sender: AnyObject) {
        navigationController!.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let message: String
        let url: URL
        
        switch game.gameStatus {
        case .theImpostorWasDefeated:
            message = NSLocalizedString("The impostor was defeated", comment: "After the game is over")
            url = Bundle.main.url(forResource: "results", withExtension: "mp3")!
        case .theImpostorWon:
            message = NSLocalizedString("The impostor won", comment: "After the game is over")
            url = Bundle.main.url(forResource: "results-impostor-won", withExtension: "mp3")!
        default:
            return
        }
        
        var soundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
        AudioServicesPlaySystemSound(soundID)
        
        let alertView = CDAlertView(title: nil,
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
        cell.textLabel!.text = game.playerWords[(indexPath as NSIndexPath).row]
        cell.imageView!.alpha = game.playerEliminated[(indexPath as NSIndexPath).row] ? 0.4 : 1.0
        let imageName = "\(indexPath.row)"
        if let photo = CachedPersistentJPEGImageStore.sharedStore.imageWithName(imageName) {
            cell.imageView!.image = photo
        } else {
            cell.imageView!.image = UIImage(named: "defaultHeadshot.png")!
        }
        return cell
    }
}
