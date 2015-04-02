//
//  ViewController.m
//  SharePlace
//
//  Created by tureki on 3/31/15.
//  Copyright (c) 2015 watur. All rights reserved.
//

#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "SPGooglePlacesAutocomplete.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>
#import "FBSendButton.h"
#import "AppDelegate.h"
#import "UIAlertView+Extension.h"

@interface ViewController () <GMSMapViewDelegate>
@property (weak, nonatomic) IBOutlet FBSendButton *fbSendButton;
@property (strong, nonatomic) IBOutlet UIView *mapCanvas;
@property (strong, nonatomic) GMSMarker *marker;
@end

@implementation ViewController{
    GMSMapView *mapView_;
    BOOL firstLocationUpdate_;
    BOOL shouldBeginEditing;
    SPGooglePlacesAutocompleteQuery *searchQuery;
    NSArray *searchResultPlaces;
}

- (void)viewDidLoad {

    [super viewDidLoad];

    self.title = @"Share Your Place";

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"MessengerIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(backFBMessenger)];

    self.navigationItem.leftBarButtonItem = backButton;

    self.searchDisplayController.searchBar.placeholder = @"Place or Address";

    searchQuery = [[SPGooglePlacesAutocompleteQuery alloc] initWithApiKey:@"AIzaSyDpogUc2EwjJUiPbTY3vltzPSAqFZdvH_M"];
    shouldBeginEditing = YES;

    [self.fbSendButton setTarget:self action:@selector(sendFBMessenger:)];


//    self.placeSearch.delegate = self;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewDidLayoutSubviews{

    [super viewDidLayoutSubviews];
    

    
    if(!mapView_){
        
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868 longitude:151.2086 zoom:12];

        mapView_ = [GMSMapView mapWithFrame:self.mapCanvas.bounds camera:camera];

        mapView_.delegate = self;
            
        mapView_.settings.compassButton = YES;

        mapView_.settings.myLocationButton = YES;

        [self.mapCanvas addSubview:mapView_];

        // Listen to the myLocation property of GMSMapView.
        [mapView_ addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context:NULL];

        dispatch_async(dispatch_get_main_queue(), ^{

            mapView_.myLocationEnabled = YES;

        });

    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backFBMessenger
{
    
    if ([FBSDKMessengerSharer messengerPlatformCapabilities] & FBSDKMessengerPlatformCapabilityOpen) {
        
        [FBSDKMessengerSharer openMessenger];
        
    }else{
        
        [self installFBMessenger];
        
    }
    
}

- (IBAction)sendFBMessenger:(id)sender {
    
    mapView_.settings.myLocationButton = NO;
    
    [FBSDKAppEvents logEvent:@"Send To Messenger"];
    
    if ([FBSDKMessengerSharer messengerPlatformCapabilities] & FBSDKMessengerPlatformCapabilityImage) {
        

        UIGraphicsBeginImageContextWithOptions(self.mapCanvas.frame.size, YES, 0.0f);
        
        [mapView_.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        [FBSDKMessengerSharer shareImage:image withOptions:nil];
        
    }else {
        
        [self installFBMessenger];
        
    }
    
    mapView_.settings.myLocationButton = YES;
}

-(void)installFBMessenger{
    
    NSString *iTunesLink = @"itms://itunes.apple.com/us/app/facebook-messenger/id454638411?mt=8";
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
    
}

#pragma mark -
#pragma mark GMSMapViewDelegate

- (BOOL)didTapMyLocationButtonForMapView:(GMSMapView *)mapView
{
    [self removeMapMarker];
    
    return NO;
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self removeMapMarker];
    
    self.marker = [GMSMarker markerWithPosition:coordinate];
    
    self.marker.map = mapView_;
    
    mapView_.selectedMarker = self.marker;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [searchResultPlaces count];
}


- (SPGooglePlacesAutocompletePlace *)placeAtIndexPath:(NSIndexPath *)indexPath {
    return searchResultPlaces[indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SPGooglePlacesAutocompleteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    cell.textLabel.font = [UIFont fontWithName:@"GillSans" size:16.0];
    cell.textLabel.text = [self placeAtIndexPath:indexPath].name;
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)removeMapMarker {

    if(self.marker){
        self.marker.map = nil;
    }

}

- (void)recenterMapToPlacemark {

    CGPoint point = [mapView_.projection pointForCoordinate:self.marker.position];
    //    point.x = point.x + 100;
    GMSCameraUpdate *camera = [GMSCameraUpdate setTarget:[mapView_.projection coordinateForPoint:point]];

    [mapView_ animateWithCameraUpdate:camera];

}

- (void)addPlacemarkAnnotationToMap:(NSDictionary *)placemark {

    [self removeMapMarker];

    CLLocationCoordinate2D coordinate;
    
    coordinate.latitude = (CGFloat)[placemark[@"geometry"][@"location"][@"lat"] floatValue];
    
    coordinate.longitude = (CGFloat)[placemark[@"geometry"][@"location"][@"lng"] floatValue];
    
//    NSLog(@"lat:%@",placemark[@"geometry"][@"location"][@"lat"]);
//    NSLog(@"lng:%f",placemark.location.coordinate.longitude);
    self.marker = [GMSMarker markerWithPosition:coordinate];

    self.marker.title = placemark[@"name"];
    
    self.marker.snippet = placemark[@"formatted_address"];
    
    self.marker.map = mapView_;

    mapView_.selectedMarker = self.marker;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    SPGooglePlacesAutocompletePlace *place = [self placeAtIndexPath:indexPath];

    [FBSDKAppEvents logEvent:@"Search Place"];
    
    [place resolveToPlacemark:^(NSDictionary *placemark, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not map selected Place"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        } else if (placemark) {

            [self addPlacemarkAnnotationToMap:placemark];

            [self recenterMapToPlacemark];

            // ref: https://github.com/chenyuan/SPGooglePlacesAutocomplete/issues/10
            [self.searchDisplayController setActive:NO];
            [self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }];

}

#pragma mark -
#pragma mark UISearchDisplayDelegate

- (void)handleSearchForSearchString:(NSString *)searchString {

       searchQuery.input = searchString;
    [searchQuery fetchPlaces:^(NSArray *places, NSError *error) {
        if (error) {

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not fetch Places"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        } else {
            searchResultPlaces = places;
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
    }];

}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {

    [self handleSearchForSearchString:searchString];

    return YES;
}

#pragma mark -
#pragma mark UISearchBar Delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (![searchBar isFirstResponder]) {

    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {

    if (shouldBeginEditing) {
        // Animate in the table view.
        NSTimeInterval animationDuration = 0.3;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        self.searchDisplayController.searchResultsTableView.alpha = 0.75;
        [UIView commitAnimations];

        [self.searchDisplayController.searchBar setShowsCancelButton:YES animated:YES];
    }
    BOOL boolToReturn = shouldBeginEditing;
    shouldBeginEditing = YES;
    return boolToReturn;
}



#pragma mark - KVO updates

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (!firstLocationUpdate_) {
        
        firstLocationUpdate_ = YES;
        
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        
        mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate zoom:14];
        
    }
    
}

@end
