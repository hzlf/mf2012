//
//  LocationCheckViewController.m
//  FsqCheckin
//
//  Created by 関 治之 on 10/10/18.
//  Copyright 2010 Haruyuki Seki. All rights reserved.
//

#import "LocationCheckViewController.h"
#define kLBL_GPSSTART @"Start Marching"
#define kLBL_SIGSTART @"Sig Start"
#define kLBL_MAPPING @"Mapping"
#define kLBL_STOP @"Stop"
#define kLBL_SEND @"Send log"
#define kLBL_REMOVE @"Remove log"
#define kLOG_FILE @"latlong"

#import "RFRequest.h"
#import "RFResponse.h"
#import "RFService.h"

#import "GeoAPI.h"

#import "UIDevice+IdentifierAddition.h"

@implementation LocationCheckViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (!(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) return nil;

	// location manager
	locMan = [[CLLocationManager alloc] init];
	locMan.delegate = self;
	[UIDevice currentDevice].batteryMonitoringEnabled = YES;
	isUpdating = NO;
	
	// mapview
	//mapView = [[MKMapView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    //mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0,24,320,460)];
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0,0,1,1)];
    
    mapView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

    
	mapView.delegate = self;
    // mapView.mapType = MKMapTypeSatellite;
	[mapView setShowsUserLocation:YES];
	
	// set up buttons
	btnGpsStart = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[btnGpsStart addTarget:self action:@selector(pressGpsStart:) forControlEvents:UIControlEventTouchUpInside];
	[btnGpsStart setTitle:kLBL_GPSSTART forState:UIControlStateNormal];
	[btnGpsStart setFrame:CGRectMake(40, 330, 240, 30)];
    
	[self.view addSubview:mapView];
	[self.view addSubview:btnGpsStart];

	
    return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}




-(NSString *) makeLogText:(CLLocation *)loc{
	NSDate *now = [NSDate date]; 
	NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
	[fmt setDateFormat:@"yyyy/MM/dd HH:mm:ss"];

    NSString *logstr = [NSString stringWithFormat:@"%@,location,%0.8f,%0.8f,%0.0f,%0.0f,%0.2f",
                        [fmt stringFromDate:now],
						loc.coordinate.latitude,
						loc.coordinate.longitude,
						loc.altitude,
						loc.horizontalAccuracy,
                        [[UIDevice currentDevice] batteryLevel]
						];
    
    
    NSString *struid = [NSString stringWithFormat:@"%@", [[UIDevice currentDevice] uniqueIdentifier]];
    
    // NSString *struid = [NSString stringWithFormat:@"%@", [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier]];
    
    
    NSLog(@"%@",[[UIDevice currentDevice] uniqueDeviceIdentifier]);
    
    NSString *strcoordinate = [NSString stringWithFormat: @"POINT (%0.8f %0.8f)", loc.coordinate.longitude, loc.coordinate.latitude];

    
    RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:@"http://node02.daj.anorg.net/"]type:RFRequestMethodPost resourcePathComponents:@"forest", @"api", @"positions/?format=json", nil];
    
    
    [r addParam:strcoordinate forKey:@"coordinates"];
    [r addParam:struid forKey:@"uid"];
    
    //now execute this request and fetch the response in a block
    [RFService execRequest:r completion:^(RFResponse *response) {
        NSLog(@"%@", response); //print out full response
    }];
    
	return logstr;
}

- (NSString *)getDocumentPath:(NSString *)file
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:file];
}

