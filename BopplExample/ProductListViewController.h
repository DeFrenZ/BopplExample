//
//  ResultViewController.h
//  BopplExample
//
//  Created by Davide De Franceschi on 21/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductListViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) NSArray *productList;
@property (strong, nonatomic) NSArray *productGroupList;
@property (strong, nonatomic) NSArray *productCategoryList;

@end
