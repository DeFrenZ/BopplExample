//
//  BopplProduct.m
//  BopplExample
//
//  Created by Davide De Franceschi on 23/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "BopplProduct.h"
#import "init_macros.h"

@implementation BopplProduct

#pragma mark Initialization

- (instancetype)initWithJSONData:(NSData *)data
{
	IF_NIL_RETURN_NIL_AND_LOG(data)
	NSError *JSONError;
	NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&JSONError];
	if (dataDictionary == nil) {
		NSLog(@"Error in JSON parsing while initializing a %@ object (%@). Data was %d bytes.", [self class], [JSONError localizedDescription], [data length]);
		return nil;
	}
	
	return [self initWithDictionary:dataDictionary];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if (self) {
		IF_NIL_RETURN_NIL_AND_LOG(dictionary)
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"id"]) _identifier = [dictionary[@"id"] unsignedIntegerValue];
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"product_id"]) _productIdentifier = [dictionary[@"product_id"] unsignedIntegerValue];
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"venueid"]) _venueIdentifier = [dictionary[@"venueid"] unsignedIntegerValue];
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"product_category_id"]) _productCategoryIdentifier = [dictionary[@"product_category_id"] unsignedIntegerValue];
		SET_VAR_OF_TYPE_OR_RETURN_NIL_AND_LOG(_name, NSString, dictionary[@"product_name"])
		SET_VAR_OF_TYPE_OR_RETURN_NIL_AND_LOG(_productDescription, NSString, dictionary[@"product_desc"])
		SET_VAR_OF_TYPE_OR_RETURN_NIL_AND_LOG(_thumbnailImageURL, NSURL, [NSURL URLWithString:dictionary[@"image_thumb_url"]])
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"price"]) _price = [dictionary[@"price"] floatValue];
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"free_product"]) _isFree = [dictionary[@"free_product"] boolValue];
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"tax_amount"]) _taxes = [dictionary[@"tax_amount"] floatValue];
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"tax_included"]) _areTaxesIncluded = [dictionary[@"tax_included"] boolValue];
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"active"]) _isActive = [dictionary[@"active"] boolValue];
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"in_stock"]) _isInStock = [dictionary[@"in_stock"] boolValue];
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"preparation_time"]) _preparationTime = [dictionary[@"preparation_time"] floatValue];
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"popularity"]) _popularity = [dictionary[@"popularity"] unsignedIntegerValue];
		if (dictionary[@"modifier_categories"] != nil) {
			NSMutableArray *tempArray = [@[] mutableCopy];
			BopplProductModifierCategory *tempCategory;
			for (NSDictionary *tempDictionary in dictionary[@"modifier_categories"]) {
				tempCategory = [BopplProductModifierCategory productModifierCategoryWithDictionary:tempDictionary];
				[tempArray addObject:tempCategory];
			}
			_modifierCategories = [NSArray arrayWithArray:tempArray];
		}
		// epos_id
	}
	return self;
}

+ (instancetype)productWithJSONData:(NSData *)data
{
	return [[self alloc] initWithJSONData:data];
}

+ (instancetype)productWithDictionary:(NSDictionary *)dictionary
{
	return [[self alloc] initWithDictionary:dictionary];
}

@end
