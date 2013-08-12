//
//  ArialBlackLabel.m
//  Tours
//
//  Created by Alan Smithee on 5/2/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "ArialBlackLabel.h"

@implementation ArialBlackLabel

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.font = [UIFont fontWithName:kMMODFontArialBlack size:self.font.pointSize];
    }
    return self;
}

@end
