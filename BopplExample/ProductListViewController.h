//
//  ResultViewController.h
//  BopplExample
//
//  Created by Davide De Franceschi on 21/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BopplServer.h"

@interface ProductListViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) BopplServer *server;
@property (strong, nonatomic) WebImageDownloader *downloader;
@property (strong, nonatomic) NSArray *productList;

@end
