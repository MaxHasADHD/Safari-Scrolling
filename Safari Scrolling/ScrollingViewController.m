//
//  ScrollingViewController.m
//  Safari Scrolling
//
//  Created by Maximilian Litteral on 9/4/13.
//  Copyright (c) 2013 Maximilian Litteral. All rights reserved.
//

#import "ScrollingViewController.h"

#import "UIScreen+isTall.h"

#import "CustomTextField.h"

#define UNIBAR_DEFAULT_X 12
#define UNIBAR_DEFAULT_Y 24
#define UNIBAR_DEFAULT_WIDTH ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait ? 297 : [UIScreen mainScreen].isTall == YES ? 545 : 457)
#define UNIBAR_DEFAULT_WIDTH_WITH(ORIENTATION) (ORIENTATION == UIInterfaceOrientationPortrait ? 297 : [UIScreen mainScreen].isTall == YES ? 545 : 457)
#define UNIBAR_DEFAULT_HEIGHT 29

#define UNIBAR_FINISHED_X 56
#define UNIBAR_FINISHED_Y 17
#define UNIBAR_FINISHED_WIDTH ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait ? 208 : [UIScreen mainScreen].isTall == YES ? 456 : 368)
#define UNIBAR_FINISHED_HEIGHT 20

#define kNavigationBarAnimationTime 0.2

#define SCREEN_HEIGHT ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)
#define SCREEN_WIDTH ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)
    
#define SCREEN_HEIGHT_WITH(ORIENTATION) (ORIENTATION == UIInterfaceOrientationPortrait ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)
#define SCREEN_WIDTH_WITH(ORIENTATION) (ORIENTATION == UIInterfaceOrientationPortrait ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)
    
#define DeviceOrientation [[UIApplication sharedApplication] statusBarOrientation]

@interface ScrollingViewController () <UIWebViewDelegate, UIScrollViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>

@end

@implementation ScrollingViewController
{
    
    //nav
    UINavigationBar *navigationBar;
    CustomTextField *addressTextField;
    BOOL addressTextFieldEditing;
    UIButton *cancelButton;
    BOOL userScrolling;
    BOOL toolbarUpInMiddleOfPageNowScrollingDown;
    
    //Toolbar
    UIToolbar *toolbar;
    
    //web
    UIWebView *webViewObject;
    
    //Scrolling
    CGPoint previousScrollOffset;
    CGPoint initialScrollOffset;
    BOOL skipScrolling;
    
}

#pragma mark - uniBar

- (void)cancel {
    addressTextField.selectedTextRange = nil;
    [addressTextField resignFirstResponder];
    [self unibarStopEditing];
}

- (void)updateUnibar {
    addressTextField.placeholder = [NSString stringWithFormat:NSLocalizedString(@"Search or enter an address", @"Search or enter an address")];
}

