//
//  SecretWordViewController.m
//  Imposter
//
//  Created by William Entriken on 12/14/13.
//  Copyright (c) 2013 William Entriken. All rights reserved.
//

#import "SecretWordViewController.h"
#import "ImposterGameModel.h"

@interface SecretWordViewController () <UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic) ImposterGameModel *game;
@property (nonatomic) UIAlertView *alertView;
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) UIPopoverController *imagePopoverController;
@property (nonatomic) BOOL wantsToTakePhoto;
@end

@implementation SecretWordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.game = [ImposterGameModel game];
}

- (IBAction)showSecretWord:(id)sender {
    NSString *theWord = [self.game.playerWords objectAtIndex:self.playerNumber];
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
    self.topSecretLabel.clipsToBounds = NO;
    
    self.playerLabel.text = [NSString stringWithFormat:@"Player #%d", self.playerNumber+1];
    UIImage *photo = [UIImage imageNamed:@"defaultHeadshot.gif"];
    self.playerImage.image = photo;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *targetPhotoPath = [basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"player%d.png",self.playerNumber]];
    photo = [UIImage imageWithContentsOfFile:targetPhotoPath];
    if (photo)
        self.playerImage.image = photo;
    self.wantsToTakePhoto = !photo;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.wantsToTakePhoto)
        return;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerController = [[UIImagePickerController alloc] init];
        self.imagePickerController.delegate = self;
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [[self presentingViewController] presentViewController:self.imagePickerController animated:YES completion:nil];
    } else {
        // THIS IS JUST FOR IPODS AND THE SIMULATOR
        self.imagePickerController = [[UIImagePickerController alloc] init];
        self.imagePickerController.delegate = self;
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        // On iPad use pop-overs.
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.imagePopoverController = [[UIPopoverController alloc] initWithContentViewController:self.imagePickerController];
            [self.imagePopoverController presentPopoverFromRect:self.topSecretLabel.frame
                                     inView:self.view
                   permittedArrowDirections:UIPopoverArrowDirectionAny
                                   animated:YES];
        }
        else {
            // On iPhone use full screen presentation.
            [[self presentingViewController] presentViewController:self.imagePickerController animated:YES completion:nil];
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (self.playerNumber == self.game.numberOfPlayers-1) {
        [self.navigationController popViewControllerAnimated:YES];
        [self.game doneShowingSecretWords];
        return;
    }
    
    UIStoryboard *storyboard;
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
//    } else {
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
//    }
    SecretWordViewController *newController = [storyboard instantiateViewControllerWithIdentifier:@"secretWord"];
    newController.playerNumber = self.playerNumber+1;
    
    // locally store the navigation controller since
    // self.navigationController will be nil once we are popped
    UINavigationController *navController = self.navigationController;
    
    // Pop this controller and replace with another
    [navController popViewControllerAnimated:NO];
    [navController pushViewController:newController animated:YES];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *photo = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.playerImage.image = photo;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *targetPhotoPath = [basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"player%d.png",self.playerNumber]];
    [UIImagePNGRepresentation(photo) writeToFile:targetPhotoPath atomically:YES];
}


@end
