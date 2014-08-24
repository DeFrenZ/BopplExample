//
//  ViewController.m
//  BopplExample
//
//  Created by Davide De Franceschi on 20/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "MainViewController.h"
#import "ProductListViewController.h"
#import "ProductDetailViewController.h"
#import "BopplServer.h"

#pragma mark -

@interface MainViewController ()

@property (strong, nonatomic) BopplServer *server;
@property (strong, nonatomic) WebImageDownloader *downloader;
@property (nonatomic) BOOL isAuthenticated;
@property (strong, nonatomic) NSArray *APICallsNames;

@property (strong, nonatomic) IBOutlet UITextField *venueIDTextField;
@property (strong, nonatomic) IBOutlet UITextField *productIDTextField;
@property (strong, nonatomic) IBOutlet UITextField *categoryIDTextField;
@property (strong, nonatomic) IBOutlet UITextField *groupIDTextField;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *otherIDTextFields;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *allTextFields;
@property (strong, nonatomic) IBOutlet UIView *productIDSelectionView;
@property (strong, nonatomic) IBOutlet UIView *categoryIDSelectionView;
@property (strong, nonatomic) IBOutlet UIView *groupIDSelectionView;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *otherIDSelectionViews;
@property (strong, nonatomic) IBOutlet UIPickerView *APICallsNamesPickerView;
@property (strong, nonatomic) IBOutlet UIButton *callAPIButton;

@end

@implementation MainViewController

#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.server = [BopplServer new];
	self.downloader = [WebImageDownloader new];
	BasicHTTPAuthAccount *savedAccount;
#warning TODO: try to load the account from the keychain
	if (savedAccount != nil) {
		self.server.account = savedAccount;
	}
	self.isAuthenticated = NO;
	self.APICallsNames = @[BopplAPICallNameGetProductsForVenue, BopplAPICallNameGetProductsByCategoryForVenue, BopplAPICallNameGetProductsByGroupForVenue, BopplAPICallNameGetProductWithIDForVenue];
	[self.APICallsNamesPickerView selectRow:0 inComponent:0 animated:NO];
	
	[self checkCallAPIButtonEnabling];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (!self.isAuthenticated) {
		[self loginOrAskForCredentials];
	}
}

static NSString *loginViewControllerSegueIdentifier = @"LoginSegue";
static NSString *productListViewControllerSegueIdentifier = @"ProductListSegue";
static NSString *productDetailViewControllerSegueIdentifier = @"ProductDetailSegue";

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:loginViewControllerSegueIdentifier]) {
		LoginViewController *destinationViewController = (LoginViewController *)segue.destinationViewController;
		destinationViewController.server = self.server;
		destinationViewController.delegate = self;
	} else if ([segue.identifier isEqualToString:productListViewControllerSegueIdentifier]) {
		ProductListViewController *destinationViewController = (ProductListViewController *)segue.destinationViewController;
		destinationViewController.server = self.server;
		destinationViewController.downloader = self.downloader;
		destinationViewController.productList = (NSArray *)sender;
	} else if ([segue.identifier isEqualToString:productDetailViewControllerSegueIdentifier]) {
		ProductDetailViewController *destinationViewController = (ProductDetailViewController *)segue.destinationViewController;
		destinationViewController.downloader = self.downloader;
		destinationViewController.product = (BopplProduct *)sender;
	} else {
		NSLog(@"Preparing for Segue with invalid identifier: %@.", segue.identifier);
	}
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[self performSegueWithIdentifier:loginViewControllerSegueIdentifier sender:self];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	UITextField *selectedOtherIDTextField = [self selectedOtherIDTextField];
	if (textField == self.venueIDTextField) {
		if (selectedOtherIDTextField) {
			[selectedOtherIDTextField becomeFirstResponder];
			return NO;
		}
	} else if (textField != selectedOtherIDTextField) {
		return YES;
	}
	
	if ([self shouldCallAPIButtonBeEnabled]) {
		[self callAPIButtonPressed:nil];
	}
	return YES;
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

