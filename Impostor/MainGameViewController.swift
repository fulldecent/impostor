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
    override func viewDidAppear(_ animated: Bool) {        
        super.viewDidAppear(animated)
        switch ImpostorGameModel.game.gameStatus {
        case .showSecretWords:
            self.performSegue(withIdentifier: "secretWord", sender: self)
        case .theImpostorRemains:
            self.performSegue(withIdentifier: "elimination", sender: self)
        case .theImpostorWasDefeated, .theImpostorWon:
            self.performSegue(withIdentifier: "results", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let secretWordViewController = segue.destination as? SecretWordViewController {
            secretWordViewController.playerNumber = 0
        }
    }
}