-(void) logTextWithTime:(NSString *)log{
    NSLog(@"logTextWithTime");
	NSDate *now = [NSDate date]; 
	NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
	[fmt setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
	[self logText:[NSString stringWithFormat:@"%@,%@", [fmt stringFromDate:now], log]];
}

-(void) logText:(NSString *)log{
    NSLog(@"logText");
    

    
    
	NSError *error = nil;
	NSString *fullPath = [self getDocumentPath:kLOG_FILE];
	NSFileManager *filem = [NSFileManager defaultManager];
	NSString *text;
	if ([filem fileExistsAtPath:fullPath]){
		text = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
	}else{
		text = @"";
	}
	NSString *data = [text stringByAppendingFormat:@"%@\n", log];
	[data writeToFile:fullPath atomically:NO encoding:NSUTF8StringEncoding error:&error];
	if (error){
		TRACE(@"write error:%@", [error localizedDescription]);
	}
    NSLog(@"%@", log);
	TRACE(@"%@", log);
}

-(void) removeLogFile{
	NSString *fullPath = [self getDocumentPath:kLOG_FILE];
	NSFileManager *filem = [NSFileManager defaultManager];
	NSError *error = nil;
	[filem removeItemAtPath:fullPath error:&error];
}

-(void) sendLog{
	NSString *text = [self readLog];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto:seki@cirius.co.jp?body=%@", 
																	 [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
}
-(NSString *)readLog{
	NSString *fullPath = [self getDocumentPath:kLOG_FILE];
	NSError *error = nil;
	return [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
}


/*
-(void)startSigLog{
	if (isUpdating){
		[self logText:@"stop logging"];
		[locMan stopMonitoringSignificantLocationChanges];
		isUpdating = NO;
		[btnSigStart setTitle:kLBL_SIGSTART forState:UIControlStateNormal];
	}else{
		[self logText:@"start logging"];
		[locMan startMonitoringSignificantLocationChanges];
		isUpdating = YES;
		[btnSigStart setTitle:kLBL_STOP forState:UIControlStateNormal];
	}
}
*/
-(void)startGpsLog{
	if (isUpdating){
		[self logText:@"stop logging"];
		[locMan stopUpdatingLocation];
		//[locMan stopMonitoringSignificantLocationChanges];
		isUpdating = NO;
		[btnGpsStart setTitle:kLBL_GPSSTART forState:UIControlStateNormal];
	}else{
		[self logText:@"start logging"];
        NSLog(@"Simple message");
		[locMan startUpdatingLocation];
		//[locMan startMonitoringSignificantLocationChanges];
		isUpdating = YES;
		[btnGpsStart setTitle:kLBL_STOP forState:UIControlStateNormal];
	}
}
-(void)forceGpsLog{
	if (isUpdating){

	}else{
		[self logText:@"start logging"];
        //NSLog(@"Simple message");
		//[locMan startUpdatingLocation];
        //[locMan startMonitoringSignificantLocationChanges];
		//isUpdating = YES;
		//[btnGpsStart setTitle:kLBL_STOP forState:UIControlStateNormal];
	}
}

#pragma mark --
#pragma mark Buttons
/*
-(void)pressSigStart:(UIButton *)sender{
	[self startSigLog];
}
 */
-(void)pressGpsStart:(UIButton *)sender{
	[self startGpsLog];
}
-(void)pressSend:(UIButton *)sender{
	[self sendLog];
}
-(void)pressRemove:(UIButton *)sender{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"confirmation" message:@"are you sure to delete log file?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
	[alert show];
	[alert release];
}
#pragma mark --
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex == 1){
		[self removeLogFile];
	}
}

#pragma mark --
#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation{
    
    
    BOOL isInBackground = NO;
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
    {
        isInBackground = YES;
    }
    
    // Handle location updates as normal, code omitted for brevity.
    // The omitted code should determine whether to reject the location update for being too
    // old, too close to the previous one, too inaccurate and so forth according to your own
    // application design.
    
    if (isInBackground)
    {
        [self logText:@"update from background"];
        // NSString *log = [self makeLogText:newLocation];
        
        static NSString * const context = @"background";
        
        [self sendBackgroundLocationToServer:newLocation:context];
        //[self logText:log];
    }
    else
    {
        [self logText:@"update from foreground"];
        
        
        [mapView setCenterCoordinate:newLocation.coordinate];
        
        
        static NSString * const context = @"foreground";
        
        [self sendBackgroundLocationToServer:newLocation:context];
        
        //NSString *log = [self makeLogText:newLocation];
        //[self logText:log];
    }
    
}


-(void) sendBackgroundLocationToServer:(CLLocation *)location:(NSString *)context
{
    UIApplication*    app = [UIApplication sharedApplication];
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    NSString *struid = [NSString stringWithFormat:@"%@", [[UIDevice currentDevice] uniqueIdentifier]];
    NSString *strcoordinate = [NSString stringWithFormat: @"POINT (%0.8f %0.8f)", location.coordinate.longitude, location.coordinate.latitude];

    
    RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:@"http://node02.daj.anorg.net/"]type:RFRequestMethodPost resourcePathComponents:@"forest", @"api", @"positions/?format=json", nil];
    
    
    [r addParam:strcoordinate forKey:@"coordinates"];
    [r addParam:struid forKey:@"uid"];
    // [r addParam:context forKey:@"app_context"];
    
    //now execute this request and fetch the response in a block
    [RFService execRequest:r completion:^(RFResponse *response) {
        NSLog(@"%@", response); //print out full response
        NSLog(@"API request done");
    }];
    
     
     
    if (bgTask != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }
        
}



- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	[self logTextWithTime:[NSString stringWithFormat:@"LocationManager Failed %@", [error localizedDescription]]];
}
#pragma mark --
#pragma mark MKMapViewDelegate
-(MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>)anAnnotation {
	return nil;
}

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
}

-(void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)userLocation{
}

#pragma mark --
- (void)dealloc {
	[mapView release];
	[locMan release];
	[btnGpsStart release];
	[btnSend release];
	[btnRemove release];
    [super dealloc];
}


@end
