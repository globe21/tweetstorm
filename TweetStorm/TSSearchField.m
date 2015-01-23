//
//  TSSearchField.m
//  TweetStorm
//
//  Created by Steven Chien on 1/20/15.
//  Copyright (c) 2015 stevenchien. All rights reserved.
//

#import "TSSearchField.h"

@implementation TSSearchField

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.leftViewMode = UITextFieldViewModeAlways;
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.keyboardAppearance = UIKeyboardAppearanceAlert;
        self.returnKeyType = UIReturnKeySearch;
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.placeholder = @"Search";
        self.font = [UIFont systemFontOfSize:14];
        [self.layer setCornerRadius:5.0f];
        [self.layer setBorderColor:[UIColor whiteColor].CGColor];
        [self.layer setBorderWidth:2.0f];
    }
    return self;
}

#pragma mark - Positioning

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 10, 6);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 10, 6);
}

#pragma mark - Sizing

- (void)setFrame:(CGRect)frame
{
    CGRect r = frame;
    r.size.height = 30;
    frame = r;
    
    [super setFrame:frame];
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    CGRect r = [super leftViewRectForBounds:bounds];
    r.origin.x = 8;
    return r;
}

@end
