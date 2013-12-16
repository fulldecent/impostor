//
//  ViewController.m
//  Imposter
//
//  Created by William Entriken on 12/14/13.
//  Copyright (c) 2013 William Entriken. All rights reserved.
//

#import "GameConfigurationViewController.h"
#import "ImposterGameModel.h"
#import "KxIntroViewController.h"
#import "KxIntroViewPage.h"
#import <MessageUI/MessageUI.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AudioToolbox/AudioToolbox.h>

@interface GameConfigurationViewController () <UICollectionViewDataSource, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic) NSInteger playerCount;
@property (nonatomic) ImposterGameModel *game;
@property (nonatomic) UIActionSheet *actionSheet;
@property (nonatomic) AVAudioPlayer *audioPlayer;
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
    self.game = [ImposterGameModel game];
    self.numberOfPlayersLabel.text = [NSString stringWithFormat:@"%d players", self.playerCount];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *savedPlayerCount = [defaults objectForKey:@"playerCount"];
    if (savedPlayerCount)
        self.playerCount = [savedPlayerCount intValue];
    else
        self.playerCount = 3;
    
    [(UICollectionViewFlowLayout *)self.playerPhotoCollectionView.collectionViewLayout setMinimumInteritemSpacing:10];
    [(UICollectionViewFlowLayout *)self.playerPhotoCollectionView.collectionViewLayout setMinimumLineSpacing:10];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSString* bundleDirectory = (NSString*)[[NSBundle mainBundle] bundlePath];
    NSURL *url = [NSURL fileURLWithPath:[bundleDirectory stringByAppendingPathComponent:@"intro.mp3"]];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.audioPlayer play];
}

- (IBAction)decrementPlayerCount:(id)sender {
    self.playerCount--;
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"buttonPress" ofType:@"mp3"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    AudioServicesPlaySystemSound (soundID);
}

- (IBAction)incrementPlayerCount:(id)sender {
    self.playerCount++;
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"buttonPress" ofType:@"mp3"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    AudioServicesPlaySystemSound (soundID);
}

- (IBAction)showInstructions:(id)sender {
    KxIntroViewController *vc;
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"buttonPress" ofType:@"mp3"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    AudioServicesPlaySystemSound (soundID);
    vc = [[KxIntroViewController alloc] initWithPages:@[
                                                        [KxIntroViewPage introViewPageWithTitle: @"A party game"
                                                                                     withDetail: @"For 3 to 12 players"
                                                                                      withImage: [UIImage imageNamed:@"homeScreenBackground.gif"]],
                                                        [KxIntroViewPage introViewPageWithTitle: @"Everyone sees their secret word"
                                                                                     withDetail: @"But the imposter's word is different"
                                                                                      withImage: [UIImage imageNamed:@"homeScreenBackground.gif"]],
                                                        [KxIntroViewPage introViewPageWithTitle: @"Each round players describe their word"
                                                                                     withDetail: @"and then vote to eliminate one player (can't use word to describe itself, break ties with a revote)"
                                                                                      withImage: [UIImage imageNamed:@"homeScreenBackground.gif"]],
                                                        [KxIntroViewPage introViewPageWithTitle: @"To win"
                                                                                     withDetail: @"the imposter must survive with one other player"
                                                                                      withImage: [UIImage imageNamed:@"homeScreenBackground.gif"]],
                                                        ]],
//    [self presentViewController:vc animated:YES completion:nil];
    [vc presentInViewController:self fullScreenLayout:YES];
}

- (IBAction)showGameOptions:(id)sender {
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"buttonPress" ofType:@"mp3"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    AudioServicesPlaySystemSound (soundID);
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                          cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reset player photos", @"Help translate this app", @"Recommend game words", @"Share this app", nil];
    [self.actionSheet showFromRect:[(UIView *)[self.view viewWithTag:9] frame]  inView:self.view animated:YES];
}

- (IBAction)startGame:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *playerCountToSave = [NSNumber numberWithInt:self.playerCount];
    [defaults setObject:playerCountToSave forKey:@"playerCount"];
    [defaults synchronize];
    [self.game startGameWithNumberOfPlayers:self.playerCount];
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
    UIImage *photo = [UIImage imageNamed:@"defaultHeadshot.gif"];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    imageView.image = photo;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *targetPhotoPath = [basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"player%d.png",indexPath.row]];
    photo = [UIImage imageWithContentsOfFile:targetPhotoPath];
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
        [self.playerPhotoCollectionView reloadData];
    } else if (buttonIndex == 1) {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            [picker setSubject:@"Imposter: Help translate"];
            [picker setToRecipients:[NSArray arrayWithObject:@"imposter@phor.net"]];
            [picker setMessageBody:@"I love the Imposter app and can help translate into: [[[WHICH LANGUAGE?]]]" isHTML:NO];
            [self presentViewController:picker animated:YES completion:nil];
        }
    } else if (buttonIndex == 2) {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            [picker setSubject:@"Imposter: Recommend game words"];
            [picker setToRecipients:[NSArray arrayWithObject:@"imposter@phor.net"]];
            [picker setMessageBody:@"I love the Imposter app and have an ideo of some more pairs of words you can use in it:" isHTML:NO];
            [self presentViewController:picker animated:YES completion:nil];
        }
    } else if (buttonIndex == 3) {
        // Create the item to share (in this example, a url)
        NSString *urlString = @"http://phor.net";
        NSURL *url = [NSURL URLWithString:urlString];
        NSString *title = @"I am playing the party game Imposter";
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
