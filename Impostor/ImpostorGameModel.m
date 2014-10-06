//
//  ImpostorGameModel.m
//  Impostor
//
//  Created by William Entriken on 12/14/13.
//  Copyright (c) 2013 William Entriken. All rights reserved.
//

#import "ImpostorGameModel.h"

@interface ImpostorGameModel()
@property (nonatomic) NSInteger numberOfPlayers;
@property (nonatomic) NSArray *playerRoles; // of NSNumber of PlayerRoles
@property (nonatomic) NSArray *playerWords; // of NSStrings
@property (nonatomic) NSMutableArray *playerEliminated; // of NSNumber of BOOLs
@property (nonatomic) GameStatus gameStatus;
@property (nonatomic) NSInteger playerNumberToStartRound;
@property (nonatomic) NSString *normalWord;
@property (nonatomic) NSString *impostorWord;
@end

@implementation ImpostorGameModel

#pragma mark - ACESSORS FOR INITIALIZERS

- (void)startGameWithNumberOfPlayers:(NSInteger)numPlayers
{
    self.numberOfPlayers = numPlayers;
    int impostorIndex = arc4random() % self.numberOfPlayers;
    
    NSMutableArray *roles = [[NSMutableArray alloc] initWithCapacity:numPlayers];
    NSMutableArray *words = [[NSMutableArray alloc] initWithCapacity:numPlayers];
    self.playerEliminated = [[NSMutableArray alloc] initWithCapacity:numPlayers];
    
    NSURL *jsonURL = [[NSBundle mainBundle] URLForResource:@"gameWords" withExtension:@"json"];
    NSString *jsonString = [NSString stringWithContentsOfURL:jsonURL encoding:NSUTF8StringEncoding error:nil];
    NSArray *allWordSets = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    int chosenWordSet = arc4random() % allWordSets.count;
    int chosenImpostorWord = arc4random() % 2;
    self.impostorWord = [(NSArray *)[allWordSets objectAtIndex:chosenWordSet] objectAtIndex:chosenImpostorWord];
    self.normalWord = [(NSArray *)[allWordSets objectAtIndex:chosenWordSet] objectAtIndex:1-chosenImpostorWord];
    
    for (int i=0; i<numPlayers; i++) {
        if (i == impostorIndex) {
            [roles addObject:[NSNumber numberWithInt:PlayerRoleImpostor]];
            [words addObject:self.impostorWord];
        } else {
            [roles addObject:[NSNumber numberWithInt:PlayerRoleNormalPlayer]];
            [words addObject:self.normalWord];
        }
        [self.playerEliminated addObject:[NSNumber numberWithBool:NO]];
    }

    self.playerRoles = [roles copy];
    self.playerWords = [words copy];
    self.gameStatus = GameStatusShowSecretWords;
    self.playerNumberToStartRound = arc4random() % self.numberOfPlayers;
}

- (void)eliminatePlayer:(NSInteger)playerNumber
{
    NSNumber *currentStatus = [self.playerEliminated objectAtIndex:playerNumber];
    if ([currentStatus isEqualToNumber:[NSNumber numberWithBool:YES]])
        NSLog(@"WARNING eliminating player that is already eliminated");
    [self.playerEliminated replaceObjectAtIndex:playerNumber withObject:[NSNumber numberWithBool:YES]];
    
    int countOfRemainingImpostors = 0;
    int countOfRemainingNormalPlayers = 0;
    for (int i=0; i<self.numberOfPlayers; i++) {
        if ([(NSNumber *)[self.playerEliminated objectAtIndex:i] isEqualToNumber:[NSNumber numberWithBool:YES]])
            continue;
        PlayerRoles role = [(NSNumber *)[self.playerRoles objectAtIndex:i] intValue];
        switch (role) {
            case PlayerRoleImpostor:
                countOfRemainingImpostors++;
                break;
            case PlayerRoleNormalPlayer:
                countOfRemainingNormalPlayers++;
                break;
        }
    }
    if (countOfRemainingImpostors == 0)
        self.gameStatus = GameStatusTheImpostorWasDefeated;
    else if (countOfRemainingNormalPlayers == 1)
        self.gameStatus = GameStatusTheImpostorWon;

    self.playerNumberToStartRound = playerNumber;
    while ([[self.playerEliminated objectAtIndex:self.playerNumberToStartRound] isEqualToNumber:[NSNumber numberWithBool:YES]])
        self.playerNumberToStartRound = (self.playerNumberToStartRound + 1) % self.numberOfPlayers;
}

- (void)doneShowingSecretWords
{
    self.gameStatus = GameStatusTheImpostorRemains;
}

+ (ImpostorGameModel *)game
{
    static ImpostorGameModel *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ImpostorGameModel alloc] init];
    });
    return sharedInstance;
}

@end



