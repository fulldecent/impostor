//
//  ImpostorGameModel.h
//  Impostor
//
//  Created by William Entriken on 12/14/13.
//  Copyright (c) 2013 William Entriken. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum PlayerRoles {
    PlayerRoleNormalPlayer,
    PlayerRoleImpostor
} PlayerRoles;

typedef enum GameStatus {
    GameStatusShowSecretWords,
    GameStatusTheImpostorRemains,
    GameStatusTheImpostorWasDefeated,
    GameStatusTheImpostorWon
} GameStatus;

@interface ImpostorGameModel : NSObject
@property (nonatomic, readonly) NSInteger numberOfPlayers;
@property (nonatomic, readonly) NSArray *playerRoles; // of NSNumber of PlayerRoles
@property (nonatomic, readonly) NSArray *playerWords; // of NSStrings
@property (nonatomic, readonly) NSMutableArray *playerEliminated; // of NSNumber of BOOLs
@property (nonatomic, readonly) GameStatus gameStatus;
@property (nonatomic, readonly) NSInteger playerNumberToStartRound;
@property (nonatomic, readonly) NSString *normalWord;
@property (nonatomic, readonly) NSString *impostorWord;
- (void)startGameWithNumberOfPlayers:(NSInteger)numPlayers;
- (void)doneShowingSecretWords;
- (void)eliminatePlayer:(NSInteger)playerNumber;
+ (ImpostorGameModel *)game;
@end
