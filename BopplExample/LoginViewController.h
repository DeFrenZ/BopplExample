//
//  LoginViewController.h
//  BopplExample
//
//  Created by Davide De Franceschi on 21/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BopplServer.h"

@protocol LoginViewControllerDelegate;

#pragma mark -

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) BopplServer *server;
@property (weak, nonatomic) id<LoginViewControllerDelegate> delegate;

@end

#pragma mark -

@protocol LoginViewControllerDelegate <NSObject>

- (void)loginViewControllerDidLogin:(LoginViewController *)controller;

@end
