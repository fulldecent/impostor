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
    self.impostorWord = ((NSArray *)allWordSets[chosenWordSet])[chosenImpostorWord];
    self.normalWord = ((NSArray *)allWordSets[chosenWordSet])[1-chosenImpostorWord];
    
    for (int i=0; i<numPlayers; i++) {
        if (i == impostorIndex) {
            [roles addObject:@(PlayerRoleImpostor)];
            [words addObject:self.impostorWord];
        } else {
            [roles addObject:@(PlayerRoleNormalPlayer)];
            [words addObject:self.normalWord];
        }
        [self.playerEliminated addObject:@NO];
    }

    self.playerRoles = [roles copy];
    self.playerWords = [words copy];
    self.gameStatus = GameStatusShowSecretWords;
    self.playerNumberToStartRound = arc4random() % self.numberOfPlayers;
}

- (void)eliminatePlayer:(NSInteger)playerNumber
{
    if ([(NSNumber *)self.playerEliminated[playerNumber] boolValue])
        NSLog(@"ERROR eliminating player that is already eliminated");
    self.playerEliminated[playerNumber] = @YES;
    
    int countOfRemainingImpostors = 0;
    int countOfRemainingNormalPlayers = 0;
    for (int i=0; i<self.numberOfPlayers; i++) {
        if ([(NSNumber *)self.playerEliminated[i] boolValue])
            continue;
        switch ([(NSNumber *)self.playerRoles[i] intValue]) {
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
    while ([(NSNumber *)self.playerEliminated[self.playerNumberToStartRound] boolValue])
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



