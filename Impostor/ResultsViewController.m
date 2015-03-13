//
//  ResultsViewController.m
//  Impostor
//
//  Created by William Entriken on 12/15/13.
//  Copyright (c) 2013 William Entriken. All rights reserved.
//

#import "ResultsViewController.h"
#import "ImpostorGameModel.h"
#import <AudioToolbox/AudioToolbox.h>
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import <Appirater.h>
#import "CachedPersistentJPEGImageStore.h"
#import <SCLAlertView.h>

@interface ResultsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) ImpostorGameModel *game;
@property (nonatomic) SCLAlertView *sclAlertView;
@end

@implementation ResultsViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    self.game = [ImpostorGameModel game];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    BOOL allPhotos = YES;
    for (NSInteger i=0; i<self.game.numberOfPlayers; i++) {
        NSString *imageName = [NSString stringWithFormat:@"%ld", (long)i];
        if (![[CachedPersistentJPEGImageStore sharedStore] imageWithName:imageName])
            allPhotos = NO;
    }
    
    if (allPhotos) {
        self.collage.hidden = NO;
        self.shim.constant = 8;
    } else {
        self.collage.hidden = YES;
        self.shim.constant = -self.collage.frame.size.height;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    self.screenName = @"ResultsViewController";
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"ResultsViewController"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];    
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Gameplay"
                                                          action:@"Gameover"
                                                           label:@"NumberOfPlayers"
                                                           value:@(self.game.numberOfPlayers)] build]];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Gameplay"
                                                          action:@"Gameover"
                                                           label:@"ImpostorWon"
                                                           value:@(self.game.gameStatus==GameStatusTheImpostorWon)] build]];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Gameplay"
                                                          action:@"Words"
                                                           label:[NSString stringWithFormat:@"%@ - %@",self.game.normalWord,self.game.impostorWord]
                                                           value:@(self.game.gameStatus==GameStatusTheImpostorWon)] build]];
    
    BOOL allPhotos = YES;
    for (NSInteger i=0; i<self.game.numberOfPlayers; i++) {
        NSString *imageName = [NSString stringWithFormat:@"%ld", (long)i];
        if (![[CachedPersistentJPEGImageStore sharedStore] imageWithName:imageName])
            allPhotos = NO;
    }
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Gameplay"
                                                          action:@"Gameover"
                                                           label:@"All users did have photos"
                                                           value:@(allPhotos)] build]];
    
    SystemSoundID soundID;
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"results" withExtension:@"mp3"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
    AudioServicesPlaySystemSound (soundID);
    
    UIImage *appIcon = [UIImage imageNamed:@"AppIcon60x60"];
    switch (self.game.gameStatus) {
        case GameStatusTheImpostorWasDefeated:
            self.sclAlertView = [[SCLAlertView alloc] init];
            self.sclAlertView.shouldDismissOnTapOutside = YES;
            self.sclAlertView.backgroundType = Blur;
            self.sclAlertView.labelTitle.font = [UIFont fontWithName:@"Chalkboard SE" size:20.0];
            self.sclAlertView.viewText.font = [UIFont fontWithName:@"Chalkboard SE" size:16.0];
            [self.sclAlertView showCustom:self image:appIcon color:[UIColor blackColor] title:nil subTitle:NSLocalizedString(@"The impostor was defeated",@"After the game is over") closeButtonTitle:NSLocalizedString(@"OK",@"Dismiss the popup") duration:0.0f];
            break;
        case GameStatusTheImpostorWon:
            self.sclAlertView = [[SCLAlertView alloc] init];
            self.sclAlertView.shouldDismissOnTapOutside = YES;
            self.sclAlertView.backgroundType = Blur;
            self.sclAlertView.labelTitle.font = [UIFont fontWithName:@"Chalkboard SE" size:20.0];
            self.sclAlertView.viewText.font = [UIFont fontWithName:@"Chalkboard SE" size:16.0];
            [self.sclAlertView showCustom:self image:appIcon color:[UIColor blackColor] title:nil subTitle:NSLocalizedString(@"The impostor won",@"After the game is over") closeButtonTitle:NSLocalizedString(@"OK",@"Dismiss the popup") duration:0.0f];
            break;
        default:;
    }
    
    [Appirater userDidSignificantEvent:YES];
}

- (IBAction)playAgain:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UITableviewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.game.numberOfPlayers;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"resultCell"];
    
    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Player #%ld", @"Current player"), (long)indexPath.row+1];
    NSString *subtitle = (NSString *)(self.game.playerWords)[indexPath.row];
    UIImage *photo = [UIImage imageNamed:@"defaultHeadshot.png"];
    BOOL eliminated = [(NSNumber *)(self.game.playerEliminated)[indexPath.row] boolValue];
    
    cell.textLabel.text = title;
    cell.detailTextLabel.text = subtitle;
    cell.imageView.image = photo;
    cell.imageView.alpha = eliminated ? 0.4 : 1.0;
    
    NSString *imageName = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    photo = [[CachedPersistentJPEGImageStore sharedStore] imageWithName:imageName];
    if (photo)
        cell.imageView.image = photo;

    return cell;
}

@end
