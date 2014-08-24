//
//  BopplProductCategoryHeaderView.m
//  BopplExample
//
//  Created by Davide De Franceschi on 24/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "BopplProductCategoryHeaderView.h"

@implementation BopplProductCategoryHeaderView

- (void)configureHeaderWithCategory
{
	self.descriptionLabel.text = self.category.categoryDescription;
}

@end
