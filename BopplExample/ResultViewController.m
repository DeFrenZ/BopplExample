//
//  ResultViewController.m
//  BopplExample
//
//  Created by Davide De Franceschi on 21/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "ResultViewController.h"

#define STATUS_BAR_HEIGHT 20.0
#define NAVIGATION_BAR_HEIGHT 64.0
#pragma mark -

@interface ResultViewController ()

@property (strong, nonatomic) IBOutlet UITextView *resultTextView;

@end

@implementation ResultViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.resultTextView.text = [self.resultObject description];
	self.resultTextView.textContainerInset = UIEdgeInsetsMake(-(STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT), 0, 0, 0);
}

@end
