//
//  LBMGPhotoCaptionViewController.h
//  Tours
//
//  Created by Alan Smithee on 4/8/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface LBMGPhotoCaptionVC : LBMGNoRotateViewController
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) double pointDistance;
@property (strong, nonatomic) NSString *previousPoint;
@property (strong, nonatomic) UIImage *thumbnailImage;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (strong, nonatomic) NSNumber *tourID;
@property (strong, nonatomic) NSString *imageFilename;

- (IBAction)exitButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;

@end
