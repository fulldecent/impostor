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

#pragma mark - REAL FUNCTIONS

- (void)startGameWithNumberOfPlayers:(NSInteger)numPlayers
{
    self.numberOfPlayers = numPlayers;
    int imposterIndex = arc4random() % self.numberOfPlayers;
    
    NSMutableArray *roles = [[NSMutableArray alloc] initWithCapacity:numPlayers];
    NSMutableArray *words = [[NSMutableArray alloc] initWithCapacity:numPlayers];
    NSMutableArray *eliminated = [[NSMutableArray alloc] initWithCapacity:numPlayers];
    
    for (int i=0; i<numPlayers; i++) {
        if (i == imposterIndex) {
            [roles addObject:[NSNumber numberWithInt:PlayerRoleImposter]];
            [words addObject:@"IMPOSTER WORD"];
#warning SET CORRECTLY
        } else {
            [roles addObject:[NSNumber numberWithInt:PlayerRoleNormalPlayer]];
            [words addObject:@"NORMAL WORD"];
#warning SET CORRECTLY
        }
        [eliminated addObject:[NSNumber numberWithBool:FALSE]];
    }

    self.playerRoles = roles;
    self.playerWords = words;
    self.playerEliminated = eliminated;
    self.gameStatus = GameStatusNewGame;
    self.playerNumberToStartRound = arc4random() % self.numberOfPlayers;
}

- (void)eliminatePlayer:(NSInteger)playerNumber
{
    NSNumber *currentStatus = [self.playerEliminated objectAtIndex:playerNumber];
    if ([currentStatus isEqualToNumber:[NSNumber numberWithBool:TRUE]])
        NSLog(@"WARNING eliminating player that is already eliminated");
    [self.playerEliminated replaceObjectAtIndex:playerNumber withObject:[NSNumber numberWithBool:TRUE]];
    
    int countOfRemainingImposters = 0;
    int countOfRemainingNormalPlayers = 0;
    for (int i=0; i<self.numberOfPlayers; i++) {
        if ([(NSNumber *)[self.playerEliminated objectAtIndex:i] isEqualToNumber:[NSNumber numberWithBool:TRUE]])
            continue;
        switch ([(NSNumber *)[self.playerRoles objectAtIndex:i] intValue]) {
            case PlayerRoleImposter:
                countOfRemainingImposters++;
                break;
            case PlayerRoleNormalPlayer:
                countOfRemainingNormalPlayers++;
                break;
        }
    }
    if (countOfRemainingImposters == 0)
        self.gameStatus = GameStatusTheImposterWasDefeated;
    else if (countOfRemainingNormalPlayers == 1)
        self.gameStatus = GameStatusTheImposterWon;

    self.playerNumberToStartRound = playerNumber;
    while ([[self.playerEliminated objectAtIndex:self.playerNumberToStartRound] isEqualToNumber:[NSNumber numberWithBool:TRUE]])
        self.playerNumberToStartRound = (self.playerNumberToStartRound + 1) % self.numberOfPlayers;
}

- (void)doneShowingSecretWords
{
    self.gameStatus = GameStatusTheImposterRemains;
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



