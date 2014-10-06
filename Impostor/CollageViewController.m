//
//  CollageViewController.m
//  Impostor
//
//  Created by William Entriken on 2/19/14.
//  Copyright (c) 2014 William Entriken. All rights reserved.
//

#import "CollageViewController.h"
#import "ImpostorGameModel.h"
#import "GAIDictionaryBuilder.h"
#import <AVFoundation/AVAudioPlayer.h>
#import <AudioToolbox/AudioToolbox.h>
#import "GameConfigurationViewController.h"
#import "CachedPersistentJPEGImageStore.h"

@interface CollageViewController () <UICollectionViewDataSource>
@property (nonatomic) ImpostorGameModel *game;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@end

@implementation CollageViewController

- (ImpostorGameModel *)game
{
    if (!_game)
        _game = [ImpostorGameModel game];
    return _game;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.screenName = @"CollageViewController";
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"camera" withExtension:@"mp3"];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self performSelector:@selector(flashScreen) withObject:nil afterDelay:1.0];
    [self performSelector:@selector(showShareBox) withObject:nil afterDelay:1.8];
    
    GameConfigurationViewController *root = (GameConfigurationViewController *)self.navigationController.viewControllers.firstObject;
    [root fadeOutMusic];
}

- (void)flashScreen
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.audioPlayer play];
        UIView *flashView = [[UIView alloc] initWithFrame:self.view.frame];
        [flashView setBackgroundColor:[UIColor whiteColor]];
        [[[self view] window] addSubview:flashView];
        
        [UIView animateWithDuration:0.7f
                         animations:^{
                             [flashView setAlpha:0.f];
                         }
                         completion:^(BOOL finished){
                             [flashView removeFromSuperview];
                         }
         ];
    });
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.view setNeedsLayout];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.game.numberOfPlayers;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [self.playerPhotoCollectionView dequeueReusableCellWithReuseIdentifier:@"playerCell" forIndexPath:indexPath];
    UIImage *photo = [UIImage imageNamed:@"defaultHeadshot.png"];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    imageView.image = photo;
    
    NSString *imageName = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    photo = [[CachedPersistentJPEGImageStore sharedStore] imageWithName:imageName];
    if (photo)
        imageView.image = photo;

#define ARC4RANDOM_MAX      0x100000000
    double val = ((double)arc4random() / ARC4RANDOM_MAX);
    double rotate = M_PI*30/180*(val-0.5);

    imageView.transform = CGAffineTransformMakeRotation(rotate);
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    bounceAnimation.values = [NSArray arrayWithObjects:@(0), @(rotate*0.5), @(-rotate*2), @(rotate), nil];
    bounceAnimation.duration = ((double)arc4random() / ARC4RANDOM_MAX);
    bounceAnimation.removedOnCompletion = YES;
    bounceAnimation.repeatCount = 0;
    bounceAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [imageView.layer addAnimation:bounceAnimation forKey:@"spin"];
    
    [self makeItBounce:imageView];
    return cell;
}

- (void)viewDidLayoutSubviews
{
    NSInteger cellMaxSide = 0, rows=9999, cols=9999;
    do {
        // if your cellWidth != cellHeight, switch here to set the larger then smaller of the two
        cols = floorf((self.playerPhotoCollectionView.frame.size.width+10)/((cellMaxSide+1)+10));
        rows = floorf((self.playerPhotoCollectionView.frame.size.height+10)/((cellMaxSide+1)+10));
    } while ((rows * cols >= self.game.numberOfPlayers) && ++cellMaxSide);
    CGFloat dim = MIN(cellMaxSide, cellMaxSide);
    
    [(UICollectionViewFlowLayout *)self.playerPhotoCollectionView.collectionViewLayout setItemSize:CGSizeMake(dim,dim)];
//    [self.playerPhotoCollectionView reloadData];
}

- (void)makeItBounce:(UIView *)view
{
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    bounceAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:1], [NSNumber numberWithFloat:1.2], nil];
    bounceAnimation.duration = 0.15;
    bounceAnimation.removedOnCompletion = NO;
    bounceAnimation.repeatCount = 2;
    bounceAnimation.autoreverses = YES;
    bounceAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [view.layer addAnimation:bounceAnimation forKey:@"bounce"];
}

- (void)showShareBox
{
    // Create the item to share (in this example, a url)
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/whos-the-impostor/id784258202"];
    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"I am playing the party game %@", @"Text for sharing on social network"), appName];
    UIImage* image = nil;
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.view.layer renderInContext: UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSArray *itemsToShare = @[image, title, url];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAssignToContact];
    
    [activityVC setCompletionHandler:^(NSString *activityType, BOOL completed) {
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Gameplay"
                                                              action:@"Gameover"
                                                               label:@"SharedCollage"
                                                               value:@(completed)] build]];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    [self presentViewController:activityVC animated:YES completion:nil];
}

@end
