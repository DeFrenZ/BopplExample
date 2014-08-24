//
//  BopplProductViewCell.m
//  BopplExample
//
//  Created by Davide De Franceschi on 24/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "BopplProductViewCell.h"

@interface BopplProductViewCell ()
@end

@implementation BopplProductViewCell

- (void)configureCellWithProduct
{
	[self.activityIndicatorView startAnimating];
	self.thumbnailImageView.image = nil;
	
	[self.product downloadThumbnailImageWithDownloader:self.downloader completion:^{
		dispatch_async(dispatch_get_main_queue(), ^{
			self.thumbnailImageView.image = self.product.thumbnailImage;
			[self.activityIndicatorView stopAnimating];
		});
	}];
	self.nameLabel.text = self.product.name;
	self.priceLabel.text = [NSString stringWithFormat:@"£ %.2f", self.product.price];
}

@end
