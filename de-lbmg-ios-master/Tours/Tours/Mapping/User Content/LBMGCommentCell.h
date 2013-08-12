//
//  LBMGCommentCell.h
//  Tours
//
//  Created by Alan Smithee on 4/9/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBMGCommentCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
@property (weak, nonatomic) IBOutlet UIImageView *highlightedImageView;

- (void)setCurrent:(BOOL)current;
@end
