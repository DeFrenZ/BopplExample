//
//  BopplProductViewCell.h
//  BopplExample
//
//  Created by Davide De Franceschi on 24/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BopplProduct.h"
#import "WebImageDownloader.h"

@interface BopplProductViewCell : UICollectionViewCell

@property (strong, nonatomic) BopplProduct *product;
@property (strong, nonatomic) WebImageDownloader *downloader;

@property (strong, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;

- (void)configureCellWithProduct;

@end
