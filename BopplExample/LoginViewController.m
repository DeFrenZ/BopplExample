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
@property (strong, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation LoginViewController

#pragma mark UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.loginButton setEnabled:NO];
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

#pragma mark LoginViewController

- (void)checkLoginButtonEnabling
{
	BOOL hasUsername = self.usernameTextField.text.length > 0;
	BOOL hasPassword = self.passwordTextField.text.length > 0;
	[self.loginButton setEnabled:hasUsername && hasPassword];
}

- (void)login
{
#warning TODO: add UIActivityIndicatorView
#warning IMPROVE: avoid code repetition with MainViewController's -loginOrAskForCredentials
	self.server.account = [BopplAccount accountWithUsername:self.usernameTextField.text andPassword:self.passwordTextField.text];
	[self.server authenticateAccountWithCompletion:^(BOOL authenticated, NSHTTPURLResponse *response, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (error != nil) {
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

@end
