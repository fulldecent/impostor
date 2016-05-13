//
//  ViewController.m
//  Impostor
//
//  Created by William Entriken on 12/14/13.
//  Copyright (c) 2013 William Entriken. All rights reserved.
//

#import "Impostor-Swift.h"
#import "GameConfigurationViewController.h"
#import "KxIntroViewController.h"
#import "KxIntroViewPage.h"
#import <MessageUI/MessageUI.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AudioToolbox/AudioToolbox.h>
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "RMStore.h"

@interface GameConfigurationViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic) NSInteger playerCount;
@property (nonatomic) ImpostorGameModel *game;
@property (nonatomic) AVAudioPlayer *audioPlayer;
@property (nonatomic) SystemSoundID buttonPress;
@end

@implementation GameConfigurationViewController

- (void)setPlayerCount:(NSInteger)playerCount
{
    _playerCount = playerCount;
    if (_playerCount < 3)
        _playerCount = 3;
    else if (_playerCount > 12)
        _playerCount = 12;
    
    self.numberOfPlayersLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%ld players",@"Number of players in the game"), (long)self.playerCount];
    for (long i = [self.playerPhotoCollectionView numberOfItemsInSection:0]; i < _playerCount; i++) {
        [self.playerPhotoCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:i inSection:0]]];
    }
    for (long i = [self.playerPhotoCollectionView numberOfItemsInSection:0]; i > _playerCount; i--) {
        [self.playerPhotoCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:i-1 inSection:0]]];
    }
    
    [self.view setNeedsLayout];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.playerPhotoCollectionView.dataSource = self;
    self.playerPhotoCollectionView.delegate = self;
    self.game = [ImpostorGameModel game];
    self.numberOfPlayersLabel.text = [NSString stringWithFormat:@"%ld players", (long)self.playerCount];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *savedPlayerCount = [defaults objectForKey:@"playerCount"];
    if (savedPlayerCount)
        self.playerCount = [savedPlayerCount intValue];
    else
        self.playerCount = 3;
    
    [(UICollectionViewFlowLayout *)self.playerPhotoCollectionView.collectionViewLayout setMinimumInteritemSpacing:10];
    [(UICollectionViewFlowLayout *)self.playerPhotoCollectionView.collectionViewLayout setMinimumLineSpacing:10];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"buttonPress" withExtension:@"mp3"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
    self.buttonPress = soundID;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // https://stackoverflow.com/questions/3460694/uibutton-wont-go-to-aspect-fit-in-iphone/3995820#3995820
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:UIButton.class]) {
            UIButton *button = (UIButton *)view;
            [button.imageView setContentMode:UIViewContentModeScaleAspectFit];
        }
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *didIAP = [defaults objectForKey:@"didIAP"];
    if (didIAP && didIAP.integerValue) {
        self.buyButton.imageView.image = [UIImage imageNamed:@"money-paid"];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.screenName = @"GameConfigurationViewController";
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"intro" withExtension:@"mp3"];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.audioPlayer play];
    
#ifndef SNAPSHOT
    // Show instructions on first run
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"didShowInstructions"]) {
        [self showInstructions:self];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"didShowInstructions"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
#endif
    
    /* TMPORARY TO GET LAUNCH IMAGES
    for (UIView *subview in self.view.subviews)
        if (![subview isKindOfClass:[UIImageView class]])
            subview.hidden=YES;
    */
}
/* TEMPORARY TO GET LAUNCH IMAGES
- (BOOL)prefersStatusBarHidden{return YES;}
*/

- (IBAction)decrementPlayerCount:(id)sender {
    self.playerCount--;
    AudioServicesPlaySystemSound (self.buttonPress);
}

- (IBAction)incrementPlayerCount:(id)sender {
    self.playerCount++;
    AudioServicesPlaySystemSound (self.buttonPress);
}

