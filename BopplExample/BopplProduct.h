//
//  BopplProduct.h
//  BopplExample
//
//  Created by Davide De Franceschi on 23/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BopplProductCategory.h"
#import "BopplProductModifierCategory.h"

@interface BopplProduct : NSObject

@property (nonatomic) NSUInteger identifier;
@property (nonatomic) NSUInteger productIdentifier;
@property (nonatomic) NSUInteger venueIdentifier;
@property (nonatomic) NSUInteger productCategoryIdentifier;
@property (strong, nonatomic) BopplProductCategory *productCategory;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *productDescription;
@property (strong, nonatomic) NSURL *thumbnailImageURL;
@property (strong, nonatomic) UIImage *thumbnailImage;
@property (nonatomic) CGFloat price;
@property (nonatomic) BOOL isFree;
@property (nonatomic) CGFloat taxes;
@property (nonatomic) BOOL areTaxesIncluded;
@property (nonatomic) BOOL isActive;
@property (nonatomic) BOOL isInStock;
@property (nonatomic) NSUInteger preparationTime;
@property (nonatomic) NSUInteger popularity;
@property (strong, nonatomic) NSArray *modifierCategories;
// epos_id

+ (instancetype)productWithJSONData:(NSData *)data;
+ (instancetype)productWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithJSONData:(NSData *)data;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
