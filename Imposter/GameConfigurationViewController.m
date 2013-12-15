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
    self.numberOfPlayersLabel.text = [NSString stringWithFormat:@"%d players", self.playerCount];
    [self.playerPhotoCollectionView reloadData];
    [self.view setNeedsLayout];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.playerPhotoCollectionView.dataSource = self;
    self.playerCount = 3;
    self.game = [ImposterGameModel game];
#warning GET FROM PREFERENCES
#warning GET PLAYER FACES
    self.numberOfPlayersLabel.text = [NSString stringWithFormat:@"%d players", self.playerCount];
    
    
    
    [(UICollectionViewFlowLayout *)self.playerPhotoCollectionView.collectionViewLayout setMinimumInteritemSpacing:10];
    [(UICollectionViewFlowLayout *)self.playerPhotoCollectionView.collectionViewLayout setMinimumLineSpacing:10];
  
    
    
}

- (IBAction)decrementPlayerCount:(id)sender {
    self.playerCount--;
}

- (IBAction)incrementPlayerCount:(id)sender {
    self.playerCount++;
}

- (IBAction)showInstructions:(id)sender {
#warning TODO
}

- (IBAction)showGameOptions:(id)sender {
#warning TODO
}

- (IBAction)startGame:(id)sender {
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
    [imageView setImage:photo];
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



@end
