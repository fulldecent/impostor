//
//  ResultsViewController.m
//  Imposter
//
//  Created by William Entriken on 12/15/13.
//  Copyright (c) 2013 William Entriken. All rights reserved.
//

#import "ResultsViewController.h"
#import "ImposterGameModel.h"

@interface ResultsViewController () <UITableViewDataSource>
@property (nonatomic) ImposterGameModel *game;
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
    self.game = [ImposterGameModel game];
    self.tableView.dataSource = self;
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    switch (self.game.gameStatus) {
        case GameStatusTheImposterWasDefeated:
            self.alertView = [[UIAlertView alloc] initWithTitle:nil message:@"The imposter was defeated" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            break;
        case GameStatusTheImposterWon:
            self.alertView = [[UIAlertView alloc] initWithTitle:nil message:@"The imposter won" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
    UIImage *photo = [UIImage imageNamed:@"defaultHeadshot.gif"];
    
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
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *targetPhotoPath = [basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"player%d.png",indexPath.row]];
    photo = [UIImage imageWithContentsOfFile:targetPhotoPath];
    if (photo)
        cell.imageView.image = photo;

    return cell;
}

@end
