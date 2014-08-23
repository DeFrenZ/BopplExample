//
//  BopplServer.h
//  BopplExample
//
//  Created by Davide De Franceschi on 20/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicHTTPAuthAccount.h"
#import "BopplJSONObjects.h"

static NSString *BopplAPICallNameGetModifierCategoriesForVenue = @"Get Modifier Categories for Venue";
static NSString *BopplAPICallNameGetModifiersForVenue = @"Get Modifiers for Venue";
static NSString *BopplAPICallNameGetProductWithIDForVenue = @"Get Product with identifier for Venue";
static NSString *BopplAPICallNameGetProductCategoriesForVenue = @"Get Product Categories for Venue";
static NSString *BopplAPICallNameGetProductGroupsForVenue = @"Get Product Groups for Venue";
static NSString *BopplAPICallNameGetProductsForVenue = @"Get Products for Venue";
static NSString *BopplAPICallNameGetProductsByCategoryForVenue = @"Get Products by Category for Venue";
static NSString *BopplAPICallNameGetProductsByGroupForVenue = @"Get Products by Group for Venue";

@interface BopplServer : NSObject

@property (strong, nonatomic) BasicHTTPAuthAccount *account;

- (void)callAPIWithCallName:(NSString *)APICallName withVenueID:(NSInteger)venueID completion:(void (^)(NSArray *result, NSHTTPURLResponse *response, NSError *error))completion;
- (void)callAPIWithCallName:(NSString *)APICallName withVenueID:(NSInteger)venueID otherID:(NSInteger)otherID completion:(void (^)(NSArray *result, NSHTTPURLResponse *response, NSError *error))completion;

- (void)authenticateAccountWithCompletion:(void (^)(BOOL authenticated, NSHTTPURLResponse *response, NSError *error))completion;

- (void)getModifierCategoriesForVenueID:(NSInteger)venueID completion:(void (^)(NSArray *modifierCategories, NSHTTPURLResponse *response, NSError *error))completion;
- (void)getModifiersForVenueID:(NSInteger)venueID completion:(void (^)(NSArray *modifiers, NSHTTPURLResponse *response, NSError *error))completion;
- (void)getProductForVenueID:(NSInteger)venueID withProductID:(NSInteger)productID completion:(void (^)(BopplProduct *product, NSHTTPURLResponse *response, NSError *error))completion;
- (void)getProductCategoriesForVenueID:(NSInteger)venueID completion:(void (^)(NSArray *productCategories, NSHTTPURLResponse *response, NSError *error))completion;
- (void)getProductGroupsForVenueID:(NSInteger)venueID completion:(void (^)(NSArray *productGroups, NSHTTPURLResponse *response, NSError *error))completion;
- (void)getProductsForVenueID:(NSInteger)venueID completion:(void (^)(NSArray *products, NSHTTPURLResponse *response, NSError *error))completion;
- (void)getProductsForVenueID:(NSInteger)venueID withCategoryID:(NSInteger)categoryID completion:(void (^)(NSArray *products, NSHTTPURLResponse *response, NSError *error))completion;
- (void)getProductsForVenueID:(NSInteger)venueID withGroupID:(NSInteger)groupID completion:(void (^)(NSArray *products, NSHTTPURLResponse *response, NSError *error))completion;

@end

#pragma mark -

@interface BopplFakeServer : BopplServer

@end
