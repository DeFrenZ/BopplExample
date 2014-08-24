//
//  ResultViewController.m
//  BopplExample
//
//  Created by Davide De Franceschi on 21/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "ProductListViewController.h"
#import "BopplJSONObjects.h"
#import "BopplProductViewCell.h"
#import "BopplProductCategoryHeaderView.h"

@interface ProductListViewController ()

@property (nonatomic) NSInteger venueID;
@property (strong, nonatomic) NSArray *productGroupList;
@property (strong, nonatomic) NSDictionary *productListByGroup;
@property (strong, nonatomic) NSArray *productCategoryList;
@property (strong, nonatomic) NSDictionary *productListByCategory;

@property (strong, nonatomic) IBOutlet UICollectionView *productsCollectionView;

@end

@implementation ProductListViewController

#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self determineVenueID];
	if (self.venueID != NSNotFound && self.server != nil) {
		dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
		[self.server getProductCategoriesForVenueID:self.venueID completion:^(NSArray *productCategories, NSHTTPURLResponse *response, NSError *error) {
			self.productCategoryList = productCategories;
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				[self linkAndFilterProductsWithCategories];
				dispatch_semaphore_signal(semaphore);
			});
			
		}];
		[self.server getProductGroupsForVenueID:self.venueID completion:^(NSArray *productGroups, NSHTTPURLResponse *response, NSError *error) {
			self.productGroupList = productGroups;
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
				[self linkAndFilterProductsWithGroups];
				dispatch_async(dispatch_get_main_queue(), ^{
					[self.productsCollectionView reloadData];
				});
			});
		}];
	}
#warning TODO: fix layout spacing between collectionview and navigationbar
#warning TODO: show only categories with at least 1 product
#warning TODO: sort by specified sorting order
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return self.productCategoryList.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	BopplProductCategory *sectionCategory = (BopplProductCategory *)self.productCategoryList[section];
	NSArray *productsInSection = self.productListByCategory[@(sectionCategory.identifier)];
	return productsInSection.count;
}

static NSString *cellReuseIdentifier = @"Cell";
static NSString *headerReuseIdentifier = @"Header";

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	BopplProductViewCell *cell = (BopplProductViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifier forIndexPath:indexPath];

	BopplProductCategory *sectionCategory = (BopplProductCategory *)self.productCategoryList[indexPath.section];
	NSArray *productsInSection = self.productListByCategory[@(sectionCategory.identifier)];
	BopplProduct *product = productsInSection[indexPath.row];
	
	cell.product = product;
	cell.downloader = self.downloader;
	[cell configureCellWithProduct];
	
	return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	BopplProductCategoryHeaderView *header = (BopplProductCategoryHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerReuseIdentifier forIndexPath:indexPath];

	BopplProductCategory *sectionCategory = (BopplProductCategory *)self.productCategoryList[indexPath.section];
	
	header.category = sectionCategory;
	[header configureHeaderWithCategory];
	
	return header;
}

#pragma mark UICollectionViewDelegate



#pragma mark UICollectionViewDelegateFlowLayout



#pragma mark ProductListViewController

- (void)determineVenueID
{
	if (self.productList == nil || self.productList.count == 0) {
		self.venueID = NSNotFound;
		return;
	}
	
	NSInteger currentID = ((BopplProduct *)self.productList[0]).venueIdentifier;
	for (BopplProduct *currentProduct in self.productList) {
		if (currentProduct.venueIdentifier != currentID) {
			self.venueID = NSNotFound;
			return;
		}
	}
	self.venueID = currentID;
}

- (void)linkAndFilterProductsWithCategories
{
	if (self.productCategoryList != nil) {
		[BopplProduct linkProducts:self.productList toCategories:self.productCategoryList];
		self.productListByCategory = [BopplProduct filterProducts:self.productList byCategories:self.productCategoryList];
	}
}

- (void)linkAndFilterProductsWithGroups
{
	if (self.productCategoryList != nil && self.productGroupList != nil) {
		[BopplProductCategory linkCategories:self.productCategoryList toGroups:self.productGroupList];
		self.productListByGroup = [BopplProduct filterProducts:self.productList byGroups:self.productGroupList withCategories:self.productCategoryList];
	}
}


@end
