//
//  LBMGAppDelegate.m
//  Tours
//
//  Created by Alan Smithee on 3/18/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGAppDelegate.h"
#import "LBMGMainMasterPageVC.h"
#import "UAirship.h"
#import "UAPush.h"
#import "UALocationService.h"
#import "UAConfig.h"
#import "TapItAppTracker.h"

@implementation LBMGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    // TESTFLIGHT
    [TestFlight takeOff:@"bda21c49-ea18-4948-8873-b82c19aacdf7"];
    
    self.lbmgEngine = [[LBMGEngine alloc] init];   // Build Network Engine

    self.viewController = [[LBMGMainMasterPageVC alloc] initWithNibName:@"LBMGMainMasterPageVC" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
            
    [LBMGUtilities createFolderForTourData];
    [LBMGUtilities removeHangingDownloadFiles];
        
    //Create Airship options directory and add the required UIApplication launchOptions
    UAConfig *config = [UAConfig defaultConfig];
    [UAirship takeOff:config];
    
    // Set the icon badge to zero on startup (optional)
    [[UAPush shared] resetBadge];
    
    // Set the notification types required for the app (optional). 
    [UAPush shared].notificationTypes = (UIRemoteNotificationTypeBadge |
                                         UIRemoteNotificationTypeSound |
                                         UIRemoteNotificationTypeAlert);
    
    NSString *yourAlias = @"Stine's test";
    [UAPush shared].alias = yourAlias;
    
    [UALocationService setAirshipLocationServiceEnabled:YES];
    UALocationService *locationService = [[UAirship shared] locationService];
    locationService.backgroundLocationServiceEnabled = NO;
    [locationService startReportingSignificantLocationChanges];
    
    TapItAppTracker *appTracker = [TapItAppTracker sharedAppTracker];
    [appTracker reportApplicationOpen];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[UAPush shared] resetBadge];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//    [UAirship land];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notif {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Local Notification" message:notif.alertBody delegate:self cancelButtonTitle:@"Cool" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Updates the device token and registers the token with UA.
    [[UAPush shared] registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
//    UA_LINFO(@"Received remote notification (in appDelegate): %@", userInfo);
    
    // Optionally provide a delegate that will be used to handle notifications received while the app is running
    // [UAPush shared].delegate = your custom push delegate class conforming to the UAPushNotificationDelegate protocol
    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];    
    UIAlertView *pushNotfication = [[UIAlertView alloc] initWithTitle:@"Not Lost" message:[apsInfo objectForKey:@"alert"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [pushNotfication show];
    
    // Reset the badge after a push received (optional)
    [[UAPush shared] resetBadge];
}

@end
