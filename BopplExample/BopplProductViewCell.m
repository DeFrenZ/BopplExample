//
//  BopplProductViewCell.m
//  BopplExample
//
//  Created by Davide De Franceschi on 24/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "BopplProductViewCell.h"

@interface BopplProductViewCell ()

@property (strong, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation BopplProductViewCell

static CGFloat productCornerRadius = 10.0;
static CGFloat productBorderWidth = 1.0;
#define PRODUCT_BORDER_COLOR [UIColor orangeColor]

- (void)configureCellWithProduct
{
	[self.activityIndicatorView startAnimating];
	self.thumbnailImageView.image = nil;
	self.thumbnailImageView.layer.borderWidth = productBorderWidth;
	self.thumbnailImageView.layer.borderColor = PRODUCT_BORDER_COLOR.CGColor;
	self.thumbnailImageView.layer.cornerRadius = productCornerRadius;
	[self.product downloadThumbnailImageWithDownloader:self.downloader completion:^{
		dispatch_async(dispatch_get_main_queue(), ^{
			self.thumbnailImageView.image = self.product.thumbnailImage;
			[self.activityIndicatorView stopAnimating];
		});
	}];
	
	self.nameLabel.text = self.product.name;
	CGFloat totalPrice = [self.product totalPrice];
	self.priceLabel.text = (totalPrice == 0)? @"FREE" : [NSString stringWithFormat:@"£ %.2f", totalPrice];
}

@end
