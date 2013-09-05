//
//  UIScreen+isTall.m
//  Safari Scrolling
//
//  Created by Maximilian Litteral on 9/4/13.
//  Copyright (c) 2013 Maximilian Litteral. All rights reserved.
//

#import "UIScreen+isTall.h"

@implementation UIScreen (isTall)

- (BOOL)isTall {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return self.bounds.size.height > 480;
    }
    else {
        return NO;
    }
}

@end
