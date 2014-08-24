//
//  ProductDetailViewController.m
//  BopplExample
//
//  Created by Davide De Franceschi on 24/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "ProductDetailViewController.h"

@interface ProductDetailViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *productImageView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIButton *priceButton;
@property (strong, nonatomic) IBOutlet UILabel *waitingClockLabel;
@property (strong, nonatomic) IBOutlet UILabel *waitingTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *popularityLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageViewAspectRatioConstraint;

@end

@implementation ProductDetailViewController

#pragma mark UIViewController

static CGFloat productCornerRadius = 15.0;
static CGFloat productBorderWidth = 2.0;
#define PRODUCT_BORDER_COLOR [UIColor orangeColor]

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self configureViewControllerWithProduct];
}

#pragma mark ProductDetailViewController

#define VIEW_ANIMATION_DURATION 0.4

- (void)configureViewControllerWithProduct
{
	if (self.product != nil) {
		self.navigationItem.title = self.product.name;
		
		[self setImage];
		
		self.descriptionLabel.text = (self.product.productDescription == nil || self.product.productDescription.length == 0)? @"No description available" : self.product.productDescription;
		
		CGFloat totalPrice = [self.product totalPrice];
		self.priceButton.titleLabel.text = (totalPrice == 0)? @"FREE" : [NSString stringWithFormat:@"£ %.2f", totalPrice];
		
		[self setWaitingTime];
		
		[self setPopularityLabel];
	}
}

#define UIIMAGE_ASPECT_RATIO(image) ((image).size.width / (image).size.height)

- (void)setImage
{
	self.productImageView.layer.borderWidth = productBorderWidth;
	self.productImageView.layer.borderColor = PRODUCT_BORDER_COLOR.CGColor;
	self.productImageView.layer.cornerRadius = productCornerRadius;
	[self.product downloadThumbnailImageWithDownloader:self.downloader completion:^{
		dispatch_async(dispatch_get_main_queue(), ^{
			self.productImageView.image = self.product.thumbnailImage;
			[self.activityIndicatorView stopAnimating];
			
			[self.productImageView removeConstraint:self.imageViewAspectRatioConstraint];
			NSLayoutConstraint *correctAspectRatioConstraint = [NSLayoutConstraint constraintWithItem:self.productImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.productImageView attribute:NSLayoutAttributeHeight multiplier:UIIMAGE_ASPECT_RATIO(self.productImageView.image) constant:0];
			[self.productImageView addConstraint:correctAspectRatioConstraint];
		});
	}];
}

- (void)setPopularityLabel
{
	NSString *popularityDescription;
	UIColor *popularityColor;
	if (self.product.popularity == NSNotFound) {
		popularityDescription = @"Unknown";
		popularityColor = [UIColor grayColor];
	} else if (self.product.popularity == 0) {
		popularityDescription = @"Virgin Product";
		popularityColor = [UIColor blueColor];
	} else if (self.product.popularity < 5) {
		popularityDescription = @"For Hipsters";
		popularityColor = [UIColor cyanColor];
	} else if (self.product.popularity < 20) {
		popularityDescription = @"Waitin' to get famous";
		popularityColor = [UIColor greenColor];
	} else if (self.product.popularity < 100) {
		popularityDescription = @"On the rise";
		popularityColor = [UIColor yellowColor];
	} else if (self.product.popularity < 500) {
		popularityDescription = @"Local favourite";
		popularityColor = [UIColor orangeColor];
	} else {
		popularityDescription = @"Local superstar";
		popularityColor = [UIColor redColor];
	}
	self.popularityLabel.text = popularityDescription;
	self.popularityLabel.textColor = popularityColor;
}

- (void)setWaitingTime
{
	NSInteger clockTime = self.product.preparationTime % 60;
	NSString *clockString;
	if (clockTime < 3) {
		clockString = @"🕛";
	} else if (clockTime < 8) {
		clockString = @"🕐";
	} else if (clockTime < 13) {
		clockString = @"🕑";
	} else if (clockTime < 18) {
		clockString = @"🕒";
	} else if (clockTime < 23) {
		clockString = @"🕓";
	} else if (clockTime < 28) {
		clockString = @"🕔";
	} else if (clockTime < 33) {
		clockString = @"🕕";
	} else if (clockTime < 38) {
		clockString = @"🕖";
	} else if (clockTime < 43) {
		clockString = @"🕗";
	} else if (clockTime < 48) {
		clockString = @"🕘";
	} else if (clockTime < 53) {
		clockString = @"🕙";
	} else if (clockTime < 58) {
		clockString = @"🕚";
	} else {
		clockString = @"🕛";
	}
	self.waitingClockLabel.text = clockString;
	
	UIColor *timeColor;
	if (self.product.preparationTime <= 5) {
		timeColor = [UIColor greenColor];
	} else if (self.product.preparationTime <= 15) {
		timeColor = [UIColor yellowColor];
	} else if (self.product.preparationTime <= 30) {
		timeColor = [UIColor orangeColor];
	} else {
		timeColor = [UIColor redColor];
	}
	self.waitingTimeLabel.text = [NSString stringWithFormat:@"%d'", self.product.preparationTime];
	self.waitingTimeLabel.textColor = timeColor;
}

@end
