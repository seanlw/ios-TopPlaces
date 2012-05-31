//
//  RecentTableViewController.m
//  Top Places
//
//  Created by Sean Watkins on 5/30/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "RecentTableViewController.h"
#import "FlickrPhotoViewController.h"
#import "FlickrFetcher.h"

@interface RecentTableViewController ()
@property (nonatomic, weak) NSArray *photos; // of Flickr dictionaries.
@property (nonatomic, strong) NSDictionary *photo; // of Flickr photo.
@end

@implementation RecentTableViewController
@synthesize photos = _photos;
@synthesize photo = _photo;


- (void)setPhotos:(NSArray *)photos
{
    if (photos != _photos) {
        _photos = photos;
        [self.tableView reloadData];
    }
}

- (NSDictionary *)photo
{
    if (!_photo) _photo = [[NSDictionary alloc] init];
    return _photo;
}

- (NSString *)flickrPhotoTitle:(NSDictionary *)photo
{
    NSString *title = [photo objectForKey:FLICKR_PHOTO_TITLE];
    NSString *description = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    return ([title length] == 0 ? (([description length] == 0) ? @"Unknown" : description) : title);
}

#define RECENTS_KEY @"photos"
- (void)loadPhotosFromRecents
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.photos = [defaults objectForKey:RECENTS_KEY];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadPhotosFromRecents];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    [segue.destinationViewController setPhotoTitle:[self flickrPhotoTitle:self.photo]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

#define MAX_VIEWABLE_RECENTS 20
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return MIN([self.photos count], MAX_VIEWABLE_RECENTS);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Recent";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    cell.textLabel.text = [self flickrPhotoTitle:photo];
    cell.detailTextLabel.text = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.photo = [self.photos objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"RecentFlickerPhotoSegue" sender:self];
}

@end
