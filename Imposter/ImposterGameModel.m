//
//  ImposterGameModel.m
//  Imposter
//
//  Created by William Entriken on 12/14/13.
//  Copyright (c) 2013 William Entriken. All rights reserved.
//

#import "ImposterGameModel.h"

@interface ImposterGameModel()
@property (nonatomic) NSInteger numberOfPlayers;
@property (nonatomic) NSArray *playerRoles; // of NSNumber of PlayerRoles
@property (nonatomic) NSArray *playerWords; // of NSStrings
@property (nonatomic) NSMutableArray *playerEliminated; // of NSNumber of BOOLs
@property (nonatomic) enum GameStatus gameStatus;
@property (nonatomic) NSInteger playerNumberToStartRound;
@end

@implementation ImposterGameModel

#pragma mark - ACESSORS FOR INITIALIZERS

- (NSMutableDictionary *)playerPhotos
{
    if (!_playerPhotos)
        _playerPhotos = [[NSMutableDictionary alloc] init];
    return _playerPhotos;
}

- (NSArray *)playerRoles
{
    if (!_playerRoles)
        _playerRoles = [[NSArray alloc] init];
    return _playerRoles;
}

- (NSArray *)playerWords
{
    if (!_playerWords)
        _playerWords = [[NSArray alloc] init];
    return _playerWords;
}

- (NSArray *)playerEliminated
{
    if (!_playerEliminated)
        _playerEliminated = [[NSMutableArray alloc] init];
    return _playerEliminated;
}

#pragma mark - REAL FUNCTIONS

- (void)startGameWithNumberOfPlayers:(NSInteger)numPlayers
{
    self.numberOfPlayers = numPlayers;
    self.playerRoles = nil; //xxxx
    self.playerWords = nil; //xxxx
    self.playerEliminated = nil; //xxxx
    self.gameStatus = GameStatusNewGame;
    self.playerNumberToStartRound = 0; // CHOOSE RANDOM
#warning MUCH TO DO HERE
}

- (void)eliminatePlayer:(NSInteger)playerNumber
{
    NSNumber *currentStatus = [self.playerEliminated objectAtIndex:playerNumber];
    if (![currentStatus isEqualToNumber:[NSNumber numberWithBool:TRUE]])
        NSLog(@"WARNING eliminating player that is already eliminated");
    [self.playerEliminated replaceObjectAtIndex:playerNumber withObject:[NSNumber numberWithBool:TRUE]];
#warning SET NEXT PLAYER NUMBER!
#warning DECIDE IF NEED TO CHANGE GAME STATE
    self.playerNumberToStartRound = 0;
}

+ (ImposterGameModel *)game
{
    static ImposterGameModel *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ImposterGameModel alloc] init];
    });
    return sharedInstance;
}

@end



