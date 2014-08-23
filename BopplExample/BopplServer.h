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

@interface BopplServer : NSObject

@property (strong, nonatomic) BasicHTTPAuthAccount *account;

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
