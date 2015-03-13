//
//  CollageViewController.h
//  Impostor
//
//  Created by William Entriken on 2/19/14.
//  Copyright (c) 2014 William Entriken. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"

@interface CollageViewController : GAITrackedViewController
@property (weak, nonatomic) IBOutlet UICollectionView *playerPhotoCollectionView;
- (IBAction)wantToShare;
- (IBAction)returnToMainScreen;
@end
