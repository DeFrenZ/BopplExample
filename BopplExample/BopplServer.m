//
//  BopplServer.m
//  BopplExample
//
//  Created by Davide De Franceschi on 20/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "BopplServer.h"

@interface BopplServer ()

- (void)callBopplServiceAtURL:(NSURL *)serviceURL completion:(void (^)(id JSONCollection, NSHTTPURLResponse *response, NSError *error))completion;

@end

@implementation BopplServer

#pragma mark Boppl Service URLs

static NSString *baseAPIURL = @"https://services-sandbox.boppl.me/api/v0.0.3";

+ (NSURL *)getModifierCategoriesURLWithVenueID:(NSInteger)venueID
{
	return [NSURL URLWithString:[NSString stringWithFormat:@"%@/venues/%d/categories/modifier", baseAPIURL, venueID]];
}

+ (NSURL *)getModifiersURLWithVenueID:(NSInteger)venueID
{
	return [NSURL URLWithString:[NSString stringWithFormat:@"%@/venues/%d/modifier", baseAPIURL, venueID]];
}

+ (NSURL *)getProductURLWithVenueID:(NSInteger)venueID andProductID:(NSInteger)productID
{
	return [NSURL URLWithString:[NSString stringWithFormat:@"%@/venues/%d/products/%d", baseAPIURL, venueID, productID]];
}

+ (NSURL *)getProductCategoriesURLWithVenueID:(NSInteger)venueID
{
	return [NSURL URLWithString:[NSString stringWithFormat:@"%@/venues/%d/categories/product", baseAPIURL, venueID]];
}

+ (NSURL *)getProductGroupsURLWithVenueID:(NSInteger)venueID
{
	return [NSURL URLWithString:[NSString stringWithFormat:@"%@/venues/%d/groups/product", baseAPIURL, venueID]];
}

+ (NSURL *)getProductsURLWithVenueID:(NSInteger)venueID
{
	return [NSURL URLWithString:[NSString stringWithFormat:@"%@/venues/%d/products", baseAPIURL, venueID]];
}

+ (NSURL *)getProductsByCategoryURLWithVenueID:(NSInteger)venueID andCategoryID:(NSInteger)categoryID
{
	return [NSURL URLWithString:[NSString stringWithFormat:@"%@/venues/%d/products/category/%d", baseAPIURL, venueID, categoryID]];
}

+ (NSURL *)getProductsByGroupURLWithVenueID:(NSInteger)venueID andGroupID:(NSInteger)groupID
{
	return [NSURL URLWithString:[NSString stringWithFormat:@"%@/venues/%d/products/group/%d", baseAPIURL, venueID, groupID]];
}

#pragma mark Boppl Service utilities

static NSString *HTTPHeaderFieldAuthorization = @"Authorization";

- (void)callBopplServiceAtURL:(NSURL *)serviceURL completion:(void (^)(id, NSHTTPURLResponse *, NSError *))completion
{
	if (self.account == nil) {
		NSLog(@"Cannot use API without specifing an account.");
		completion(nil, nil, nil);
		return;
	}
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:serviceURL];
	[request setValue:[NSString stringWithFormat:@"Basic %@", [self.account encodedAuthorizationString]] forHTTPHeaderField:HTTPHeaderFieldAuthorization];
	
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
		NSLog(@"Received response from API Call.");
		if (connectionError != nil) {
			NSLog(@"Connection Error in service call: %@.", [connectionError localizedDescription]);
			completion(nil, nil, connectionError);
		} else {
			if (response == nil || ![response isKindOfClass:[NSHTTPURLResponse class]]) {
				NSLog(@"API URLResponse is nil or not an NSHTTPURLResponse.");
				completion(nil, nil, nil);
			} else {
				NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
				if ([HTTPResponse statusCode] != 200) {
					NSLog(@"API response status code = %d.", [HTTPResponse statusCode]);
					completion(nil, HTTPResponse, nil);
				} else {
					if (data == nil || data.length == 0) {
						NSLog(@"Response data is nil or empty.");
						completion(nil, HTTPResponse, nil);
					} else {
						NSError *JSONError;
						id responseCollection = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&JSONError];
						if (JSONError != nil) {
							NSLog(@"Error in parsing JSON data of %d bytes. %@.", data.length, [JSONError localizedDescription]);
							completion(nil, HTTPResponse, JSONError);
						} else {
							completion(responseCollection, HTTPResponse, nil);
						}
					}
				}
			}
		}
	}];
}

#pragma mark Boppl Service calls

static NSUInteger defaultVenueID = 4;

- (void)authenticateAccountWithCompletion:(void (^)(BOOL, NSHTTPURLResponse *, NSError *))completion
{
	NSURL *serviceURL = [[self class] getModifierCategoriesURLWithVenueID:defaultVenueID];
	[self callBopplServiceAtURL:serviceURL completion:^(id JSONCollection, NSHTTPURLResponse *response, NSError *error) {
		NSLog(@"Call to %s returned JSON object: %@.", __PRETTY_FUNCTION__, JSONCollection);
		completion(JSONCollection != nil, response, error);
	}];
}

- (void)getModifierCategoriesForVenue:(NSInteger)venueID completion:(void (^)(NSArray *, NSHTTPURLResponse *, NSError *))completion
{
	NSURL *serviceURL = [[self class] getModifierCategoriesURLWithVenueID:venueID];
	[self callBopplServiceAtURL:serviceURL completion:^(id JSONCollection, NSHTTPURLResponse *response, NSError *error) {
		NSLog(@"Call to %s returned JSON object: %@.", __PRETTY_FUNCTION__, JSONCollection);
	}];
}

@end

#pragma mark -

@implementation BopplFakeServer

- (void)callBopplServiceAtURL:(NSURL *)serviceURL completion:(void (^)(id, NSHTTPURLResponse *, NSError *))completion
{
	if (self.account == nil) {
		NSLog(@"Cannot use API without specifing an account.");
		completion(nil, nil, nil);
		return;
	}
	
	if (![self.account isEqualToAccount:[BopplAccount accountWithUsername:@"defrenz@gmail.com" andPassword:@"password123"]]) {
		NSLog(@"Cannot use API on Fake Server with an account different from defrenz@gmail.com:password123");
		completion(nil, [[NSHTTPURLResponse alloc] initWithURL:serviceURL statusCode:401 HTTPVersion:@"HTTP/1.1" headerFields:nil], nil);
		return;
	}
	
#warning make check work for any venueID
	NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:serviceURL statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:nil];
	id JSONCollection;
	if ([serviceURL isEqual:[[self class] getModifierCategoriesURLWithVenueID:defaultVenueID]]) {
		JSONCollection = @[@{@"id": @1,
							 @"category_desc": @"Sizes",
							 @"override_price": @YES,
							 @"mandatory_select": @YES,
							 @"multi_select": @NO,
							 @"sort_order": @0,
							 @"active": @YES,
							 @"product_modifiers": @[]},
						   @{@"id": @2,
							 @"category_desc": @"Mixers",
							 @"override_price": @NO,
							 @"mandatory_select": @YES,
							 @"multi_select": @NO,
							 @"sort_order": @1,
							 @"active": @YES,
							 @"product_modifiers": @[]}];
	}
	completion(JSONCollection, response, nil);
}

@end
