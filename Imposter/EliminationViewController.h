//
//  EliminationViewController.h
//  Imposter
//
//  Created by William Entriken on 12/15/13.
//  Copyright (c) 2013 William Entriken. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EliminationViewController : UIViewController
@property (weak, nonatomic) IBOutlet UICollectionView *playerPhotoCollectionView;
- (IBAction)eliminatePlayer:(UIButton *)sender;

@end
