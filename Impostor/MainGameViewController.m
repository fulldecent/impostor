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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    self.screenName = @"MainGameViewController";

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
