//
//  LoginViewController.m
//  BopplExample
//
//  Created by Davide De Franceschi on 21/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *allTextFields;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UIView *loadingContentBackgroundView;

@end

@implementation LoginViewController

#pragma mark UIViewController

static CGFloat viewCornerRadius = 20.0;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.loadingContentBackgroundView.layer.cornerRadius = viewCornerRadius;
	[self checkLoginButtonEnabling];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == self.usernameTextField) {
		[self.passwordTextField becomeFirstResponder];
		return NO;
	} else if (textField == self.passwordTextField) {
		[self login];
	}
	return YES;
}

#pragma mark IBAction

- (IBAction)loginButtonPressed:(id)sender
{
	[self login];
}

- (IBAction)textFieldHasEditedText:(id)sender
{
	[self checkLoginButtonEnabling];
}

- (IBAction)handleTap:(UITapGestureRecognizer *)sender
{
	for (UITextField *textField in self.allTextFields) {
		[textField resignFirstResponder];
	}
}

#pragma mark LoginViewController

- (void)checkLoginButtonEnabling
{
	BOOL hasUsername = self.usernameTextField.text.length > 0;
	BOOL hasPassword = self.passwordTextField.text.length > 0;
	[self.loginButton setEnabled:hasUsername && hasPassword];
}

- (void)login
{
	for (UITextField *textField in self.allTextFields) {
		[textField resignFirstResponder];
	}
	
	[self showOrHideLoadingView:YES];
	self.server.account = [BasicHTTPAuthAccount accountWithUsername:self.usernameTextField.text andPassword:self.passwordTextField.text];
	[self.server authenticateAccountWithCompletion:^(BOOL authenticated, NSHTTPURLResponse *response, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self showOrHideLoadingView:NO];
			if (error != nil && !([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorUserCancelledAuthentication)) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alert show];
			} else if (!authenticated) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Credentials" message:@"Please login with valid credentials" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alert show];
			} else {
				[self.delegate loginViewControllerDidLogin:self];
			}
		});
	}];
}

#define VIEW_ANIMATION_DURATION 0.4
#define ALPHA_OPAQUE 1.0
#define ALPHA_TRANSPARENT 0.0

- (void)showOrHideLoadingView:(BOOL)show
{	
	[UIView animateWithDuration:VIEW_ANIMATION_DURATION animations:^{
		if (show) {
			self.loadingView.hidden = NO;
		}
		self.loadingView.alpha = (show)? ALPHA_OPAQUE : ALPHA_TRANSPARENT;
	} completion:^(BOOL finished) {
		if (!show) {
			self.loadingView.hidden = YES;
		}
	}];
}

@end
