//
//  LBMGEventVC.h
//  Tours
//
//  Created by Alan Smithee on 3/21/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIToggleButton.h"
#import "Event.h"
#import "LBMGEventMasterVC.h"

@interface LBMGSponsoredEventVC : LBMGEventMasterVC <UIActionSheetDelegate, UIPickerViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) Event *event;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *contentBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;

// view option buttons
@property (weak, nonatomic) IBOutlet UIToggleButton *infoButton;
@property (weak, nonatomic) IBOutlet UIToggleButton *reviewButton;
@property (weak, nonatomic) IBOutlet UIToggleButton *mediaButton;

@property (weak, nonatomic) IBOutlet UITextView *descriptionLabel;

// Review view
@property (weak, nonatomic) IBOutlet UIView *reviewView;
@property (weak, nonatomic) IBOutlet UITableView *reviewsTableView;

// Media View
@property (weak, nonatomic) IBOutlet UIView *mediaView;
@property (weak, nonatomic) IBOutlet UICollectionView *mediaCollectionView;

- (IBAction)imGoingButtonPressed:(id)sender;
- (IBAction)infoButtonPressed:(id)sender;
- (IBAction)reviewButtonPressed:(id)sender;
- (IBAction)mediaButtonPressed:(id)sender;
- (IBAction)website2ButtonPressed:(id)sender;

@end
