//
//  SecretWordViewController.h
//  Impostor
//
//  Created by William Entriken on 12/14/13.
//  Copyright (c) 2013 William Entriken. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"

@interface SecretWordViewController : GAITrackedViewController
@property (nonatomic) NSInteger playerNumber;

#pragma mark - IB
@property (weak, nonatomic) IBOutlet UILabel *playerLabel;
@property (weak, nonatomic) IBOutlet UIImageView *playerImage;
@property (weak, nonatomic) IBOutlet UILabel *topSecretLabel;

- (IBAction)showSecretWord:(id)sender;
- (IBAction)stopGame:(id)sender;
@end
