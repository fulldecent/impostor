//
//  ImpostorGameModel_Tests.m
//  ImpostorGameModel Tests
//
//  Created by William Entriken on 10/5/14.
//  Copyright (c) 2014 William Entriken. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ImpostorGameModel.h"

@interface ImpostorGameModel_Tests : XCTestCase
@property ImpostorGameModel *gameModel;
@end

@implementation ImpostorGameModel_Tests

- (void)setUp {
    [super setUp];
    self.gameModel = [ImpostorGameModel game];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testStartGameWithSamePlayers {
    NSInteger numberOfPlayers = 5;
    [self.gameModel startGameWithNumberOfPlayers:numberOfPlayers];
    XCTAssertEqual(self.gameModel.numberOfPlayers, numberOfPlayers);
}

- (void)testGameStatusChangedWhenDoneShowingSecretWords {
    [self.gameModel startGameWithNumberOfPlayers:10];
    XCTAssertEqual(self.gameModel.gameStatus, GameStatusShowSecretWords);
    [self.gameModel doneShowingSecretWords];
    XCTAssertEqual(self.gameModel.gameStatus, GameStatusTheImpostorRemains);
}

- (void)testElimanateAPlayer {
    [self.gameModel startGameWithNumberOfPlayers:10];
    [self.gameModel doneShowingSecretWords];
    [self.gameModel eliminatePlayer:0];
    XCTAssertEqual(self.gameModel.playerEliminated[0], @YES);
    for (int i=1; i<10; i++) {
        XCTAssertEqual(self.gameModel.playerEliminated[i], @NO);
    }
}

@end
