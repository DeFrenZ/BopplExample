//
//  BopplProductGroup.h
//  BopplExample
//
//  Created by Davide De Franceschi on 23/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BopplProductGroup : NSObject

@property (nonatomic) NSUInteger identifier;
@property (strong, nonatomic) NSString *groupDescription;
@property (nonatomic) NSUInteger sortOrder;
@property (nonatomic) BOOL isActive;

+ (instancetype)productGroupWithJSONData:(NSData *)data;
+ (instancetype)productGroupWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithJSONData:(NSData *)data;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

+ (NSDictionary *)dictionaryFromProductGroups:(NSArray *)groups;

@end
