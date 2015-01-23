//
//  ViewController.m
//  TweetStorm
//
//  Created by Steven Chien on 1/19/15.
//  Copyright (c) 2015 stevenchien. All rights reserved.
//

#import "TSViewController.h"
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "TSHeader.h"
#import "TSSearchField.h"
#import "TSResultCell.h"

@interface TSViewController ()

@property (nonatomic, strong) UITableView *streamTableView;
@property (nonatomic, strong) TSSearchField *searchField;
@property (nonatomic, strong) NSURLConnection *twitterConnection;
@property (nonatomic, strong) NSMutableArray *arrayOfResults;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) UILabel *firstTimeSearchLabel;
@property (nonatomic, assign) BOOL cellsLoaded;

@end

@implementation TSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
    [self setupTableView];
    [self setupLabel];
    self.arrayOfResults = [[NSMutableArray alloc] initWithCapacity:1];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Tap anywhere on the screen when typing to dismiss keyboard
- (void)dismissKeyboard
{
    [self.searchField resignFirstResponder];
    [self.view endEditing:YES];
}

#pragma mark - Setup Navigation Bar

- (void)setupNavigationBar
{
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:TWITTER_RED_COLOR green:TWITTER_GREEN_COLOR blue:TWITTER_BLUE_COLOR alpha:1.0f];
    
    self.searchField = [[TSSearchField alloc] initWithFrame:CGRectMake(0, 6, 200, 44)];
    self.searchField.delegate = self;
    self.searchField.frame = CGRectMake(0, 6, 200, 44);
    
    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    [searchView addSubview:self.searchField];
    
    self.navigationItem.titleView = searchView;
}

#pragma mark - Setup UITableView
- (void)setupTableView
{
    CGRect tableRect = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    UITableView *table = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
    table.backgroundColor = [UIColor whiteColor];
    table.dataSource = self;
    table.delegate = self;
    table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    table.clipsToBounds = YES;
    table.showsVerticalScrollIndicator = NO;
    table.scrollsToTop = YES;
    self.streamTableView = table;
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.streamTableView.bounds.size.width, 64)];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = footer.center;
    self.loadingIndicator = indicator;
    [footer addSubview:self.loadingIndicator];
    
    self.streamTableView.tableFooterView = footer;
    
    [self.view addSubview:self.streamTableView];
    self.automaticallyAdjustsScrollViewInsets = YES;
}

#pragma mark - Setup FirstTimeSearchLabel
- (void)setupLabel
{
    self.firstTimeSearchLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.firstTimeSearchLabel.center = self.view.center;
    self.firstTimeSearchLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    self.firstTimeSearchLabel.text = @"Search Tweets by typing in a keyword!";
    self.firstTimeSearchLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.firstTimeSearchLabel];
}

#pragma mark - TSSearchFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.cellsLoaded = NO;
    self.firstTimeSearchLabel.hidden = YES;
    [self.arrayOfResults removeAllObjects];
    [self.streamTableView reloadData];
    [self.loadingIndicator startAnimating];
    [self.twitterConnection cancel];
    [self performSearchWithQuery:textField.text];
    [textField resignFirstResponder];
    [self.view endEditing:YES];
    return NO;
}

#pragma mark - UITableView Delegate and Datasource Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TSResultCell *cell = [self.streamTableView dequeueReusableCellWithIdentifier:@"TWEETCELL"];
    if (cell == nil) {
        cell = [[TSResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TWEETCELL"];
    }
    cell.username.text = [[[self.arrayOfResults objectAtIndex:indexPath.row] objectForKey:TWEETUSER] objectForKey:TWEETUSERNAME];
    CGRect r = cell.tweet.frame;
    r.size.height = [[[self.arrayOfResults objectAtIndex:indexPath.row] objectForKey:TWEETTEXT] sizeWithFont:[UIFont systemFontOfSize:14.0f]
                                                                                            constrainedToSize:CGSizeMake(self.view.bounds.size.width - 20, 1000)
                                                                                                lineBreakMode:NSLineBreakByWordWrapping].height;
    cell.tweet.frame = r;
    cell.tweet.text = [[self.arrayOfResults objectAtIndex:indexPath.row] objectForKey:TWEETTEXT];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize labelSize = [[[self.arrayOfResults objectAtIndex:indexPath.row] objectForKey:TWEETTEXT] sizeWithFont:[UIFont systemFontOfSize:14.0f]
                                                                                  constrainedToSize:CGSizeMake(self.view.bounds.size.width - 20, 1000)
                                                                                      lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat labelHeight = labelSize.height;
    return labelHeight + 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.cellsLoaded) {
        return [self.arrayOfResults count];
    }
    else {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.cellsLoaded) {
        return 1;
    }
    else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

#pragma mark - Search With Query

- (void)performSearchWithQuery:(NSString *)queryString
{
    //First, we need to obtain the account instance for the user's Twitter account
    ACAccountStore *store = [[ACAccountStore alloc] init];
    ACAccountType *twitterAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    //  Request permission from the user to access the available Twitter accounts
    [store requestAccessToAccountsWithType:twitterAccountType
                     withCompletionHandler:^(BOOL granted, NSError *error) {
                         if (!granted) {
                             // The user rejected access to account
                             [self.loadingIndicator stopAnimating];
                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Please allow access to your Twitter account. Go to your phone's Settings > Twitter to proceed" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                             [alert show];
                         }
                         else {
                             // Grab the available accounts
                             NSArray *twitterAccounts = [store accountsWithAccountType:twitterAccountType];
                             if ([twitterAccounts count] > 0) {
                                 // Use the first account for simplicity
                                 ACAccount *account = [twitterAccounts objectAtIndex:0];
                                 NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                                 [params setObject:@"true" forKey:@"stall_warnings"];
                                 [params setObject:queryString forKey:@"track"];
                                 NSURL *url = [NSURL URLWithString:@"https://stream.twitter.com/1.1/statuses/filter.json"];
                                 
                                 //  Build the request with our parameter
                                 TWRequest *request = [[TWRequest alloc] initWithURL:url
                                                                          parameters:params
                                                                       requestMethod:TWRequestMethodPOST];
                                 
                                 // Attach the account object to this request
                                 [request setAccount:account];
                                 NSURLRequest *signedReq = request.signedURLRequest;
                                 
                                 // make the connection, ensuring that it is made on the main runloop
                                 self.twitterConnection = [[NSURLConnection alloc] initWithRequest:signedReq delegate:self startImmediately: NO];
                                 [self.twitterConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                                                   forMode:NSDefaultRunLoopMode];
                                 [self.twitterConnection start];
                                 
                             }
                             else {
                                 [self.loadingIndicator stopAnimating];
                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Please add your Twitter account under your phone's Settings > Twitter to proceed" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                                 [alert show];
                             }
                         }
                     }];
}

#pragma mark - NSURLConnection methods

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSURLCredential *cred = [[NSURLCredential alloc] initWithUser:@"USERNAME" password:@"PASSWORD" persistence:NSURLCredentialPersistencePermanent];
    [[challenge sender] useCredential:cred forAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{    
    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingAllowFragments
                                                           error:&error];
    self.cellsLoaded = YES;
    [self.loadingIndicator stopAnimating];
    if (json) {
        [self.arrayOfResults insertObject:json atIndex:0];
        if ([self.arrayOfResults count] == 1) {
            [self.streamTableView reloadData];
        }
        else {
            [self.streamTableView beginUpdates];
            [self.streamTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            [self.streamTableView endUpdates];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.loadingIndicator stopAnimating];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:[error.userInfo objectForKey:@"NSLocalizedDescription"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}


@end
