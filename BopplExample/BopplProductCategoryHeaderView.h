//
//  BopplProductCategoryHeaderView.h
//  BopplExample
//
//  Created by Davide De Franceschi on 24/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BopplProductCategory.h"

@interface BopplProductCategoryHeaderView : UICollectionReusableView

@property (strong, nonatomic) BopplProductCategory *category;

- (void)configureHeaderWithCategory;

@end
