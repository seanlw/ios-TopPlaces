//
//  PlacePhotosTableViewController.m
//  Top Places
//
//  Created by Sean Watkins on 5/30/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "PlacePhotosTableViewController.h"
#import "FlickrFetcher.h"

@interface PlacePhotosTableViewController ()
@property (nonatomic, strong) NSArray *photos; // of Flickr place dictionary.
@property (nonatomic, strong) NSDictionary *photo; // of Flicker dictionary.
@end

@implementation PlacePhotosTableViewController

@synthesize photos = _photos;
@synthesize place = _place;
@synthesize photo = _photo;

- (NSDictionary *)place
{
    if(!_place) _place = [[NSDictionary alloc] init];
    return _place;
}

- (NSDictionary *)photo
{
    if(!_photo) _photo = [[NSDictionary alloc] init];
    return _photo;
}

#define MAX_PHOTO_RESULTS 50
- (void)loadPhotosFromPlace:(NSDictionary *)place
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner]; 
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("Flickr downloadQueue", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *photos = [FlickrFetcher photosInPlace:place maxResults:MAX_PHOTO_RESULTS];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = photos;
            self.navigationItem.rightBarButtonItem = nil;
        });
    });
    dispatch_release(downloadQueue);
}

- (void)setPhotos:(NSArray *)photos
{
    if (photos != _photos) {
        _photos = photos;
        [self.tableView reloadData];
    }
}

- (void)setPlace:(NSDictionary *)place
{
    if(place != _place){
        _place = place;
        [self loadPhotosFromPlace:place];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setPhoto:self.photo];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photos";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    NSString *title = [photo objectForKey:FLICKR_PHOTO_TITLE];
    NSString *description = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];

    cell.textLabel.text = ([title length] == 0 ? (([description length] == 0) ? @"Unknown" : description) : title);
    cell.detailTextLabel.text = description;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.photo = [self.photos objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"FlickerPhotoSegue" sender:self];
}

@end
