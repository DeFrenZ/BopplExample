//
//  BopplProduct.m
//  BopplExample
//
//  Created by Davide De Franceschi on 23/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "BopplJSONObjects.h"
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
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"venue_id"]) _venueIdentifier = [dictionary[@"venue_id"] unsignedIntegerValue];
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"product_category_id"]) _productCategoryIdentifier = [dictionary[@"product_category_id"] unsignedIntegerValue];
		SET_VAR_OF_TYPE_OR_RETURN_NIL_AND_LOG(_name, NSString, dictionary[@"product_name"])
		SET_STRING_VAR_TREATING_EMPTY_AS_NIL(_productDescription, dictionary[@"product_desc"])
		_thumbnailImageURL = [NSURL URLWithString:dictionary[@"image_thumb_url"]];
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

#pragma mark BopplProduct

+ (NSDictionary *)dictionaryFromProducts:(NSArray *)products
{
	if (products != nil) {
		NSMutableDictionary *tempDictionary = [NSMutableDictionary dictionaryWithCapacity:products.count];
		for (BopplProduct *currentProduct in products) {
			tempDictionary[@(currentProduct.productIdentifier)] = currentProduct;
		}
		return [NSDictionary dictionaryWithDictionary:tempDictionary];
	}
	
	NSLog(@"Trying to index a nil NSArray.");
	return nil;
}

+ (void)linkProducts:(NSArray *)products toCategories:(NSArray *)categories
{
	if (products != nil && categories != nil) {
		NSDictionary *indexedCategories = [BopplProductCategory dictionaryFromProductCategories:categories];
		for (BopplProduct *currentProduct in products) {
			currentProduct.productCategory = indexedCategories[@(currentProduct.productCategoryIdentifier)];
		}
	}
	
	NSLog(@"Trying to link arrays in %s but at least one is nil.", __PRETTY_FUNCTION__);
}

+ (void)linkProducts:(NSArray *)products toGroups:(NSArray *)groups withCategories:(NSArray *)categories
{
	if (products != nil && groups != nil && categories != nil) {
		[BopplProductCategory linkCategories:categories toGroups:groups];
		[[self class] linkProducts:products toCategories:categories];
	}
	
	NSLog(@"Trying to link arrays in %s but at least one is nil.", __PRETTY_FUNCTION__);
}

+ (NSDictionary *)filterProducts:(NSArray *)products byCategories:(NSArray *)categories
{
	if (products != nil && categories != nil) {
		NSMutableDictionary *tempDictionary = [NSMutableDictionary dictionaryWithCapacity:categories.count];
		NSArray *productsWithinCurrentCategory;
		for (BopplProductCategory *currentCategory in categories) {
			productsWithinCurrentCategory = [products filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"productCategoryIdentifier == %d", currentCategory.identifier]];
			tempDictionary[@(currentCategory.identifier)] = productsWithinCurrentCategory;
		}
		return [NSDictionary dictionaryWithDictionary:tempDictionary];
	}
	
	NSLog(@"Trying to filter products by category without supplying products or categories.");
	return nil;
}

+ (NSDictionary *)filterProducts:(NSArray *)products byGroups:(NSArray *)groups withCategories:(NSArray *)categories
{
	if (products != nil && groups != nil && categories != nil) {
		[[self class] linkProducts:products toCategories:categories];
		
		NSMutableDictionary *tempDictionary = [NSMutableDictionary dictionaryWithCapacity:groups.count];
		NSArray *productsWithinCurrentGroup;
		for (BopplProductGroup *currentGroup in groups) {
			productsWithinCurrentGroup = [products filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"productCategoryIdentifier.productGroupIdentifier == %d", currentGroup.identifier]];
			tempDictionary[@(currentGroup.identifier)] = productsWithinCurrentGroup;
		}
		return [NSDictionary dictionaryWithDictionary:tempDictionary];
	}
	
	NSLog(@"Trying to filter products by group without supplying products, groups or categories.");
	return nil;
}

- (void)downloadThumbnailImageWithDownloader:(WebImageDownloader *)downloader completion:(void (^)())completion
{
	if (downloader == nil) {
		NSLog(@"Trying to download thumbnail image with nil downloader.");
		return;
	}
	
	[downloader downloadImageFromURL:self.thumbnailImageURL completion:^(UIImage *downloadedImage) {
		self.thumbnailImage = downloadedImage;
		completion(self.thumbnailImage);
	}];
}

@end
