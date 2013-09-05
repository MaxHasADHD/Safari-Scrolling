//
//  CustomTextField.m
//  Safari Scrolling
//
//  Created by Maximilian Litteral on 9/4/13.
//  Copyright (c) 2013 Maximilian Litteral. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField
{
    UIButton *_refreshButton;
}

#pragma mark - Setup

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.borderStyle = UITextBorderStyleRoundedRect;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.textAlignment = NSTextAlignmentCenter;
        self.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
        _refreshButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _refreshButton.frame = CGRectMake(_refreshButton.frame.origin.x, _refreshButton.frame.origin.y, 29, 29);
        _refreshButton.backgroundColor = [UIColor clearColor];
        [_refreshButton setImage:[[UIImage imageNamed:@"NavigationBarReload"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        self.rightView = _refreshButton;
        self.rightView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        
    }
    return self;
}


- (CGRect)textRectForBounds:(CGRect)bounds {
    if (self.textAlignment == NSTextAlignmentCenter) {
        int margin = 29;
        CGRect inset = CGRectMake(bounds.origin.x + margin, bounds.origin.y, bounds.size.width - (margin*2), bounds.size.height);
        return inset;
    }
    else {
        int margin = 29;
        CGRect inset = CGRectMake(bounds.origin.x+5, bounds.origin.y, (bounds.size.width - margin) - 5, bounds.size.height);
        return inset;
    }
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    int margin = 29;
    CGRect inset = CGRectMake(bounds.origin.x+5, bounds.origin.y, (bounds.size.width - margin) - 5, bounds.size.height);
    return inset;
}

@end
