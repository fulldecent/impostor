//
//  AppDelegate.m
//  Impostor
//
//  Created by William Entriken on 12/14/13.
//  Copyright (c) 2013 William Entriken. All rights reserved.
//

#import "AppDelegate.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import <Appirater.h>

@interface AppDelegate() <AppiraterDelegate>
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-52764-17"];
    
#if TARGET_IPHONE_SIMULATOR
    [[GAI sharedInstance] setDryRun:YES];
#endif
    
    [Appirater setAppId:@"784258202"];
    [Appirater setDaysUntilPrompt:12];
    [Appirater setUsesUntilPrompt:6];
    [Appirater setSignificantEventsUntilPrompt:6];
    [Appirater setTimeBeforeReminding:6];
    [Appirater appLaunched:YES];
    [Appirater setDelegate:self];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - AppiraterDelegate

- (void)appiraterDidDisplayAlert:(Appirater *)appirater
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Appirater"
                                                          action:@"DisplayAlert"
                                                           label:@"done"
                                                           value:@1] build]];
}

- (void)appiraterDidDeclineToRate:(Appirater *)appirater
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Appirater"
                                                          action:@"DeclineToRate"
                                                           label:@"done"
                                                           value:@1] build]];
}

- (void)appiraterDidOptToRate:(Appirater *)appirater
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Appirater"
                                                          action:@"OptToRate"
                                                           label:@"done"
                                                           value:@1] build]];
}

- (void)appiraterDidOptToRemindLater:(Appirater *)appirater
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Appirater"
                                                          action:@"OptToRemindLater"
                                                           label:@"done"
                                                           value:@1] build]];
}

- (void)appiraterWillPresentModalView:(Appirater *)appirater animated:(BOOL)animated
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Appirater"
                                                          action:@"WillPresentModalView"
                                                           label:@"done"
                                                           value:@1] build]];
}

- (void)appiraterDidDismissModalView:(Appirater *)appirater animated:(BOOL)animated
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Appirater"
                                                          action:@"DidDismissModalView"
                                                           label:@"done"
                                                           value:@1] build]];
}

@end
