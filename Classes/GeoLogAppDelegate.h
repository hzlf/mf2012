//
//  GeoLogAppDelegate.h
//  GeoLog
//
//  Created by 関 治之 on 10/10/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationCheckViewController.h"

#import "GeoAPI.h"

@interface GeoLogAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
     
	LocationCheckViewController *locController;
    //UINavigationController *navigationController;
    UITabBarController *tabBarController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end

