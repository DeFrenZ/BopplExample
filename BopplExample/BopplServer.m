//
//  BopplServer.m
//  BopplExample
//
//  Created by Davide De Franceschi on 20/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "BopplServer.h"

@interface BopplServer ()

- (void)callBopplServiceAtURL:(NSURL *)serviceURL completion:(void (^)(NSArray *JSONCollection, NSHTTPURLResponse *response, NSError *error))completion;

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

+ (NSArray *)arrayByConvertingItemsOfArray:(NSArray *)itemArray toClass:(Class)itemClass
{
	NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:itemArray.count];
	for (NSDictionary *itemDictionary in itemArray) {
		[tempArray addObject:[[itemClass alloc] initWithDictionary:itemDictionary]];
	}
	return [NSArray arrayWithArray:tempArray];
}

static NSString *HTTPHeaderFieldAuthorization = @"Authorization";

- (void)callBopplServiceAtURL:(NSURL *)serviceURL completion:(void (^)(NSArray *, NSHTTPURLResponse *, NSError *))completion
{
	if (self.account == nil) {
		NSLog(@"Cannot use API without specifing an account.");
		completion(nil, nil, nil);
		return;
	}
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:serviceURL];
	[request setValue:[NSString stringWithFormat:@"Basic %@", [self.account encodedAuthorizationString]] forHTTPHeaderField:HTTPHeaderFieldAuthorization];
	
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
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
						NSArray *responseCollection = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&JSONError];
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

- (void)callAPIWithCallName:(NSString *)APICallName withVenueID:(NSInteger)venueID completion:(void (^)(NSArray *, NSHTTPURLResponse *, NSError *))completion
{
	if ([APICallName isEqualToString:BopplAPICallNameGetModifierCategoriesForVenue]) {
		[self getModifierCategoriesForVenueID:venueID completion:completion];
	} else if ([APICallName isEqualToString:BopplAPICallNameGetModifiersForVenue]) {
		[self getModifiersForVenueID:venueID completion:completion];
	} else if ([APICallName isEqualToString:BopplAPICallNameGetProductCategoriesForVenue]) {
		[self getProductCategoriesForVenueID:venueID completion:completion];
	} else if ([APICallName isEqualToString:BopplAPICallNameGetProductGroupsForVenue]) {
		[self getProductGroupsForVenueID:venueID completion:completion];
	} else if ([APICallName isEqualToString:BopplAPICallNameGetProductsForVenue]) {
		[self getProductsForVenueID:venueID completion:completion];
	} else if ([APICallName isEqualToString:BopplAPICallNameGetProductWithIDForVenue] || [APICallName isEqualToString:BopplAPICallNameGetProductsByCategoryForVenue] || [APICallName isEqualToString:BopplAPICallNameGetProductsByGroupForVenue]) {
		NSLog(@"Trying to call API with name %@ missing a parameter.", APICallName);
		completion(nil, nil, nil);
	} else {
		NSLog(@"Trying to call API with invalid name %@.", APICallName);
		completion(nil, nil, nil);
	}
}

- (void)callAPIWithCallName:(NSString *)APICallName withVenueID:(NSInteger)venueID otherID:(NSInteger)otherID completion:(void (^)(NSArray *, NSHTTPURLResponse *, NSError *))completion
{
	if ([APICallName isEqualToString:BopplAPICallNameGetProductWithIDForVenue]) {
		[self getProductForVenueID:venueID withProductID:otherID completion:^(BopplProduct *product, NSHTTPURLResponse *response, NSError *error) {
			completion((product == nil)? nil : @[product], response, error);
		}];
	} else if ([APICallName isEqualToString:BopplAPICallNameGetProductsByCategoryForVenue]) {
		[self getProductsForVenueID:venueID withCategoryID:otherID completion:completion];
	} else if ([APICallName isEqualToString:BopplAPICallNameGetProductsByGroupForVenue]) {
		[self getProductsForVenueID:venueID withGroupID:otherID completion:completion];
	} else {
		[self callAPIWithCallName:APICallName withVenueID:venueID completion:completion];
	}
}

- (void)authenticateAccountWithCompletion:(void (^)(BOOL, NSHTTPURLResponse *, NSError *))completion
{
	NSURL *serviceURL = [[self class] getProductURLWithVenueID:0 andProductID:0];
	[self callBopplServiceAtURL:serviceURL completion:^(NSArray *JSONCollection, NSHTTPURLResponse *response, NSError *error) {
		completion(JSONCollection != nil, response, error);
	}];
}

- (void)getModifierCategoriesForVenueID:(NSInteger)venueID completion:(void (^)(NSArray *, NSHTTPURLResponse *, NSError *))completion
{
	NSURL *serviceURL = [[self class] getModifierCategoriesURLWithVenueID:venueID];
	[self callBopplServiceAtURL:serviceURL completion:^(NSArray *JSONCollection, NSHTTPURLResponse *response, NSError *error) {
		NSArray *convertedArray = [[self class] arrayByConvertingItemsOfArray:JSONCollection toClass:[BopplProductModifierCategory class]];
		completion(convertedArray, response, error);
	}];
}

- (void)getModifiersForVenueID:(NSInteger)venueID completion:(void (^)(NSArray *, NSHTTPURLResponse *, NSError *))completion
{
	NSURL *serviceURL = [[self class] getModifiersURLWithVenueID:venueID];
	[self callBopplServiceAtURL:serviceURL completion:^(NSArray *JSONCollection, NSHTTPURLResponse *response, NSError *error) {
		NSArray *convertedArray = [[self class] arrayByConvertingItemsOfArray:JSONCollection toClass:[BopplProductModifier class]];
		completion(convertedArray, response, error);
	}];
}

