//
//  TopPlacesTableViewController.h
//  Top Places
//
//  Created by Sean Watkins on 5/30/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopPlacesTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *photos; // of Flicker Top Places dictionaries.

- (NSString *)getCityNameFromFlickrPlaceName:(NSString *)placeName;

@end
