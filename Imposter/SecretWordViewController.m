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

- (IBAction)showSecretWord:(id)sender {
    NSString *theWord = [self.game.playerWords objectAtIndex:self.playerNumber];
    self.alertView = [[UIAlertView alloc] initWithTitle:@"YOUR SECRET WORD IS" message:theWord delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [self.alertView show];
}

- (IBAction)stopGame:(id)sender {
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.topSecretLabel.transform = CGAffineTransformMakeRotation(-10 * M_PI / 180.0);

    self.playerLabel.text = [NSString stringWithFormat:@"Player #%d", self.playerNumber];
    UIImage *photo = [UIImage imageNamed:@"defaultHeadshot.gif"];
    [self.playerImage setImage:photo];
#warning ALSO US FDTAKE

}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
}

@end
