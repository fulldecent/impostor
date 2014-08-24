//
//  MainGameViewController.m
//  Impostor
//
//  Created by William Entriken on 12/14/13.
//  Copyright (c) 2013 William Entriken. All rights reserved.
//

#import "MainGameViewController.h"
#import "ImpostorGameModel.h"
#import "SecretWordViewController.h"

@interface MainGameViewController ()
@property ImpostorGameModel *game;
@end

@implementation MainGameViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    switch ([[ImpostorGameModel game] gameStatus]) {
        case GameStatusNewGame:
            [self performSegueWithIdentifier:@"secretWord" sender:self];
            break;
        case GameStatusTheImpostorRemains:
            [self performSegueWithIdentifier:@"elimination" sender:self];
            break;
        case GameStatusTheImpostorWasDefeated:
        case GameStatusTheImpostorWon:
            [self performSegueWithIdentifier:@"results" sender:self];
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SecretWordViewController class]]) {
        SecretWordViewController *controller = (SecretWordViewController *)segue.destinationViewController;
        controller.playerNumber = 0;
    }
}


@end
