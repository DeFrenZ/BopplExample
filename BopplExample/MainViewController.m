//
//  ViewController.m
//  BopplExample
//
//  Created by Davide De Franceschi on 20/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "MainViewController.h"
#import "ResultViewController.h"
#import "BopplServer.h"

@interface MainViewController ()

@property (strong, nonatomic) BopplServer *server;
@property (nonatomic) BOOL isAuthenticated;
@property (strong, nonatomic) NSArray *APICallsNames;
@property (strong, nonatomic) id<NSObject> lastAPIResult;

@property (strong, nonatomic) IBOutlet UIPickerView *APICallsNamesPickerView;

@end

@implementation MainViewController

static NSString *loginViewControllerSegueIdentifier = @"LoginSegue";
static NSString *resultViewControllerSegueIdentifier = @"ResultSegue";

#pragma mark UIViewController

static NSString *APICallNameGetModifierCategoriesForVenue = @"Get Modifier Categories for Venue";

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
	self.APICallsNames = @[APICallNameGetModifierCategoriesForVenue];
	[self.APICallsNamesPickerView selectRow:0 inComponent:0 animated:NO];
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
	if ([segue.identifier isEqualToString:loginViewControllerSegueIdentifier]) {
		LoginViewController *destinationViewController = (LoginViewController *)segue.destinationViewController;
		destinationViewController.server = self.server;
		destinationViewController.delegate = self;
	} else if ([segue.identifier isEqualToString:resultViewControllerSegueIdentifier]) {
		ResultViewController *destinationViewController = (ResultViewController *)segue.destinationViewController;
		destinationViewController.resultObject = self.lastAPIResult;
	}
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[self performSegueWithIdentifier:loginViewControllerSegueIdentifier sender:self];
}

#pragma mark UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 30;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	return pickerView.frame.size.width;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return self.APICallsNames[row];
}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return self.APICallsNames.count;
}

#pragma mark LoginViewControllerDelegate

- (void)loginViewControllerDidLogin:(LoginViewController *)controller
{
	self.isAuthenticated = YES;
	if (controller != nil) {
		[controller dismissViewControllerAnimated:YES completion:nil];
	}
	
	NSLog(@"Login successful!");
}

#pragma mark IBAction

- (IBAction)callAPIButtonPressed:(id)sender
{
	NSString *selectedAPICallName = self.APICallsNames[[self.APICallsNamesPickerView selectedRowInComponent:0]];
	if ([selectedAPICallName isEqualToString:APICallNameGetModifierCategoriesForVenue]) {
		[self.server getModifierCategoriesForVenue:4 completion:^(NSArray *modifierCategories, NSHTTPURLResponse *response, NSError *error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (error != nil) {
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"API Call Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
					[alert show];
				} else {
					self.lastAPIResult = modifierCategories;
					[self performSegueWithIdentifier:resultViewControllerSegueIdentifier sender:self];
				}
			});
		}];
	}
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