- (IBAction)showInstructions:(id)sender {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"IntroViewController"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];

    KxIntroViewController *vc;
    AudioServicesPlaySystemSound (self.buttonPress);
    vc = [[KxIntroViewController alloc] initWithPages:@[
                                                        [KxIntroViewPage introViewPageWithTitle: NSLocalizedString(@"A party game", @"Intro screen 1 title")
                                                                                     withDetail: NSLocalizedString(@"For 3 to 12 players", @"Intro screen 1 detail")
                                                                                      withImage: [UIImage imageNamed:@"help1"]],
                                                        [KxIntroViewPage introViewPageWithTitle: NSLocalizedString(@"Everyone sees their secret word", @"Intro screen 2 title")
                                                                                     withDetail: NSLocalizedString(@"But the impostor's word is different", @"Intro screen 2 detail")
                                                                                      withImage: [UIImage imageNamed:@"help2"]],
                                                        [KxIntroViewPage introViewPageWithTitle: NSLocalizedString(@"Each round players describe their word", @"Intro screen 3 title")
                                                                                     withDetail: NSLocalizedString(@"then vote to eliminate one player (can't use word to describe itself or repeat other players, break ties with a revote)", @"Intro screen 3 detail")
                                                                                      withImage: [UIImage imageNamed:@"help3"]],
                                                        [KxIntroViewPage introViewPageWithTitle: NSLocalizedString(@"To win", @"Intro screen 4 title")
                                                                                     withDetail: NSLocalizedString(@"the impostor must survive with one other player", @"Intro screen 4 detail")
                                                                                      withImage: [UIImage imageNamed:@"help4"]],
                                                        ]],
    [vc presentInViewController:self fullScreenLayout:YES];
}

- (IBAction)resetPlayerPhotos:(id)sender {
    AudioServicesPlaySystemSound (self.buttonPress);
    [[CachedPersistentJPEGImageStore sharedStore] deleteAllImages];
    [self.playerPhotoCollectionView reloadData];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Gameplay"
                                                          action:@"Configuration"
                                                           label:@"ResetPlayerPhotos"
                                                           value:@(1)] build]];
}

- (IBAction)viewWeixin:(id)sender {
    AudioServicesPlaySystemSound (self.buttonPress);
    NSURL *wxurl = [NSURL URLWithString:@"weixin://contacts/profile/fulldecent"];
    NSURL *backupurl = [NSURL URLWithString:@"http://user.qzone.qq.com/858772059"];
    if ([[UIApplication sharedApplication] canOpenURL: wxurl]){
        [[UIApplication sharedApplication] openURL:wxurl];
    } else {
        [[UIApplication sharedApplication] openURL:backupurl];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"weixin://contacts/profile/fulldecent"]];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Other"
                                                          action:@"View Weixin"
                                                           label:nil
                                                           value:@([[UIApplication sharedApplication] canOpenURL: wxurl])] build]];
}

- (IBAction)recommendWords:(id)sender {
    AudioServicesPlaySystemSound (self.buttonPress);
    NSURL *url = [NSURL URLWithString:@"http://phor.net/apps/impostor/newWords.php"];
    [[UIApplication sharedApplication] openURL:url];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Gameplay"
                                                          action:@"Configuration"
                                                           label:@"SuggestWords"
                                                           value:@(1)] build]];
}

