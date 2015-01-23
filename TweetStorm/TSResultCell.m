//
//  TSResultCell.m
//  TweetStorm
//
//  Created by Steven Chien on 1/22/15.
//  Copyright (c) 2015 stevenchien. All rights reserved.
//

#import "TSResultCell.h"

@implementation TSResultCell

@synthesize username;
@synthesize tweet;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupCell];
    }
    return self;
}

- (void)setupCell
{
    self.username = [[UILabel alloc] initWithFrame:CGRectMake(10, 6, self.frame.size.width - 20, 20)];
    self.username.textColor = [UIColor blackColor];
    self.username.font = [UIFont boldSystemFontOfSize:14.0f];
    self.username.numberOfLines = 1;
    [self addSubview:self.username];
    
    self.tweet = [[UILabel alloc] initWithFrame:CGRectMake(10, 24, self.frame.size.width - 20, 20)];
    self.tweet.textColor = [UIColor grayColor];
    self.tweet.font = [UIFont systemFontOfSize:14.0f];
    self.tweet.numberOfLines = 0;
    [self addSubview:self.tweet];
}


@end
