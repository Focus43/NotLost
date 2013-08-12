//
//  LMGViewController.m
//  TourGuide
//
//  Created by Paul Warren on 8/30/12.
//  Copyright (c) 2012 LBMG. All rights reserved.
//

#import "LMGViewController.h"
#import "UserRoutes.h"
#import "Route.h"
#import "LMGMainMapViewController.h"

@interface LMGViewController ()

@property (nonatomic, strong) UserRoutes *routeData;

@end

@implementation LMGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self getData];
}

- (void)viewDidAppear:(BOOL)animated {
    Route *route = [self.routeData.routes objectAtIndex:0];
    LMGMainMapViewController  *map = [self.storyboard instantiateViewControllerWithIdentifier:@"mapVC"];
    map.route = route;
    
    [self presentModalViewController:map animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

-(void)getData
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"testRoutes" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    NSError *error = nil;
    
    if (jsonData) {
        
        id jsonObjects = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        
        if (error) {
            NSLog(@"error is %@", [error localizedDescription]);
            
            // Handle Error and return
            return;
            
        }
        
        self.routeData = [UserRoutes instanceFromDictionary:jsonObjects];
        
    } else {
        NSLog(@"Error");
    }
    
}

@end
