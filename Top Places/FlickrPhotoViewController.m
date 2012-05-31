//
//  FlickrPhotoViewController.m
//  Top Places
//
//  Created by Sean Watkins on 5/30/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "FlickrPhotoViewController.h"
#import "FlickrFetcher.h"

@interface FlickrPhotoViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@end

@implementation FlickrPhotoViewController
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize toolbar = _toolbar;
@synthesize photo = _photo;
@synthesize photoTitle = _photoTitle;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (splitViewBarButtonItem != _splitViewBarButtonItem) {
        NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
        if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
        if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
        self.toolbar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

- (void)centerFlickrPhotoScrollView
{
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect imageFrame = self.imageView.frame;
    
    if (imageFrame.size.width < boundsSize.width) {
        imageFrame.origin.x = (boundsSize.width - imageFrame.size.width) / 2;
    }
    else {
        imageFrame.origin.x = 0;
    }
    
    if (imageFrame.size.height < boundsSize.height) {
        imageFrame.origin.y = (boundsSize.height - imageFrame.size.height) / 2;
    }
    else {
        imageFrame.origin.y = 0;
    }
    
    self.imageView.frame = imageFrame;
}

- (void)zoomAndCenterFlickrPhoto
{
    // zoom image fit.
    CGFloat scaleWidth = self.scrollView.frame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = self.scrollView.frame.size.height / self.scrollView.contentSize.height;
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale = MIN(scaleWidth, scaleHeight);
    [self centerFlickrPhotoScrollView];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)loadFlickrImageFromUrlToView
{
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner]; 
    
    dispatch_queue_t downloadPhoto = dispatch_queue_create("Flickr photo downloader", NULL);
    dispatch_async(downloadPhoto, ^{
        NSData *data = [NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imageView setImage:[UIImage imageWithData:data]];
            self.scrollView.zoomScale = 1;
            self.scrollView.contentSize = self.imageView.image.size;
            self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
            [self zoomAndCenterFlickrPhoto];
        });
    });
    dispatch_release(downloadPhoto);
}

#define RECENTS_KEY @"photos"
- (void)addPhotoToRecents
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *photos = [[defaults objectForKey:RECENTS_KEY] mutableCopy];
    if (!photos) photos = [NSMutableArray array];
    for (NSDictionary *photo in photos) {
        if ([photo isEqualToDictionary:self.photo]) {
            return;
        }
    }
    
    [photos insertObject:self.photo atIndex:0];
    [defaults setObject:photos forKey:RECENTS_KEY];
    [defaults synchronize];
}

- (void)setPhoto:(NSDictionary *)photo
{
    if (photo != _photo) {
        _photo = photo;
        if (photo) {
            [self addPhotoToRecents];
            [self loadFlickrImageFromUrlToView];
        }
    }
}

- (void)setPhotoTitle:(NSString *)photoTitle
{
    if (photoTitle != _photoTitle) {
        _photoTitle = photoTitle;
        self.title = photoTitle;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self;
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setImageView:nil];
    [self setToolbar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setTintColor:nil];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
