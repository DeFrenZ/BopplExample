//
//  ViewController.m
//  BopplExample
//
//  Created by Davide De Franceschi on 20/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "MainViewController.h"
#import "BopplServer.h"

@interface MainViewController ()

@property (strong, nonatomic) BopplServer *server;
@property (nonatomic) BOOL isAuthenticated;

@end

@implementation MainViewController

static NSString *loginViewControllerSegueIdentifier = @"LoginSegue";

#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.server = [BopplServer new];
	BopplAccount *savedAccount;
#warning TODO: try to load the account from the keychain
	if (savedAccount != nil) {
		self.server.account = savedAccount;
	}
	self.isAuthenticated = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (!self.isAuthenticated) {
		[self loginOrAskForCredentials];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	LoginViewController *destinationViewController = (LoginViewController *)[segue destinationViewController];
	destinationViewController.server = self.server;
	destinationViewController.delegate = self;
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[self performSegueWithIdentifier:loginViewControllerSegueIdentifier sender:self];
}

#pragma mark LoginViewControllerDelegate

- (void)loginViewControllerDidLogin:(LoginViewController *)controller
{
	self.isAuthenticated = YES;
	if (controller != nil) {
		[controller dismissViewControllerAnimated:YES completion:nil];
	}
	
	NSLog(@"Login successful!");
#warning TODO: application logic after login
}

#pragma mark MainViewController

- (void)loginOrAskForCredentials
{
	if (self.server.account == nil) {
		[self performSegueWithIdentifier:loginViewControllerSegueIdentifier sender:self];
	} else {
		[self.server authenticateAccountWithCompletion:^(BOOL authenticated, NSHTTPURLResponse *response, NSError *error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (error != nil) {
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
					[alert show];
				} else if (!authenticated) {
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Credentials" message:@"Please login with valid credentials" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
					[alert show];
				} else {
					[self loginViewControllerDidLogin:nil];
				}
			});
		}];
	}
}

@end
