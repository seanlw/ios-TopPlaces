//
//  FlickrPhotoViewController.h
//  Top Places
//
//  Created by Sean Watkins on 5/30/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"

@interface FlickrPhotoViewController : UIViewController <SplitViewBarButtonItemPresenter>

@property (nonatomic, strong) NSDictionary *photo;
@property (nonatomic, strong) NSString *photoTitle;

@end
