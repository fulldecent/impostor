//
//  MainGameViewController.m
//  Imposter
//
//  Created by William Entriken on 12/14/13.
//  Copyright (c) 2013 William Entriken. All rights reserved.
//

#import "MainGameViewController.h"
#import "ImposterGameModel.h"
#import "SecretWordViewController.h"

@interface MainGameViewController ()
@property ImposterGameModel *game;
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
    switch ([[ImposterGameModel game] gameStatus]) {
        case GameStatusNewGame:
            [self performSegueWithIdentifier:@"secretWord" sender:self];
            break;
        case GameStatusTheImposterRemains:
            [self performSegueWithIdentifier:@"elimination" sender:self];
            break;
        case GameStatusTheImposterWasDefeated:
        case GameStatusTheImposterWon:
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
