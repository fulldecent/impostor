//
//  ViewController.m
//  Impostor
//
//  Created by William Entriken on 12/14/13.
//  Copyright (c) 2013 William Entriken. All rights reserved.
//

#import "GameConfigurationViewController.h"
#import "ImpostorGameModel.h"
#import "KxIntroViewController.h"
#import "KxIntroViewPage.h"
#import <MessageUI/MessageUI.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AudioToolbox/AudioToolbox.h>

@interface GameConfigurationViewController () <UICollectionViewDataSource, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic) NSInteger playerCount;
@property (nonatomic) ImpostorGameModel *game;
@property (nonatomic) UIActionSheet *actionSheet;
@property (nonatomic) AVAudioPlayer *audioPlayer;
@property (nonatomic) SystemSoundID buttonPress;
@end

@implementation GameConfigurationViewController

- (void)setPlayerCount:(NSInteger)playerCount
{
    if (playerCount < 3)
        _playerCount = 3;
    else if (playerCount > 12)
        _playerCount = 12;
    else
        _playerCount = playerCount;
    self.numberOfPlayersLabel.text = [NSString stringWithFormat:@"%d players", self.playerCount];
    [self.playerPhotoCollectionView reloadData];
    [self.view setNeedsLayout];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.playerPhotoCollectionView.dataSource = self;
    self.game = [ImpostorGameModel game];
    self.numberOfPlayersLabel.text = [NSString stringWithFormat:@"%d players", self.playerCount];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *savedPlayerCount = [defaults objectForKey:@"playerCount"];
    if (savedPlayerCount)
        self.playerCount = [savedPlayerCount intValue];
    else
        self.playerCount = 3;
    
    [(UICollectionViewFlowLayout *)self.playerPhotoCollectionView.collectionViewLayout setMinimumInteritemSpacing:10];
    [(UICollectionViewFlowLayout *)self.playerPhotoCollectionView.collectionViewLayout setMinimumLineSpacing:10];
    
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"buttonPress" ofType:@"mp3"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    self.buttonPress = soundID;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSString* bundleDirectory = (NSString*)[[NSBundle mainBundle] bundlePath];
    NSURL *url = [NSURL fileURLWithPath:[bundleDirectory stringByAppendingPathComponent:@"intro.mp3"]];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.audioPlayer play];
    
    // Show instructions on first run
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"didShowInstructions"]) {
        [self showInstructions:self];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"didShowInstructions"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
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
    KxIntroViewController *vc;
    AudioServicesPlaySystemSound (self.buttonPress);
    vc = [[KxIntroViewController alloc] initWithPages:@[
                                                        [KxIntroViewPage introViewPageWithTitle: @"A party game"
                                                                                     withDetail: @"For 3 to 12 players"
                                                                                      withImage: nil],
                                                        [KxIntroViewPage introViewPageWithTitle: @"Everyone sees their secret word"
                                                                                     withDetail: @"But the impostor's word is different"
                                                                                      withImage: nil],
                                                        [KxIntroViewPage introViewPageWithTitle: @"Each round players describe their word"
                                                                                     withDetail: @"and then vote to eliminate one player (can't use word to describe itself or repeat other players, break ties with a revote)"
                                                                                      withImage: nil],
                                                        [KxIntroViewPage introViewPageWithTitle: @"To win"
                                                                                     withDetail: @"the impostor must survive with one other player"
                                                                                      withImage: nil],
                                                        ]],
//    [self presentViewController:vc animated:YES completion:nil];
    [vc presentInViewController:self fullScreenLayout:YES];
}

- (IBAction)showGameOptions:(id)sender {
    AudioServicesPlaySystemSound (self.buttonPress);
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                          cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reset player photos", @"Help translate this app", @"Recommend game words", @"Share this app", nil];
    [self.actionSheet showFromRect:[(UIView *)[self.view viewWithTag:9] frame]  inView:self.view animated:YES];
}

- (IBAction)startGame:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *playerCountToSave = [NSNumber numberWithInteger:self.playerCount];
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
    
    photo = [self.game.playerPhotos objectForKey:[NSNumber numberWithInteger:indexPath.row]];
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
    [self.playerPhotoCollectionView reloadData];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == self.actionSheet.cancelButtonIndex)
        return;
    else if (buttonIndex == 0) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *photoPaths = [fileManager contentsOfDirectoryAtPath:basePath error:nil];
        for (NSString *path in photoPaths)
            [fileManager removeItemAtPath:[basePath stringByAppendingPathComponent:path] error:nil];
        [self.game.playerPhotos removeAllObjects];
        [self.playerPhotoCollectionView reloadData];
    } else if (buttonIndex == 1) {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            [picker setSubject:@"Impostor: Help translate"];
            [picker setToRecipients:[NSArray arrayWithObject:@"impostor@phor.net"]];
            [picker setMessageBody:@"I love the Impostor app and can help translate into: [[[WHICH LANGUAGE?]]]" isHTML:NO];
            [self presentViewController:picker animated:YES completion:nil];
        }
    } else if (buttonIndex == 2) {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            [picker setSubject:@"Impostor: Recommend game words"];
            [picker setToRecipients:[NSArray arrayWithObject:@"impostor@phor.net"]];
            [picker setMessageBody:@"I love the Impostor app and have an ideo of some more pairs of words you can use in it:" isHTML:NO];
            [self presentViewController:picker animated:YES completion:nil];
        }
    } else if (buttonIndex == 3) {
        // Create the item to share (in this example, a url)
        NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/whos-the-impostor/id784258202"];
        NSString *title = @"I am playing the party game Impostor";
        NSArray *itemsToShare = @[url, title];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll]; //or whichever you don't need
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
