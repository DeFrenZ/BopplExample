//
//  ResultViewController.m
//  BopplExample
//
//  Created by Davide De Franceschi on 21/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "ProductListViewController.h"
#import "ProductDetailViewController.h"
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
				[self linkAndFilterProductsWithCategoriesRemovingEmptyCategories:YES andOrderingBySortOrder:YES];
				dispatch_semaphore_signal(semaphore);
			});
			
		}];
		[self.server getProductGroupsForVenueID:self.venueID completion:^(NSArray *productGroups, NSHTTPURLResponse *response, NSError *error) {
			self.productGroupList = productGroups;
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
				[self linkAndFilterProductsWithGroupsRemovingEmptyGroups:YES andOrderingBySortOrder:YES];
				dispatch_async(dispatch_get_main_queue(), ^{
					[self updateNavigationBarTitle];
					[self.productsCollectionView reloadData];
				});
			});
		}];
	}
}

static NSString *productDetailViewControllerSegueIdentifier = @"ProductDetailSegue";

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:productDetailViewControllerSegueIdentifier]) {
		ProductDetailViewController *destinationViewController = (ProductDetailViewController *)segue.destinationViewController;
		destinationViewController.downloader = self.downloader;
		destinationViewController.product = (BopplProduct *)sender;
	} else {
		NSLog(@"Preparing for Segue with invalid identifier: %@.", segue.identifier);
	}
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	BopplProductCategory *sectionCategory = (BopplProductCategory *)self.productCategoryList[indexPath.section];
	NSArray *productsInSection = self.productListByCategory[@(sectionCategory.identifier)];
	BopplProduct *product = productsInSection[indexPath.row];
	
	[self performSegueWithIdentifier:productDetailViewControllerSegueIdentifier sender:product];
	
	[collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

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

- (void)linkAndFilterProductsWithCategoriesRemovingEmptyCategories:(BOOL)removeEmptyCategories andOrderingBySortOrder:(BOOL)useSortOrder
{
	if (self.productCategoryList != nil) {
		[BopplProduct linkProducts:self.productList toCategories:self.productCategoryList];
		self.productListByCategory = [BopplProduct filterProducts:self.productList byCategories:self.productCategoryList];
		
		if (removeEmptyCategories) {
			NSMutableIndexSet *emptyCategoriesIndices = [NSMutableIndexSet new];
			[self.productCategoryList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				BopplProductCategory *currentCategory = (BopplProductCategory *)obj;
				NSArray *productsInCategory = self.productListByCategory[@(currentCategory.identifier)];
				if (productsInCategory.count == 0) {
					[emptyCategoriesIndices addIndex:idx];
				}
			}];
			NSMutableArray *tempArray = [self.productCategoryList mutableCopy];
			[tempArray removeObjectsAtIndexes:emptyCategoriesIndices];
			self.productCategoryList = [NSArray arrayWithArray:tempArray];
		}
		
		if (useSortOrder) {
			self.productCategoryList = [self.productCategoryList sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES]]];
		}
	}
}

- (void)linkAndFilterProductsWithGroupsRemovingEmptyGroups:(BOOL)removeEmptyGroups andOrderingBySortOrder:(BOOL)useSortOrder
{
	if (self.productCategoryList != nil && self.productGroupList != nil) {
		[BopplProductCategory linkCategories:self.productCategoryList toGroups:self.productGroupList];
		self.productListByGroup = [BopplProduct filterProducts:self.productList byGroups:self.productGroupList withCategories:self.productCategoryList];
		
		if (removeEmptyGroups) {
			NSMutableIndexSet *emptyCategoriesIndices = [NSMutableIndexSet new];
			[self.productGroupList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				BopplProductGroup *currentGroup = (BopplProductGroup *)obj;
				NSArray *productsInGroup = self.productListByGroup[@(currentGroup.identifier)];
				if (productsInGroup.count == 0) {
					[emptyCategoriesIndices addIndex:idx];
				}
			}];
			NSMutableArray *tempArray = [self.productGroupList mutableCopy];
			[tempArray removeObjectsAtIndexes:emptyCategoriesIndices];
			self.productGroupList = [NSArray arrayWithArray:tempArray];
		}
		
		if (useSortOrder) {
			self.productGroupList = [self.productGroupList sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES]]];
		}
	}
}

- (void)updateNavigationBarTitle
{
	if (self.productCategoryList != nil && self.productCategoryList.count == 1) {
		self.navigationItem.title = ((BopplProductCategory *)self.productCategoryList.firstObject).categoryDescription;
	} else if (self.productGroupList != nil && self.productGroupList.count == 1) {
		self.navigationItem.title = ((BopplProductGroup *)self.productGroupList.firstObject).groupDescription;
	}
}


@end
