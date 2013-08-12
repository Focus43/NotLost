//
//  LBMGTourLibraryTBVCell.m
//  Tours
//
//  Created by Alan Smithee on 3/21/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGTourLibraryTBVCell.h"
#import <QuartzCore/QuartzCore.h>    

@implementation LBMGTourLibraryTBVCell

- (void)setTourName:(NSString *)aTourName
{
    if (_tourName != aTourName) {
        _tourName = aTourName;
        self.tourNameLabel.text = aTourName;
    }
}

- (void)setTourDistance:(NSNumber *)aTourDistance
{
    if (_tourDistance != aTourDistance) {
        _tourDistance = aTourDistance;
        self.tourDistanceLabel.text = [NSString stringWithFormat:@"%3.1f Miles", [aTourDistance floatValue]];
    }
}

- (void)animateForDuration:(CGFloat) duration {
    CGRect bounds = self.backgroundImageView.bounds;
    bounds.size.width = 0;
    self.backgroundImageView.layer.anchorPoint = CGPointMake(1.0, 0.5);
    self.backgroundColor = [UIColor clearColor];
    self.layer.anchorPoint = CGPointMake(1.0, 0.5);
    self.backgroundImageView.frame = CGRectMake(320, 0, bounds.size.width, bounds.size.height);
    self.backgroundImageView.bounds = bounds;
    CGSize size = [_tourName sizeWithFont:self.tourNameLabel.font];
    self.backgroundImageView.bounds = CGRectMake(0, 0, size.width+40, self.bounds.size.height);
    [self animateBack:duration];
}

- (void)animateBack:(CGFloat) duration  {
    self.backgroundImageView.layer.transform = CATransform3DIdentity;
    CABasicAnimation * anim = [CABasicAnimation animation];
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1.0 / -500;
    transform = CATransform3DRotate(transform, M_PI/2, 0.0f, 1.0f, 0.0f);
    anim.keyPath = @"transform";
    anim.fromValue = [NSValue valueWithCATransform3D:transform];
    anim.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    anim.duration = 0.75;
    anim.fillMode = kCAFillModeBoth;
    anim.beginTime = CACurrentMediaTime()+(duration-1);
    [self.layer addAnimation:anim forKey:@"transform"];
    
    
}

-(void)transformLayer:(CALayer *)layer {
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1.0 / -500;
    transform = CATransform3DTranslate(transform, -layer.bounds.size.width/2.0f, 0.0f, 0.0f);
    transform = CATransform3DRotate(transform, -M_PI/4, 0.0f, 1.0f, 0.0f);
    layer.transform = CATransform3DTranslate(transform, layer.bounds.size.width/2.0f, 0.0f, 0.0f);
};


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    if (selected) {
        self.backgroundImageView.image = [UIImage imageNamed:@"menu_tcell_slither_on"];
    } else {
        self.backgroundImageView.image = [UIImage imageNamed:@"menu_tcell_slither"];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.backgroundImageView.image = [UIImage imageNamed:@"menu_tcell_slither_on"];
    } else {
        self.backgroundImageView.image = [UIImage imageNamed:@"menu_tcell_slither"];
    }
}

@end
