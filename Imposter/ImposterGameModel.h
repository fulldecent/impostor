//
//  ImposterGameModel.h
//  Imposter
//
//  Created by William Entriken on 12/14/13.
//  Copyright (c) 2013 William Entriken. All rights reserved.
//

#import <Foundation/Foundation.h>

enum PlayerRoles {
    PlayerRoleNormalPlayer,
    PlayerRoleImposter
};

enum GameStatus {
    GameStatusNewGame,
    GameStatusTheImposterRemains,
    GameStatusTheImposterWasDefeated,
    GameStatusTheImposterWon
};

@interface ImposterGameModel : NSObject
@property (nonatomic, readwrite) NSMutableDictionary *playerPhotos; // MODEL DOES NOT USE THIS

@property (nonatomic, readonly) NSInteger numberOfPlayers;
@property (nonatomic, readonly) NSArray *playerRoles; // of NSNumber of PlayerRoles
@property (nonatomic, readonly) NSArray *playerWords; // of NSStrings
@property (nonatomic, readonly) NSMutableArray *playerEliminated; // of NSNumber of BOOLs
@property (nonatomic, readonly) enum GameStatus gameStatus;
@property (nonatomic, readonly) NSInteger playerNumberToStartRound;
- (void)startGameWithNumberOfPlayers:(NSInteger)numPlayers;
- (void)doneShowingSecretWords;
- (void)eliminatePlayer:(NSInteger)playerNumber;
+ (ImposterGameModel *)game;
@end
