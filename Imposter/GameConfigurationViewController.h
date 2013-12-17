//
//  ViewController.h
//  Imposter
//
//  Created by William Entriken on 12/14/13.
//  Copyright (c) 2013 William Entriken. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameConfigurationViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *numberOfPlayersLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *playerPhotoCollectionView;
- (IBAction)decrementPlayerCount:(id)sender;
- (IBAction)incrementPlayerCount:(id)sender;
- (IBAction)showInstructions:(id)sender;
- (IBAction)showGameOptions:(id)sender;
- (IBAction)startGame:(id)sender;
- (IBAction)fadeOutMusic;

@end
