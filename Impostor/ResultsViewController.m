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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"results" ofType:@"mp3"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    AudioServicesPlaySystemSound (soundID);
    
    switch (self.game.gameStatus) {
        case GameStatusTheImpostorWasDefeated:
            self.alertView = [[UIAlertView alloc] initWithTitle:nil message:@"The impostor was defeated" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            break;
        case GameStatusTheImpostorWon:
            self.alertView = [[UIAlertView alloc] initWithTitle:nil message:@"The impostor won" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            break;
        default:;
    }
    [self.alertView show];
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

    NSString *title = [NSString stringWithFormat:@"Player #%d", indexPath.row+1];
    if (eliminated)
        [title stringByAppendingString:@" ELIMINATED"];
    
    NSString *subtitle;
    subtitle = word;
    
    cell.textLabel.text = title;
    cell.detailTextLabel.text = subtitle;
    cell.imageView.image = photo;
    cell.imageView.alpha = eliminated ? 0.4 : 1.0;
    
    photo = [self.game.playerPhotos objectForKey:[NSNumber numberWithInt:indexPath.row]];
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
