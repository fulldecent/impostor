//
//  SecretWordViewController.m
//  Imposter
//
//  Created by William Entriken on 12/14/13.
//  Copyright (c) 2013 William Entriken. All rights reserved.
//

#import "SecretWordViewController.h"
#import "ImposterGameModel.h"

@interface SecretWordViewController () <UIAlertViewDelegate>
@property (nonatomic) ImposterGameModel *game;
@property (nonatomic) UIAlertView *alertView;
@end

@implementation SecretWordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.game = [ImposterGameModel game];
}

- (IBAction)showSecretWord:(id)sender {
    NSString *theWord = [self.game.playerWords objectAtIndex:self.playerNumber-1];
    self.alertView = [[UIAlertView alloc] initWithTitle:@"YOUR SECRET WORD IS" message:theWord delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [self.alertView show];
}

- (IBAction)stopGame:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.topSecretLabel.transform = CGAffineTransformMakeRotation(-10 * M_PI / 180.0);

    self.playerLabel.text = [NSString stringWithFormat:@"Player #%d", self.playerNumber];
    UIImage *photo = [UIImage imageNamed:@"defaultHeadshot.gif"];
    [self.playerImage setImage:photo];
#warning ALSO USE FDTAKE
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (self.playerNumber == self.game.numberOfPlayers) {
        [self.navigationController popViewControllerAnimated:YES];
        [self.game doneShowingSecretWords];
        return;
    }
    
    UIStoryboard *storyboard;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    } else {
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    }
    SecretWordViewController *newController = [storyboard instantiateViewControllerWithIdentifier:@"secretWord"];
    newController.playerNumber = self.playerNumber+1;
    
    // locally store the navigation controller since
    // self.navigationController will be nil once we are popped
    UINavigationController *navController = self.navigationController;
    
    // Pop this controller and replace with another
    [navController popViewControllerAnimated:NO];
    [navController pushViewController:newController animated:YES];
}

@end
