//
//  LBMGPhotoCaptionViewController.m
//  Tours
//
//  Created by Alan Smithee on 4/8/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGPhotoCaptionVC.h"
#import "LBMGUtilities.h"

@interface LBMGPhotoCaptionVC ()

@end

@implementation LBMGPhotoCaptionVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.captionTextView becomeFirstResponder];
    self.thumbnailImageView.image = self.thumbnailImage;
}

- (IBAction)exitButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSMutableDictionary *photoData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.imageFilename, @"photo", nil];
    
    NSString *latitude = [NSString stringWithFormat:@"%f", self.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", self.longitude];
    [photoData setObject:latitude forKey:@"latitude"];
    [photoData setObject:longitude forKey:@"longitude"];
    [photoData setObject:self.previousPoint forKey:@"lastPoint"];
    
    NSNumber *distance = [NSNumber numberWithDouble:self.pointDistance];
    [photoData setObject:distance forKey:@"distance"];
    
    [LBMGUtilities updateUserContentForTour:self.tourID withItem:photoData];
}

- (IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // store image name and caption if there is text
    NSMutableDictionary *photoData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.imageFilename, @"photo", nil];
    NSString *latitude = [NSString stringWithFormat:@"%f", self.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", self.longitude];
    [photoData setObject:latitude forKey:@"latitude"];
    [photoData setObject:longitude forKey:@"longitude"];
    [photoData setObject:self.previousPoint forKey:@"lastPoint"];
    
    NSNumber *distance = [NSNumber numberWithDouble:self.pointDistance];
    [photoData setObject:distance forKey:@"distance"];
    
    if ([self.captionTextView.text length] > 0) {
        [photoData setObject:self.captionTextView.text forKey:@"caption"];
    }
    
    [LBMGUtilities updateUserContentForTour:self.tourID withItem:photoData];
}

#pragma mark - UITextView Delegate Mthods
- (void)textViewDidChange:(UITextView *)textView {
    if ([textView.text length] > 0) {
        self.doneButton.hidden = NO;
    }
    else {
        self.doneButton.hidden = YES;
    }
}

@end
