//
//  LBMGAddCommentViewController.m
//  Tours
//
//  Created by Alan Smithee on 4/9/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGAddCommentVC.h"
#import "LBMGUtilities.h"

@interface LBMGAddCommentVC ()

@end

@implementation LBMGAddCommentVC

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
    [self.commentTextView becomeFirstResponder];
}

- (IBAction)exitButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    NSMutableDictionary *commentData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.commentTextView.text, @"comment", nil];
    NSString *latitude = [NSString stringWithFormat:@"%f", self.userLocation.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", self.userLocation.coordinate.longitude];
    [commentData setObject:latitude forKey:@"latitude"];
    [commentData setObject:longitude forKey:@"longitude"];
    [commentData setObject:[NSString stringWithFormat:@"%i", self.lastPointPassedIndex] forKey:@"lastPoint"];
    
    NSNumber *distance = [NSNumber numberWithDouble:self.distFromPrevious];
    [commentData setObject:distance forKey:@"distance"];

    [LBMGUtilities updateUserContentForTour:self.tourID withItem:commentData];
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
