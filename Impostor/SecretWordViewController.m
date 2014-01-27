//
//  SecretWordViewController.m
//  Impostor
//
//  Created by William Entriken on 12/14/13.
//  Copyright (c) 2013 William Entriken. All rights reserved.
//

#import "SecretWordViewController.h"
#import "ImpostorGameModel.h"
#import <AudioToolbox/AudioToolbox.h>

@interface SecretWordViewController () <UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic) ImpostorGameModel *game;
@property (nonatomic) UIAlertView *alertView;
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) UIPopoverController *imagePopoverController;
@property (nonatomic) BOOL wantsToTakePhoto;
@property (nonatomic) BOOL photoDenied;
@end

@implementation SecretWordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.game = [ImpostorGameModel game];
    self.topSecretLabel.transform = CGAffineTransformMakeRotation(-10 * M_PI / 180.0);
    self.topSecretLabel.clipsToBounds = NO;
}

- (IBAction)showSecretWord:(id)sender {
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"peek" ofType:@"mp3"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    AudioServicesPlaySystemSound (soundID);
    NSString *theWord = [self.game.playerWords objectAtIndex:self.playerNumber];
    self.alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Your secret word is", @"On the secret word screen") message:theWord delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [self.alertView show];
}

- (IBAction)stopGame:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.playerLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Player #%ld", @"Current player"), (long)self.playerNumber+1];
    UIImage *photo = [UIImage imageNamed:@"defaultHeadshot.png"];
    self.playerImage.image = photo;

    photo = [self.game.playerPhotos objectForKey:[NSNumber numberWithInteger:self.playerNumber]];
    if (photo)  
        self.playerImage.image = photo;
    self.wantsToTakePhoto = !photo;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.screenName = @"SecretWordViewController";
    
    if (!self.wantsToTakePhoto || self.photoDenied)
        return;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerController = [[UIImagePickerController alloc] init];
        self.imagePickerController.delegate = self;
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:
                                                 UIImagePickerControllerSourceTypeCamera];
        if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])
            self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            
//        [[self presentingViewController] presentViewController:self.imagePickerController animated:YES completion:nil];
        [self presentViewController:self.imagePickerController animated:YES completion:nil];

    }
/*
    else {
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
*/
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
    // http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload/5427890#5427890
    UIImage *normalizedImage;
    if (photo.imageOrientation == UIImageOrientationUp)
        normalizedImage = photo;
    else {
        UIGraphicsBeginImageContextWithOptions(photo.size, NO, photo.scale);
        [photo drawInRect:(CGRect){0, 0, photo.size}];
        normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    normalizedImage = [[self class] cropBiggestCenteredSquareImageFromImage:normalizedImage withSide:800];
    
    self.playerImage.image = normalizedImage;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *targetPhotoPath = [basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"player%ld.png",(long)self.playerNumber]];
    [UIImagePNGRepresentation(normalizedImage) writeToFile:targetPhotoPath atomically:YES];
    [self.game.playerPhotos setObject:normalizedImage forKey:[NSNumber numberWithInteger:self.playerNumber]];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    self.photoDenied = YES;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// http://stackoverflow.com/questions/14917770/finding-the-biggest-centered-square-from-a-landscape-or-a-portrait-uiimage-and-s
+ (UIImage*) cropBiggestCenteredSquareImageFromImage:(UIImage*)image withSide:(CGFloat)side
{
    // Get size of current image
    CGSize size = [image size];
    if( size.width == size.height && size.width == side){
        return image;
    }
    
    CGSize newSize = CGSizeMake(side, side);
    double ratio;
    double delta;
    CGPoint offset;
    
    //make a new square size, that is the resized imaged width
    CGSize sz = CGSizeMake(newSize.width, newSize.width);
    
    //figure out if the picture is landscape or portrait, then
    //calculate scale factor and offset
    if (image.size.width > image.size.height) {
        ratio = newSize.height / image.size.height;
        delta = ratio*(image.size.width - image.size.height);
        offset = CGPointMake(delta/2, 0);
    } else {
        ratio = newSize.width / image.size.width;
        delta = ratio*(image.size.height - image.size.width);
        offset = CGPointMake(0, delta/2);
    }
    
    //make the final clipping rect based on the calculated values
    CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                 (ratio * image.size.width),
                                 (ratio * image.size.height));
    
    //start a new context, with scale factor 0.0 so retina displays get
    //high quality image
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(sz);
    }
    UIRectClip(clipRect);
    [image drawInRect:clipRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


@end
