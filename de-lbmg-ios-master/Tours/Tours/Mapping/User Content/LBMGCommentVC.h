//
//  LBMGCommentViewController.h
//  Tours
//
//  Created by Alan Smithee on 4/9/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBMGCommentVC : LBMGNoRotateViewController
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) NSString *commentText;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;

- (IBAction)exitButtonPressed:(id)sender;

@end
