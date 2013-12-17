//
//  EliminationViewController.m
//  Impostor
//
//  Created by William Entriken on 12/15/13.
//  Copyright (c) 2013 William Entriken. All rights reserved.
//

#import "EliminationViewController.h"
#import "ImpostorGameModel.h"
#import <AudioToolbox/AudioToolbox.h>
#import "GameConfigurationViewController.h"

@interface EliminationViewController () <UICollectionViewDataSource>
@property (nonatomic) ImpostorGameModel *game;
@property (nonatomic) UIAlertView *alertView;
@end

@implementation EliminationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.game = [ImpostorGameModel game];
    self.playerPhotoCollectionView.dataSource = self;
}

- (void)eliminatePlayer:(UIButton *)sender
{
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"eliminate" ofType:@"mp3"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    AudioServicesPlaySystemSound (soundID);

    CGPoint center = sender.center;
    CGPoint rootViewPoint = [sender.superview convertPoint:center toView:self.playerPhotoCollectionView];
    NSIndexPath *indexPath = [self.playerPhotoCollectionView indexPathForItemAtPoint:rootViewPoint];
    [self.game eliminatePlayer:indexPath.row];
    [self.playerPhotoCollectionView reloadData];
    
    if (self.game.gameStatus == GameStatusTheImpostorRemains) {
        self.alertView = [[UIAlertView alloc] initWithTitle:@"The impostor remains" message:[NSString stringWithFormat:@"Player #%i starts this round", self.game.playerNumberToStartRound+1] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.alertView show];
    } else if (self.game.gameStatus == GameStatusTheImpostorWasDefeated ||
               self.game.gameStatus == GameStatusTheImpostorWon) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Player #%d was randomly selected to start the first round", self.game.playerNumberToStartRound+1] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [self.alertView show];
    
    GameConfigurationViewController *root = (GameConfigurationViewController *)self.navigationController.viewControllers.firstObject;
    [root fadeOutMusic];
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
    [imageView setImage:photo];
    UIButton *button = (UIButton *)[cell viewWithTag:2];
    if ([(NSNumber *)[self.game.playerEliminated objectAtIndex:indexPath.row] isEqualToNumber:[NSNumber numberWithBool:TRUE]]) {
        imageView.alpha = 0.4;
        button.userInteractionEnabled = NO;
    } else {
        imageView.alpha = 1.0;
        button.userInteractionEnabled = YES;
    }
    photo = [self.game.playerPhotos objectForKey:[NSNumber numberWithInt:indexPath.row]];
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
    } while ((rows * cols >= self.game.numberOfPlayers) && ++cellMaxSide);
    CGFloat dim = MIN(cellMaxSide, cellMaxSide);
    
    [(UICollectionViewFlowLayout *)self.playerPhotoCollectionView.collectionViewLayout setItemSize:CGSizeMake(dim,dim)];
    [self.playerPhotoCollectionView reloadData];
}

@end
