//
//  TopPlacesTableViewController.m
//  Top Places
//
//  Created by Sean Watkins on 5/30/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "TopPlacesTableViewController.h"
#import "FlickrFetcher.h"
#import "SplitViewBarButtonItemPresenter.h"

@interface TopPlacesTableViewController ()
@property (nonatomic, strong) NSDictionary *place; // of Flickr photo place dictionary.
@end

@implementation TopPlacesTableViewController

@synthesize photos = _photos;
@synthesize place = _place;


- (void)awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

- (id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if (![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]) {
        detailVC = nil;
    }
    return detailVC;
}

- (NSDictionary *)place
{
    if(!_place) _place = [[NSDictionary alloc] init];
    return _place;
}

- (void)setPhotos:(NSArray *)photos{
    if (photos != _photos){
        _photos = photos;
        [self.tableView reloadData];
    }
}

- (void)reloadFlickrPlaces:(id)navigationBarButtonItem
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:((self.splitViewController) ? UIActivityIndicatorViewStyleGray : UIActivityIndicatorViewStyleWhite)];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *photos = [FlickrFetcher topPlaces];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = [self sortPhotoPlacesByName:[photos mutableCopy]];
            self.navigationItem.rightBarButtonItem = navigationBarButtonItem;
        });
    });
    dispatch_release(downloadQueue);
}

- (IBAction)reload:(id)sender
{
    [self reloadFlickrPlaces:sender];
}

- (NSArray *)sortPhotoPlacesByName:(NSMutableArray *)photos
{
    NSArray *sortedArray = [photos sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 isKindOfClass:[NSDictionary class]] && [obj2 isKindOfClass:[NSDictionary class]]) {
            return [[obj1 objectForKey:FLICKR_PLACE_NAME] compare:[obj2 objectForKey:FLICKR_PLACE_NAME]]; 
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    return sortedArray;
}

- (NSString *)getCityNameFromFlickrPlaceName:(NSString *)placeName
{
   return [[placeName componentsSeparatedByString:@", "] objectAtIndex:0];
}

- (NSString *)getLocationNameFromFlickrPlaceName:(NSString *)placeName
{
    NSMutableArray *place = [[placeName componentsSeparatedByString:@", "] mutableCopy];
    [place removeObjectAtIndex:0];
    return [place componentsJoinedByString:@", "];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setPlace:self.place];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadFlickrPlaces:self.navigationItem.rightBarButtonItem];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return [self splitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Places";
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Top Place";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    cell.textLabel.text = [self getCityNameFromFlickrPlaceName:[photo objectForKey:FLICKR_PLACE_NAME]];
    cell.detailTextLabel.text = [self getLocationNameFromFlickrPlaceName:[photo objectForKey:FLICKR_PLACE_NAME]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.place = [self.photos objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"PlacePhotos" sender:self];
}

@end
