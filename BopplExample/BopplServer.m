//
//  BopplServer.m
//  BopplExample
//
//  Created by Davide De Franceschi on 20/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "BopplServer.h"

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

#pragma mark Boppl Service calls

- (void)authenticateUsername:(NSString *)username withPassword:(NSString *)password
{
	// TODO: write
}

- (void)getModifierCategoriesForVenue:(NSInteger)venueID
{
	if (self.account == nil) {
		NSLog(@"Cannot use API without specifing an account.");
		return;
	}
	
	NSURL *serviceURL = [[self class] getModifierCategoriesURLWithVenueID:venueID];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:serviceURL];]
	// TODO: complete
}

@end
