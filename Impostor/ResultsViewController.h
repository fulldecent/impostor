//
//  ResultsViewController.h
//  Impostor
//
//  Created by William Entriken on 12/15/13.
//  Copyright (c) 2013 William Entriken. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"

@interface ResultsViewController : GAITrackedViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)playAgain:(id)sender;

@end
