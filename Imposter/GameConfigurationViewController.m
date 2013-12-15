//
//  ViewController.m
//  Imposter
//
//  Created by William Entriken on 12/14/13.
//  Copyright (c) 2013 William Entriken. All rights reserved.
//

#import "GameConfigurationViewController.h"
#import "ImposterGameModel.h"

@interface GameConfigurationViewController () <UICollectionViewDataSource>
@property (nonatomic) NSInteger playerCount;
@property (nonatomic) ImposterGameModel *game;
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.playerPhotoCollectionView.dataSource = self;
    self.playerCount = 6;
    self.game = [ImposterGameModel game];
#warning GET FROM PREFERENCES
#warning GET PLAYER FACES
    self.numberOfPlayersLabel.text = [NSString stringWithFormat:@"%d players", self.playerCount];
}

- (IBAction)decrementPlayerCount:(id)sender {
    self.playerCount--;
    self.numberOfPlayersLabel.text = [NSString stringWithFormat:@"%d players", self.playerCount];
    [self.playerPhotoCollectionView reloadData];
}

- (IBAction)incrementPlayerCount:(id)sender {
    self.playerCount++;
    self.numberOfPlayersLabel.text = [NSString stringWithFormat:@"%d players", self.playerCount];
    [self.playerPhotoCollectionView reloadData];
}

- (IBAction)showInstructions:(id)sender {
#warning TODO
}

- (IBAction)showGameOptions:(id)sender {
#warning TODO
}

- (IBAction)startGame:(id)sender {
#warning TODO
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
    [imageView setImage:photo];
    return cell;
}

@end
