//
//  main.m
//  Safari Scrolling
//
//  Created by Maximilian Litteral on 9/4/13.
//  Copyright (c) 2013 Maximilian Litteral. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ScrollingAppDelegate.h"

typedef int (*PYStdWriter)(void *, const char *, int);
static PYStdWriter _oldStdWrite;

int __pyStderrWrite(void *inFD, const char *buffer, int size)
{
    if ( strncmp(buffer, "AssertMacros:", 13) == 0 ) {
        return 0;
    }
    return _oldStdWrite(inFD, buffer, size);
}

int main(int argc, char * argv[])
{
    _oldStdWrite = stderr->_write;
    stderr->_write = __pyStderrWrite;
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([ScrollingAppDelegate class]));
    }
}