#define VIEW_ANIMATION_DURATION 0.4

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	UITextField *selectedTextField = [self selectedOtherIDTextField];
	UIView *selectionView = [self selectionViewOfTextField:selectedTextField];
	[UIView animateWithDuration:VIEW_ANIMATION_DURATION animations:^{
		for (UIView *view in self.otherIDSelectionViews) {
			[view setHidden:YES];
			[view setUserInteractionEnabled:NO];
		}
		for (UITextField *textField in self.otherIDTextFields) {
			[textField resignFirstResponder];
		}
		
		[selectionView setHidden:NO];
	} completion:^(BOOL finished) {
		[selectionView setUserInteractionEnabled:YES];
	}];
	
	[self.venueIDTextField setReturnKeyType:(selectedTextField != nil)? UIReturnKeyNext : UIReturnKeySend];
	[self checkCallAPIButtonEnabling];
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
}

#pragma mark IBAction

- (IBAction)callAPIButtonPressed:(id)sender
{
	for (UITextField *textField in self.allTextFields) {
		[textField resignFirstResponder];
	}
	
	NSString *selectedAPICallName = self.APICallsNames[[self.APICallsNamesPickerView selectedRowInComponent:0]];
	[self.server callAPIWithCallName:selectedAPICallName withVenueID:[self selectedVenueID] otherID:[self selectedOtherID] completion:^(NSArray *result, NSHTTPURLResponse *response, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (error != nil) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"API Call Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alert show];
			} else if (result.count == 0) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Products" message:@"There were no items found with the selected parameters" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alert show];
			} else {
				if ([selectedAPICallName isEqualToString:BopplAPICallNameGetProductWithIDForVenue]) {
					[self performSegueWithIdentifier:productDetailViewControllerSegueIdentifier sender:result[0]];
				} else {
					[self performSegueWithIdentifier:productListViewControllerSegueIdentifier sender:result];
				}
			}
		});
	}];
}

- (IBAction)textFieldHasEditedText:(id)sender
{
	[self checkCallAPIButtonEnabling];
}

- (IBAction)handleTap:(UITapGestureRecognizer *)sender
{
	if (sender.state == UIGestureRecognizerStateEnded) {
		for (UITextField *textField in self.allTextFields) {
			[textField resignFirstResponder];
		}
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

- (NSString *)selectedAPICallName
{
	return self.APICallsNames[[self.APICallsNamesPickerView selectedRowInComponent:0]];
}

- (UITextField *)selectedOtherIDTextField
{
	NSString *selectedAPICallName = [self selectedAPICallName];
	if ([selectedAPICallName isEqualToString:BopplAPICallNameGetProductWithIDForVenue]) {
		return self.productIDTextField;
	} else if ([selectedAPICallName isEqualToString:BopplAPICallNameGetProductsByCategoryForVenue]) {
		return self.categoryIDTextField;
	} else if ([selectedAPICallName isEqualToString:BopplAPICallNameGetProductsByGroupForVenue]) {
		return self.groupIDTextField;
	}
	return nil;
}

- (UIView *)selectionViewOfTextField:(UITextField *)textField
{
	if (textField == self.productIDTextField) {
		return self.productIDSelectionView;
	} else if (textField == self.categoryIDTextField) {
		return self.categoryIDSelectionView;
	} else if (textField == self.groupIDTextField) {
		return self.groupIDSelectionView;
	}
	return nil;
}

- (BOOL)shouldCallAPIButtonBeEnabled
{
	if ([self selectedVenueID] == NSNotFound) {
		return NO;
	}
	
	UITextField *selectedTextField = [self selectedOtherIDTextField];
	if (selectedTextField == nil || [self selectedOtherID] != NSNotFound) {
		return YES;
	}
	return NO;
}

- (void)checkCallAPIButtonEnabling
{
	[self.callAPIButton setEnabled:[self shouldCallAPIButtonBeEnabled]];
}

- (NSInteger)selectedVenueID
{
	if (self.venueIDTextField.text != nil && self.venueIDTextField.text.length > 0) {
		return [self.venueIDTextField.text integerValue];
	}
	return NSNotFound;
}

- (NSInteger)selectedOtherID
{
	UITextField *selectedTextField = [self selectedOtherIDTextField];
	if (selectedTextField != nil && selectedTextField.text != nil && selectedTextField.text.length > 0) {
		return [selectedTextField.text integerValue];
	}
	return NSNotFound;
}

@end
