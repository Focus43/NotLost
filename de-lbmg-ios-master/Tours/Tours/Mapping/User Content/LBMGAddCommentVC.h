//
//  LBMGAddCommentViewController.h
//  Tours
//
//  Created by Alan Smithee on 4/9/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface LBMGAddCommentVC : LBMGNoRotateViewController <UITextViewDelegate>
@property (strong, nonatomic) NSNumber *tourID;
@property (strong, nonatomic) CLLocation *userLocation;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic) int lastPointPassedIndex;
@property (nonatomic) float distFromPrevious;

- (IBAction)exitButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;

@end
