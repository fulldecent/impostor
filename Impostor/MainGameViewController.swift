//
//  MainGameViewController.swift
//  Impostor
//
//  Created by William Entriken on 4/24/16.
//  Copyright © 2016 William Entriken. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class MainGameViewController: UIViewController {
    override func viewDidAppear(animated: Bool) {        
        super.viewDidAppear(animated)
        switch ImpostorGameModel.game.gameStatus {
        case .ShowSecretWords:
            self.performSegueWithIdentifier("secretWord", sender: self)
        case .TheImpostorRemains:
            self.performSegueWithIdentifier("elimination", sender: self)
        case .TheImpostorWasDefeated, .TheImpostorWon:
            self.performSegueWithIdentifier("results", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let secretWordViewController = segue.destinationViewController as? SecretWordViewController {
            secretWordViewController.playerNumber = 0
        }
    }
}
