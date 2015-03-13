//
//  TeaseViewController.m
//  Impostor
//
//  Created by William Entriken on 3/13/15.
//  Copyright (c) 2015 William Entriken. All rights reserved.
//

#import "TeaseViewController.h"

@interface TeaseViewController ()

@end

@implementation TeaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    bounceAnimation.values = @[@(0), @(M_PI*8)];
    bounceAnimation.duration = 3;
    bounceAnimation.removedOnCompletion = YES;
    bounceAnimation.repeatCount = 0;
    bounceAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.spy.layer addAnimation:bounceAnimation forKey:@"spin"];
    
    [self performSelector:@selector(close) withObject:self afterDelay:5];
}

- (void)close
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