- (IBAction)buyUpgrade:(id)sender {
    AudioServicesPlaySystemSound (self.buttonPress);
    // Document the attempt before anything
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Gameplay"
                                                          action:@"Unlock"
                                                           label:@"IAP Try"
                                                           value:@(1)] build]];
    
    // Check if they already have it
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *unlock = [defaults objectForKey:@"didIAP"];
    if (unlock && unlock.integerValue) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Your previous purchase was restored", @"In-app purchase")
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Dismiss the popup")
                                              otherButtonTitles:nil];
        [alert show];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Gameplay"
                                                              action:@"Unlock"
                                                               label:@"IAP Already Had"
                                                               value:@(1)] build]];
        return;
    }
    
    // Try to unlock past sale
    [[RMStore defaultStore] restoreTransactionsOnSuccess:^(NSArray *transactions){
        if (transactions.count) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@(1) forKey:@"didIAP"];
            [defaults synchronize];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Your previous purchase was restored", @"In-app purchase")
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"Dismiss the popup")
                                                  otherButtonTitles:nil];
            [alert show];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Gameplay"
                                                                  action:@"Unlock"
                                                                   label:@"IAP Restore"
                                                                   value:@(1)] build]];
        }
        return;
    } failure:^(NSError *error) {
    }];
    
    // Try to make new sale
    NSSet *products = [NSSet setWithArray:@[@"words0001"]];
    [[RMStore defaultStore] requestProducts:products success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        NSLog(@"Products loaded");
        [[RMStore defaultStore] addPayment:@"words0001" success:^(SKPaymentTransaction *transaction) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@(1) forKey:@"didIAP"];
            [defaults synchronize];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Thank you for your purchase!", @"In-app purchase")
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"Dismiss the popup")
                                                  otherButtonTitles:nil];
            [alert show];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Gameplay"
                                                                  action:@"Unlock"
                                                                   label:@"IAP Success"
                                                                   value:@(1)] build]];
        } failure:^(SKPaymentTransaction *transaction, NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"There was a problem with your purchase!", @"In-app purchase")
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"Dismiss the popup")
                                                  otherButtonTitles:nil];
            [alert show];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Gameplay"
                                                                  action:@"Unlock"
                                                                   label:@"IAP Error"
                                                                   value:@(0)] build]];
        }];
    } failure:^(NSError *error) {
        NSLog(@"Something went wrong");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"There was a problem with your purchase!", @"In-app purchase")
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Dismiss the popup")
                                              otherButtonTitles:nil];
        [alert show];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Gameplay"
                                                              action:@"Unlock"
                                                               label:@"IAP Error"
                                                               value:@(0)] build]];
    }];
}


- (IBAction)startGame:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *playerCountToSave = @(self.playerCount);
    [defaults setObject:playerCountToSave forKey:@"playerCount"];
    [defaults synchronize];
    [self.game startGameWithNumberOfPlayers:self.playerCount];
}

- (void)fadeOutMusic
{
    // http://stackoverflow.com/questions/1216581/avaudioplayer-fade-volume-out
    if (self.audioPlayer.volume > 0.1) {
        self.audioPlayer.volume -= 0.1;
        [self performSelector:@selector(fadeOutMusic) withObject:nil afterDelay:0.1];
    } else {
        // Stop and get the sound ready for playing again
        [self.audioPlayer stop];
        self.audioPlayer.currentTime = 0;
        [self.audioPlayer prepareToPlay];
        self.audioPlayer.volume = 1.0;
    }
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
    return self.playerCount;
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
    return cell;
}

- (void)viewDidLayoutSubviews
{
    NSInteger cellMaxSide = 0, rows=9999, cols=9999;
    do {
        // if your cellWidth != cellHeight, switch here to set the larger then smaller of the two
        cols = floorf((self.playerPhotoCollectionView.frame.size.width+10)/((cellMaxSide+1)+10));
        rows = floorf((self.playerPhotoCollectionView.frame.size.height+10)/((cellMaxSide+1)+10));
    } while ((rows * cols >= self.playerCount) && ++cellMaxSide);
    CGFloat dim = MIN(cellMaxSide, cellMaxSide);
    [(UICollectionViewFlowLayout *)self.playerPhotoCollectionView.collectionViewLayout setItemSize:CGSizeMake(dim,dim)];
//    [self.playerPhotoCollectionView reloadData];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self makeItBounce:cell];
}

- (void)makeItBounce:(UIView *)view
{
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    bounceAnimation.values = @[@1.0f, @1.2f];
    bounceAnimation.duration = 0.15;
    bounceAnimation.removedOnCompletion = NO;
    bounceAnimation.repeatCount = 2;
    bounceAnimation.autoreverses = YES;
    bounceAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [view.layer addAnimation:bounceAnimation forKey:@"bounce"];
}

@end
