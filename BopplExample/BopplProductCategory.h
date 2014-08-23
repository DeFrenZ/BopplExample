//
//  BopplProductCategory.h
//  BopplExample
//
//  Created by Davide De Franceschi on 23/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BopplProductGroup;

@interface BopplProductCategory : NSObject

@property (nonatomic) NSUInteger identifier;
@property (strong, nonatomic) NSString *categoryDescription;
@property (nonatomic) NSUInteger productGroupIdentifier;
@property (strong, nonatomic) BopplProductGroup *productGroup;
@property (nonatomic) NSUInteger sortOrder;
@property (nonatomic) BOOL isActive;
@property (strong, nonatomic) NSArray *subCategories;

+ (instancetype)productCategoryWithJSONData:(NSData *)data;
+ (instancetype)productCategoryWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithJSONData:(NSData *)data;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

+ (NSDictionary *)dictionaryFromProductCategories:(NSArray *)categories;
+ (void)linkCategories:(NSArray *)categories toGroups:(NSArray *)groups;
+ (NSDictionary *)filterCategories:(NSArray *)categories byGroup:(NSArray *)groups;

@end
