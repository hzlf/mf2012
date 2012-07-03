//
//  GeoLogAppDelegate.m
//  GeoLog
//
//  Created by 関 治之 on 10/10/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GeoLogAppDelegate.h"
#import <CoreLocation/CoreLocation.h>

#import "GeoAPI.h"

#import "UIDevice+IdentifierAddition.h"

@implementation GeoLogAppDelegate

@synthesize TestView;
@synthesize window;
@synthesize navigationController;
@synthesize tabBarController;
@synthesize webView;
@synthesize streamView;



#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    // LocationCheckerViewController のインスタンスが無ければ作成
	if (locController == nil){
		locController = [[[LocationCheckViewController alloc] initWithNibName:nil bundle:nil] retain];
        
		[TestView addSubview:locController.view];  
        [window addSubview:tabBarController.view];      
		//[window makeKeyAndVisible];
	}
    

    NSString *struid = [NSString stringWithFormat:@"%@", [[UIDevice currentDevice] uniqueIdentifier]];
    // NSString *struid = [NSString stringWithFormat:@"%@", [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier]];
    
    
    NSString *fullURL = [NSString stringWithFormat:@"http://mf2012.anorg.net/london2012/map/?uid=%@", struid];
    NSURL *websiteURL = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:websiteURL];
    [self.webView loadRequest:requestObj];
    
    [self.streamView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"stream" ofType:@"html"]isDirectory:NO]]];

    
    // [GeoAPI updatePos];
    

	// 起動オプションにUIApplicationLaunchOptionsLocationKey がある場合、
	// startMonitoringSignificantLocationChanges で起動されている。新たに Location 取得を開始。
	id locationValue = [launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey];
	if (locationValue)
	{
		// create a new manager and start checking for sig changes
		[locController logTextWithTime:@"didFinishLaunchingWithOptions location key"];
		[locController startSigLog];
		return YES;
	}
    
    return YES;
}

//- (void)applicationDidFinishLaunching:(UIApplication *)application {
//	[window addSubview:tabBarController.view];
//}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	[locController logTextWithTime:@"enter background"];
    [locController forceGpsLog];
    //[CLLocationManager startMonitoringSignificantLocationChanges];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	[locController logTextWithTime:@"enter foreground"];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window release];
	[navigationController release];
	[tabBarController release];
	[locController release];
    [TestView release];
    [webView release];
    [super dealloc];
}


- (IBAction)GeoSwitch:(id)sender {
}
@end
