//
//  BopplProductGroup.m
//  BopplExample
//
//  Created by Davide De Franceschi on 23/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "BopplProductGroup.h"
#import "init_macros.h"

@implementation BopplProductGroup

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
		SET_STRING_VAR_TREATING_EMPTY_AS_NIL(_groupDescription, dictionary[@"group_desc"])
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"sort_order"]) _sortOrder = [dictionary[@"sort_order"] unsignedIntegerValue];
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"active"]) _isActive = [dictionary[@"active"] boolValue];
	}
	return self;
}

+ (instancetype)productGroupWithJSONData:(NSData *)data
{
	return [[self alloc] initWithJSONData:data];
}

+ (instancetype)productGroupWithDictionary:(NSDictionary *)dictionary
{
	return [[self alloc] initWithDictionary:dictionary];
}

#pragma mark BopplProductGroup

+ (NSDictionary *)dictionaryFromProductGroups:(NSArray *)groups
{
	if (groups != nil) {
		NSMutableDictionary *tempDictionary = [NSMutableDictionary dictionaryWithCapacity:groups.count];
		for (BopplProductGroup *currentGroup in groups) {
			tempDictionary[@(currentGroup.identifier)] = currentGroup;
		}
		return [NSDictionary dictionaryWithDictionary:tempDictionary];
	}
	
	NSLog(@"Trying to index a nil NSArray.");
	return nil;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *tempDictionary = [@{} mutableCopy];
	tempDictionary[@"id"] = @(self.identifier);
	tempDictionary[@"group_desc"] = (self.groupDescription == nil)? @"" : self.groupDescription;
	tempDictionary[@"sort_order"] = @(self.sortOrder);
	tempDictionary[@"active"] = @(self.isActive);	
	
	return [NSDictionary dictionaryWithDictionary:tempDictionary];
}

- (NSData *)JSONData
{
	NSDictionary *tempDictionary = [self dictionaryRepresentation];
	NSError *JSONError;
	NSData *JSONData = [NSJSONSerialization dataWithJSONObject:tempDictionary options:NSJSONWritingPrettyPrinted error:&JSONError];
	if (JSONData == nil) {
		NSLog(@"Error in writing a JSON representation of a %@ object (%@). Dictionary was %@.", [self class], [JSONError localizedDescription], tempDictionary);
		return nil;
	}
	
	return [NSData dataWithData:JSONData];
}

@end