- (void)unibarStopEditing {
    if ([addressTextField isFirstResponder]) [addressTextField resignFirstResponder];
    
    addressTextField.textAlignment = NSTextAlignmentCenter;
    addressTextField.clearButtonMode = UITextFieldViewModeNever;
    
    [UIView animateWithDuration:kNavigationBarAnimationTime animations:^{
        [self showNavigationBarAtFullHeight];
        cancelButton.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        addressTextField.refreshButton.hidden = NO;
        addressTextField.rightViewMode = UITextFieldViewModeAlways;
        addressTextFieldEditing = YES;
    }];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.frame.size.height == UNIBAR_FINISHED_HEIGHT) {
        [UIView animateWithDuration:kNavigationBarAnimationTime animations:^{
            [self showNavigationBarAtFullHeight];
            toolbar.frame = CGRectMake(0, SCREEN_HEIGHT-44, SCREEN_WIDTH, 44);
        }];
        
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    addressTextFieldEditing = YES;
    addressTextField.refreshButton.hidden = YES;
    addressTextField.rightViewMode = UITextFieldViewModeNever;
    addressTextField.textAlignment = NSTextAlignmentLeft;
    
    addressTextField.clearButtonMode = UITextFieldViewModeAlways;
    
    // Get current selected range , this example assumes is an insertion point or empty selection
    UITextRange *selectedRange = [textField selectedTextRange];
    
    // Calculate the new position, - for left and + for right
    UITextPosition *newPosition = [textField positionFromPosition:selectedRange.start offset:-textField.text.length];
    
    // Construct a new range using the object that adopts the UITextInput, our textfield
    UITextRange *newRange = [textField textRangeFromPosition:newPosition toPosition:selectedRange.start];
    
    // Set new range
    [textField setSelectedTextRange:newRange];
    
    [UIView animateWithDuration:kNavigationBarAnimationTime animations:^{
        [self showNavigationBarAtFullHeight];
        CGRect unibarFrame = addressTextField.frame;
        unibarFrame.size.width = unibarFrame.size.width-60;
        addressTextField.frame = unibarFrame;
        cancelButton.alpha = 1.0;
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

#pragma mark - Scrollview Delegate

- (void)showNavigationBarAtFullHeight {
    
    //Navigation
    navigationBar.frame = CGRectMake(0, 0, SCREEN_WIDTH, 64);
    
    //Address Bar
    addressTextField.frame = CGRectMake(UNIBAR_DEFAULT_X, UNIBAR_DEFAULT_Y, UNIBAR_DEFAULT_WIDTH, UNIBAR_DEFAULT_HEIGHT);
    addressTextField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    ((UIView *)addressTextField.subviews[0]).alpha = 1.0;
    
    addressTextField.refreshButton.alpha = 1.0;
    addressTextField.refreshButton.frame = CGRectMake(addressTextField.frame.size.width-29, 0, 29, 29);
    
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    NSLog(@"scrolling to top!");
    [self showNavigationBarAtFullHeight];
    webViewObject.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    userScrolling = YES;
    initialScrollOffset = scrollView.contentOffset;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!userScrolling) return;
    if (scrollView.contentSize.height <= SCREEN_HEIGHT) {
        //Page is less than/= to the screens height, no need to scroll anything.
        webViewObject.frame =  CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64);
        [self showNavigationBarAtFullHeight];
        toolbar.frame = CGRectMake(0, SCREEN_HEIGHT-44, SCREEN_WIDTH, 44);
        
        [[webViewObject scrollView] setContentInset:UIEdgeInsetsMake(0, 0, 68, 0)];
        [[webViewObject scrollView] setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 68, 0)];
        return;
    }
    else [[webViewObject scrollView] setContentInset:UIEdgeInsetsMake(0, 0, 44, 0)];
    
    if (scrollView.contentOffset.y <= 0) {
        //Scrolling above the page
        
        [self showNavigationBarAtFullHeight];
        toolbar.frame = CGRectMake(0, SCREEN_HEIGHT-44, SCREEN_WIDTH, 44);
        webViewObject.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64);
    }
    
    CGFloat contentOffset = scrollView.contentOffset.y-initialScrollOffset.y;
    if (scrollView.contentOffset.y <= 24) {
        contentOffset = scrollView.contentOffset.y;
    }
    else {
        if (contentOffset < 0 && (scrollView.contentOffset.y-previousScrollOffset.y) > 0) {
            initialScrollOffset = scrollView.contentOffset;
        }
    }
    contentOffset = roundf(contentOffset);
    if (contentOffset <= 24 && contentOffset >= 0) {
        //perform the animation if the offset of current position is less than/= to 24. but above 0
        CGRect navFrame = navigationBar.frame;
        if (scrollView.contentOffset.y < previousScrollOffset.y) {
            //up
            if (navFrame.size.height == 64) {
                skipScrolling = YES;
            }
        }
        
        if (navFrame.size.height == 40 && scrollView.contentOffset.y > 24) {
            //if the height is 40 already, skip.
            skipScrolling = YES;
        }
        
        if (skipScrolling == NO) {
            //If everything else passes and skip scrolling = NO, perform scrolling animation
            navFrame.size.height = 64 -  contentOffset;
            if (navFrame.size.height <=64 && navFrame.size.height >= 40) {
                
                navigationBar.frame = navFrame;
                webViewObject.frame = CGRectMake(0, 64-(64-navFrame.size.height), SCREEN_WIDTH, SCREEN_HEIGHT-(64-(64-navFrame.size.height)));
                
                CGFloat XOffset =(contentOffset-2)*2;
                if (XOffset < 0) {
                    XOffset=0;
                }
                CGFloat X = 12+XOffset;
                
                CGFloat Y = UNIBAR_DEFAULT_Y - (contentOffset/3.42857143);
                
                CGFloat widthOffset = (contentOffset-2)*4.04545455;
                if (widthOffset < 0) {
                    widthOffset=0;
                }
                CGFloat width = UNIBAR_DEFAULT_WIDTH-widthOffset;
                
                //29 to 20
                CGFloat height = UNIBAR_DEFAULT_HEIGHT-(contentOffset/2.66666667);
                
                addressTextField.frame = CGRectMake(X, Y, width, height);
                //Font and alpha
                addressTextField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:navFrame.size.height/3.764];
                ((UIView *)addressTextField.subviews[0]).alpha = 1.0-((64-navFrame.size.height)*(1.0/24));
                addressTextField.refreshButton.alpha = 1.0-((64-navFrame.size.height)*(1.0/24));
                
            }
        }
    }
    else if (contentOffset > 24) {
        //Scrolled past the initial animation point. Small navigation bar
        navigationBar.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
        addressTextField.frame = CGRectMake(UNIBAR_FINISHED_X, UNIBAR_FINISHED_Y, UNIBAR_FINISHED_WIDTH, UNIBAR_FINISHED_HEIGHT);
        addressTextField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
        ((UIView *)addressTextField.subviews[0]).alpha = 0;
        addressTextField.refreshButton.alpha = 0.0;
        addressTextField.refreshButton.frame = CGRectMake(179, -5, 29, 29);
        webViewObject.frame = CGRectMake(0, 40, SCREEN_WIDTH, SCREEN_HEIGHT-40);
    }
    if (scrollView.contentOffset.y <= 0) {
        navigationBar.frame = CGRectMake(0, 0, SCREEN_WIDTH, 64);
        addressTextField.frame = CGRectMake(UNIBAR_DEFAULT_X, UNIBAR_DEFAULT_Y, UNIBAR_DEFAULT_WIDTH, UNIBAR_DEFAULT_HEIGHT);
        addressTextField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
        ((UIView *)addressTextField.subviews[0]).alpha = 1;
        webViewObject.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64);
    }
    
    //Toolbar
    if (scrollView.contentOffset.y >= 0 && scrollView.contentOffset.y <= 44) {
        if (scrollView.contentOffset.y < previousScrollOffset.y && toolbar.frame.origin.y == SCREEN_HEIGHT-44) {
            //Up
            return;
        }
        toolbarUpInMiddleOfPageNowScrollingDown = NO;
        //Scrolling near the top
        CGRect toolbarFrame = toolbar.frame;
        toolbarFrame.origin.y = (SCREEN_HEIGHT-44) + scrollView.contentOffset.y;
        toolbar.frame = toolbarFrame;
        
        CGFloat bottomInset = 44-scrollView.contentOffset.y;
        if (bottomInset > 0 && bottomInset <= 64) {
            //[[webViewObject scrollView] setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, bottomInset+((webViewObject.frame.origin.y+528)-SCREEN_HEIGHT), 0)];
            [[webViewObject scrollView] setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, bottomInset, 0)];
        }
    }
    else if ((scrollView.contentOffset.y >= 45 && toolbar.frame.origin.y == SCREEN_HEIGHT-44) || toolbarUpInMiddleOfPageNowScrollingDown) {
        if (scrollView.contentOffset.y < previousScrollOffset.y) {
            //Up
        }
        else {
            //Down
            toolbarUpInMiddleOfPageNowScrollingDown = YES;
            CGRect toolbarFrame = toolbar.frame;
            toolbarFrame.origin.y = (SCREEN_HEIGHT-44) + contentOffset;
            toolbar.frame = toolbarFrame;
            if (toolbarFrame.origin.y == SCREEN_HEIGHT) {
                toolbarUpInMiddleOfPageNowScrollingDown = NO;
            }
            
        }
    }
    else if (scrollView.contentOffset.y >= 45) {
        if (scrollView.contentOffset.y < previousScrollOffset.y) {
            //Up
        }
        else {
            //Down
            NSLog(@"down 2");
            toolbar.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 44);
            [[webViewObject scrollView] setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
    }
    else if (scrollView.contentOffset.y < 0) {
        [[webViewObject scrollView] setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 44, 0)];
    }
    
    //Bottom of page
    CGFloat fromBottomOffset = ((scrollView.contentOffset.y+webViewObject.frame.size.height)-scrollView.contentSize.height);
    if (scrollView.contentOffset.y + webViewObject.frame.size.height >= scrollView.contentSize.height && fromBottomOffset <=44) {
        toolbar.frame = CGRectMake(0, SCREEN_HEIGHT-fromBottomOffset, SCREEN_WIDTH, 44);
        [[webViewObject scrollView] setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, fromBottomOffset, 0)];
    }
    else if (fromBottomOffset > 44) {
        toolbar.frame = CGRectMake(0, SCREEN_HEIGHT-44, SCREEN_WIDTH, 44);
        [[webViewObject scrollView] setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 44, 0)];
    }
    
    if (scrollView.contentOffset.y+scrollView.frame.size.height <= scrollView.contentSize.height) {
        previousScrollOffset = scrollView.contentOffset;
    }
    
    skipScrolling = NO;
}


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (velocity.y < -2) {
        userScrolling = NO;
        if (navigationBar.frame.size.height == 40) {
            
            [UIView animateWithDuration:kNavigationBarAnimationTime animations:^{
                [self showNavigationBarAtFullHeight];
                toolbar.frame = CGRectMake(0, SCREEN_HEIGHT-44, SCREEN_WIDTH, 44);
                webViewObject.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64);
            }];
        }
    }
    
    /*if (navigationBar.frame.size.height <= 52) {
     [UIView animateWithDuration:0.2 animations:^{
     navigationBar.frame = CGRectMake(0, 0, 320, 40);
     webProgress.frame = CGRectMake(0, _navigationBar.frame.size.height-2, SCREEN_WIDTH, 2);
     uniBar.frame = CGRectMake(UNIBAR_FINISHED_X, UNIBAR_FINISHED_Y, UNIBAR_FINISHED_WIDTH, UNIBAR_FINISHED_HEIGHT);
     uniBar.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
     ((UIView *)uniBar.subviews[0]).alpha = 0;
     webViewObject.frame = CGRectMake(0, 40, 320, 528);
     }];
     }*/
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    userScrolling = NO;
    initialScrollOffset = CGPointMake(0, 0);
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH_WITH(currentOrientation), 64)];
    navigationBar.translucent = YES;
    [self.view addSubview:navigationBar];
    
    //Cancel Button
    cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelButton.frame = CGRectMake(SCREEN_WIDTH_WITH(currentOrientation)- 60, UNIBAR_DEFAULT_Y, 55, UNIBAR_DEFAULT_HEIGHT);
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:NSLocalizedString(@"Cancel", @"Cancel") forState:UIControlStateNormal];
    cancelButton.alpha = 0.0;
    [navigationBar addSubview:cancelButton];
    
    //unibar
    addressTextField = [[CustomTextField alloc] initWithFrame:CGRectMake(UNIBAR_DEFAULT_X, UNIBAR_DEFAULT_Y, UNIBAR_DEFAULT_WIDTH_WITH(currentOrientation), UNIBAR_DEFAULT_HEIGHT)];
    addressTextField.delegate = self;
    addressTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    addressTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    addressTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    addressTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    addressTextField.returnKeyType = UIReturnKeyGo;
    addressTextField.adjustsFontSizeToFitWidth = YES;
    addressTextField.keyboardType = UIKeyboardTypeWebSearch;
    addressTextField.placeholder = NSLocalizedString(@"Search or enter an address", @"Search or enter an address");
    addressTextField.rightViewMode = UITextFieldViewModeUnlessEditing;
    [navigationBar addSubview:addressTextField];
    
    webViewObject = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH_WITH(currentOrientation), SCREEN_HEIGHT_WITH(currentOrientation)-64)];
    
    webViewObject.clipsToBounds = NO;
    webViewObject.scrollView.clipsToBounds = NO;
    [webViewObject loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]]];
    [[webViewObject scrollView] setContentInset:UIEdgeInsetsMake(0, 0, 44, 0)];
    [[webViewObject scrollView] setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 44, 0)];
    webViewObject.delegate = self;
    webViewObject.scrollView.delegate = self;
    webViewObject.scalesPageToFit = YES;
    webViewObject.allowsInlineMediaPlayback = YES;
    webViewObject.backgroundColor = [UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.000];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    singleTap.delegate = self;
    [webViewObject addGestureRecognizer:singleTap];
    
    [self.view addSubview:webViewObject];
    [self.view sendSubviewToBack:webViewObject];
    
    //Toolbar
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-44, SCREEN_WIDTH, 44)];
    toolbar.barStyle = UIBarStyleDefault;
    toolbar.translucent = YES;
    [self.view insertSubview:toolbar aboveSubview:toolbar];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture {
    CGPoint touchPoint=[gesture locationInView:webViewObject];
    if (CGRectContainsPoint(CGRectMake(0, webViewObject.frame.size.height-44, SCREEN_WIDTH, 44), touchPoint)) {
        [UIView animateWithDuration:kNavigationBarAnimationTime animations:^{
            
            [self showNavigationBarAtFullHeight];
            
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
