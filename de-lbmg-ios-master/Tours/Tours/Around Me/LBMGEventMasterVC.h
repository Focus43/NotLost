//
//  LBMGEventMasterVC.h
//  Tours
//
//  Created by Alan Smithee on 4/25/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "TapItAdDelegates.h"

@interface LBMGEventMasterVC : LBMGNoRotateViewController <TapItInterstitialAdDelegate>

@property (strong, nonatomic) Event *event;
@property (weak, nonatomic) IBOutlet UIImageView *contentBackgroundImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (weak, nonatomic) IBOutlet UILabel *dateFromLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateToLabel;
// Info View
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIButton *website1Button;
@property (weak, nonatomic) IBOutlet UILabel *website1Label;
@property (weak, nonatomic) IBOutlet UIButton *website2Button;
@property (weak, nonatomic) IBOutlet UILabel *website2Label;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *imGoingButton;
@property (weak, nonatomic) IBOutlet UIButton *takeMeThereButton;

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)phoneButtonPressed:(id)sender;
- (IBAction)website1ButtonPressed:(id)sender;
- (IBAction)addressButtonPressed:(id)sender;

- (IBAction)goingButtonPressed:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIView *pickerView;
@property (strong, nonatomic) IBOutlet UIView *pickerContainer;
- (IBAction)cancelPickerPressed:(UIBarButtonItem *)sender;
- (IBAction)pickerDateSelected:(UIBarButtonItem *)sender;
- (IBAction)pickerValueChanged:(id)sender;

@end
