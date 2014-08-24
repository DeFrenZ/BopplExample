//
//  ProductDetailViewController.h
//  BopplExample
//
//  Created by Davide De Franceschi on 24/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BopplProduct.h"

@interface ProductDetailViewController : UIViewController

@property (strong, nonatomic) WebImageDownloader *downloader;
@property (strong, nonatomic) BopplProduct *product;

- (void)configureViewControllerWithProduct;

@end