- (void)getProductForVenueID:(NSInteger)venueID withProductID:(NSInteger)productID completion:(void (^)(BopplProduct *, NSHTTPURLResponse *, NSError *))completion
{
	NSURL *serviceURL = [[self class] getProductURLWithVenueID:venueID andProductID:productID];
	[self callBopplServiceAtURL:serviceURL completion:^(NSArray *JSONCollection, NSHTTPURLResponse *response, NSError *error) {
		if (JSONCollection.count > 1) {
			NSLog(@"Returned more than 1 %@ with a call to %s.", [BopplProduct class], __PRETTY_FUNCTION__);
		} else if (JSONCollection.count == 0) {
			completion(nil, response, error);
		} else {
			completion([BopplProduct productWithDictionary:JSONCollection[0]], response, error);
		}
	}];
}

- (void)getProductCategoriesForVenueID:(NSInteger)venueID completion:(void (^)(NSArray *, NSHTTPURLResponse *, NSError *))completion
{
	NSURL *serviceURL = [[self class] getProductCategoriesURLWithVenueID:venueID];
	[self callBopplServiceAtURL:serviceURL completion:^(NSArray *JSONCollection, NSHTTPURLResponse *response, NSError *error) {
		NSArray *convertedArray = [[self class] arrayByConvertingItemsOfArray:JSONCollection toClass:[BopplProductCategory class]];
		completion(convertedArray, response, error);
	}];
}

- (void)getProductGroupsForVenueID:(NSInteger)venueID completion:(void (^)(NSArray *, NSHTTPURLResponse *, NSError *))completion
{
	NSURL *serviceURL = [[self class] getProductGroupsURLWithVenueID:venueID];
	[self callBopplServiceAtURL:serviceURL completion:^(NSArray *JSONCollection, NSHTTPURLResponse *response, NSError *error) {
		NSArray *convertedArray = [[self class] arrayByConvertingItemsOfArray:JSONCollection toClass:[BopplProductGroup class]];
		completion(convertedArray, response, error);
	}];
}

- (void)getProductsForVenueID:(NSInteger)venueID completion:(void (^)(NSArray *, NSHTTPURLResponse *, NSError *))completion
{
	NSURL *serviceURL = [[self class] getProductsURLWithVenueID:venueID];
	[self callBopplServiceAtURL:serviceURL completion:^(NSArray *JSONCollection, NSHTTPURLResponse *response, NSError *error) {
		NSArray *convertedArray = [[self class] arrayByConvertingItemsOfArray:JSONCollection toClass:[BopplProduct class]];
		completion(convertedArray, response, error);
	}];
}

- (void)getProductsForVenueID:(NSInteger)venueID withCategoryID:(NSInteger)categoryID completion:(void (^)(NSArray *, NSHTTPURLResponse *, NSError *))completion
{
	NSURL *serviceURL = [[self class] getProductsByCategoryURLWithVenueID:venueID andCategoryID:categoryID];
	[self callBopplServiceAtURL:serviceURL completion:^(NSArray *JSONCollection, NSHTTPURLResponse *response, NSError *error) {
		NSArray *convertedArray = [[self class] arrayByConvertingItemsOfArray:JSONCollection toClass:[BopplProduct class]];
		completion(convertedArray, response, error);
	}];
}

- (void)getProductsForVenueID:(NSInteger)venueID withGroupID:(NSInteger)groupID completion:(void (^)(NSArray *, NSHTTPURLResponse *, NSError *))completion
{
	NSURL *serviceURL = [[self class] getProductsByGroupURLWithVenueID:venueID andGroupID:groupID];
	[self callBopplServiceAtURL:serviceURL completion:^(NSArray *JSONCollection, NSHTTPURLResponse *response, NSError *error) {
		NSArray *convertedArray = [[self class] arrayByConvertingItemsOfArray:JSONCollection toClass:[BopplProduct class]];
		completion(convertedArray, response, error);
	}];
}

@end

#pragma mark -

@implementation BopplFakeServer

- (void)callBopplServiceAtURL:(NSURL *)serviceURL completion:(void (^)(NSArray *, NSHTTPURLResponse *, NSError *))completion
{
	if (self.account == nil) {
		NSLog(@"Cannot use API without specifing an account.");
		completion(nil, nil, nil);
		return;
	}
	
	if (![self.account isEqualToAccount:[BasicHTTPAuthAccount accountWithUsername:@"defrenz@gmail.com" andPassword:@"password123"]]) {
		NSLog(@"Cannot use API on Fake Server with an account different from defrenz@gmail.com:password123");
		completion(nil, [[NSHTTPURLResponse alloc] initWithURL:serviceURL statusCode:401 HTTPVersion:@"HTTP/1.1" headerFields:nil], nil);
		return;
	}
	
	NSArray *URLComponents = [serviceURL.absoluteString componentsSeparatedByString:@"/"];
	NSUInteger venueIDIndex = 1 + [URLComponents indexOfObject:@"venues"];
	NSUInteger venueID = [URLComponents[venueIDIndex] integerValue];
	NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:serviceURL statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:nil];
	id JSONCollection;
	if ([serviceURL isEqual:[[self class] getModifierCategoriesURLWithVenueID:venueID]]) {
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
#warning TODO: fake return data on all API calls
	completion(JSONCollection, response, nil);
}

- (void)authenticateAccountWithCompletion:(void (^)(BOOL, NSHTTPURLResponse *, NSError *))completion
{
	if (![self.account isEqualToAccount:[BasicHTTPAuthAccount accountWithUsername:@"defrenz@gmail.com" andPassword:@"password123"]]) {
		NSLog(@"Cannot use API on Fake Server with an account different from defrenz@gmail.com:password123");
		completion(NO, nil, nil);
		return;
	}
	
	completion(YES, nil, nil);
}

@end
