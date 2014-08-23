//
//  ResultViewController.m
//  BopplExample
//
//  Created by Davide De Franceschi on 21/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "ProductListViewController.h"
#import "BopplJSONObjects.h"

@interface ProductListViewController ()

@property (strong, nonatomic) NSDictionary *productListByGroup;
@property (strong, nonatomic) NSDictionary *productListByCategory;

@end

@implementation ProductListViewController

#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	
}

#pragma mark UICollectionViewDataSource



#pragma mark UICollectionViewDelegate



#pragma mark ProductListViewController

- (void)filterProductListByCategory
{
	self.productListByCategory = [BopplProduct filterProducts:self.productList byCategories:self.productCategoryList];
}

- (void)filterProductListByGroup
{
	self.productListByGroup = [BopplProduct filterProducts:self.productList byGroups:self.productGroupList withCategories:self.productCategoryList];
}

@end
