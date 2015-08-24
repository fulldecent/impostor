//
//  AppDelegate.m
//  Impostor
//
//  Created by William Entriken on 12/14/13.
//  Copyright (c) 2013 William Entriken. All rights reserved.
//

#import "AppDelegate.h"
#import <Appirater.h>
#import <Google/Analytics.h>

@interface AppDelegate() <AppiraterDelegate>
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);

    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions

#if TARGET_IPHONE_SIMULATOR
    gai.dryRun = YES;
#endif
        
    [Appirater setAppId:@"784258202"];
    [Appirater setDaysUntilPrompt:5];
    [Appirater setUsesUntilPrompt:5];
    [Appirater setSignificantEventsUntilPrompt:5];
    [Appirater setTimeBeforeReminding:5];
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
