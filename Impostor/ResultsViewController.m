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
#import <Appirater.h>

@interface ResultsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) ImpostorGameModel *game;
@property (nonatomic) UIAlertView *alertView;
@end

@implementation ResultsViewController

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
    self.game = [ImpostorGameModel game];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    BOOL allPhotos = YES;
    for (NSInteger i=0; i<self.game.numberOfPlayers; i++) {
        if (![self.game.playerPhotos objectForKey:@(i)])
            allPhotos = NO;
    }

    if ((arc4random() % 6 == 0) && allPhotos) {
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
    self.screenName = @"ResultsViewController";
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
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
        if (![self.game.playerPhotos objectForKey:@(i)])
            allPhotos = NO;
    }
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Gameplay"
                                                          action:@"Gameover"
                                                           label:@"All users did have photos"
                                                           value:@(allPhotos)] build]];
    
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"results" ofType:@"mp3"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    AudioServicesPlaySystemSound (soundID);
    
    switch (self.game.gameStatus) {
        case GameStatusTheImpostorWasDefeated:
            self.alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"The impostor was defeated",@"After the game is over") delegate:self cancelButtonTitle:NSLocalizedString(@"OK",@"Dismiss the popup") otherButtonTitles:nil];
            break;
        case GameStatusTheImpostorWon:
            self.alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"The impostor won",@"After the game is over") delegate:self cancelButtonTitle:NSLocalizedString(@"OK",@"Dismiss the popup") otherButtonTitles:nil];
            break;
        default:;
    }
    [self.alertView show];
    
    [Appirater userDidSignificantEvent:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    UIImage *photo = [UIImage imageNamed:@"defaultHeadshot.png"];
    
    BOOL eliminated = [(NSNumber *)[self.game.playerEliminated objectAtIndex:indexPath.row] boolValue];
    NSString *word = (NSString *)[self.game.playerWords objectAtIndex:indexPath.row];

    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Player #%ld", @"Current player"), (long)indexPath.row+1];
    
    NSString *subtitle;
    subtitle = word;
    
    cell.textLabel.text = title;
    cell.detailTextLabel.text = subtitle;
    cell.imageView.image = photo;
    cell.imageView.alpha = eliminated ? 0.4 : 1.0;
    
    photo = [self.game.playerPhotos objectForKey:[NSNumber numberWithInteger:indexPath.row]];
    if (photo)
        cell.imageView.image = photo;

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

@end
