//
//  AppDelegate.m
//  TweetStorm
//
//  Created by Steven Chien on 1/19/15.
//  Copyright (c) 2015 stevenchien. All rights reserved.
//

#import "TSAppDelegate.h"
#import "TSViewController.h"
#import "TSHeader.h"
#import <QuartzCore/QuartzCore.h>

@interface TSAppDelegate ()

@property (nonatomic, strong) CALayer *mask;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *cloud1;
@property (nonatomic, strong) UIImageView *cloud2;
@property (nonatomic, strong) UIImageView *lightning1;
@property (nonatomic, strong) UIImageView *lightning2;
@property (nonatomic, strong) UILabel *appLabel;
@property (nonatomic, strong) UINavigationController *nav;

@end

@implementation TSAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    TSViewController *ts = [[TSViewController alloc] init];
    self.nav = [[UINavigationController alloc] initWithRootViewController:ts];
    self.nav.view.frame = self.window.frame;
    self.window.rootViewController = self.nav;
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.window.frame];
    self.imageView.backgroundColor = [UIColor whiteColor];
    
    self.cloud1 = [[UIImageView alloc] initWithFrame:CGRectMake(-self.imageView.bounds.size.width / 2, 0, self.imageView.bounds.size.width / (1.5), [UIImage imageNamed:@"Cloud"].size.height / 2)];
    self.cloud1.backgroundColor = [UIColor clearColor];
    self.cloud1.image = [UIImage imageNamed:@"Cloud"];
    self.cloud1.contentMode = UIViewContentModeScaleAspectFit;
    
    self.cloud2 = [[UIImageView alloc] initWithFrame:CGRectMake((self.imageView.bounds.size.width / 2) * 3, 0, self.imageView.bounds.size.width / (1.5), [UIImage imageNamed:@"Cloud"].size.height / 2)];
    self.cloud2.backgroundColor = [UIColor clearColor];
    self.cloud2.image = [UIImage imageNamed:@"Cloud"];
    self.cloud2.contentMode = UIViewContentModeScaleAspectFit;
    
    self.lightning1 = [[UIImageView alloc] initWithFrame:CGRectMake(-self.imageView.bounds.size.width / 2, 0, [UIImage imageNamed:@"Lightning"].size.width / 3, [UIImage imageNamed:@"Lightning"].size.height / 3)];
    self.lightning1.center = self.cloud1.center;
    self.lightning1.backgroundColor = [UIColor clearColor];
    self.lightning1.image = [UIImage imageNamed:@"Lightning"];
    self.lightning1.contentMode = UIViewContentModeScaleAspectFit;
    
    self.lightning2 = [[UIImageView alloc] initWithFrame:CGRectMake((self.imageView.bounds.size.width / 2) * 3, 0, [UIImage imageNamed:@"Lightning"].size.width / 3, [UIImage imageNamed:@"Lightning"].size.height / 3)];
    self.lightning2.center = self.cloud2.center;
    self.lightning2.backgroundColor = [UIColor clearColor];
    self.lightning2.image = [UIImage imageNamed:@"Lightning"];
    self.lightning2.contentMode = UIViewContentModeScaleAspectFit;
    
    self.appLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, 60)];
    self.appLabel.center = self.window.center;
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"TWEETSTORM" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:TWITTER_RED_COLOR green:TWITTER_GREEN_COLOR blue:TWITTER_BLUE_COLOR alpha:1.0f]}];
    self.appLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    self.appLabel.attributedText = title;
    self.appLabel.textAlignment = NSTextAlignmentCenter;
    [self.imageView addSubview:self.appLabel];
    self.appLabel.alpha = 0.0f;
    
    [self.imageView addSubview:self.lightning1];
    [self.imageView addSubview:self.lightning2];
    [self.imageView addSubview:self.cloud1];
    [self.imageView addSubview:self.cloud2];
    
    [self.nav.view addSubview:self.imageView];
    
    [self animateSplash];
    
    [self.window makeKeyAndVisible];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)animateSplash
{
    //cloud 1 moving from left to right animation
    CAKeyframeAnimation *moveAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    UIBezierPath *particlePath = [UIBezierPath bezierPath];
    [particlePath moveToPoint:self.cloud1.layer.position];
    [particlePath addQuadCurveToPoint:CGPointMake(self.imageView.bounds.size.width / 3, self.cloud1.layer.position.y)
                         controlPoint:self.cloud1.layer.position];
    moveAnim.path = particlePath.CGPath;
    moveAnim.delegate = self;
    moveAnim.fillMode=kCAFillModeForwards;
    moveAnim.duration = 1;
    moveAnim.beginTime = CACurrentMediaTime();
    moveAnim.removedOnCompletion = NO;
    NSArray *timingFunctions = [NSArray arrayWithObjects:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],nil];
    [moveAnim setTimingFunctions:timingFunctions];
    [self.cloud1.layer addAnimation:moveAnim forKey:@"cloud1"];
    
    //cloud 2 moving from right to left animation
    CAKeyframeAnimation *moveAnim2 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    UIBezierPath *particlePath2 = [UIBezierPath bezierPath];
    [particlePath2 moveToPoint:self.cloud2.layer.position];
    [particlePath2 addQuadCurveToPoint:CGPointMake((self.imageView.bounds.size.width / 3) * 2, self.cloud2.layer.position.y)
                         controlPoint:self.cloud2.layer.position];
    moveAnim2.path = particlePath2.CGPath;
    moveAnim2.delegate = self;
    moveAnim2.fillMode=kCAFillModeForwards;
    moveAnim2.duration = 1;
    moveAnim2.beginTime = CACurrentMediaTime();
    moveAnim2.removedOnCompletion = NO;
    NSArray *timingFunctions2 = [NSArray arrayWithObjects:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],nil];
    [moveAnim2 setTimingFunctions:timingFunctions2];
    [self.cloud2.layer addAnimation:moveAnim2 forKey:@"cloud2"];
    
    //lightning bolt 1 move animation coinciding with the cloud 1 movement
    CAKeyframeAnimation *moveAnim3 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    UIBezierPath *particlePath3 = [UIBezierPath bezierPath];
    [particlePath3 moveToPoint:self.lightning1.layer.position];
    [particlePath3 addQuadCurveToPoint:CGPointMake(self.imageView.bounds.size.width / 3, self.lightning1.layer.position.y)
                         controlPoint:self.lightning1.layer.position];
    moveAnim3.path = particlePath3.CGPath;
    moveAnim3.delegate = self;
    moveAnim3.fillMode=kCAFillModeForwards;
    moveAnim3.duration = 1;
    moveAnim3.beginTime = CACurrentMediaTime() + 0.2;
    moveAnim3.removedOnCompletion = NO;
    NSArray *timingFunctions3 = [NSArray arrayWithObjects:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],nil];
    [moveAnim3 setTimingFunctions:timingFunctions3];
    [self.lightning1.layer addAnimation:moveAnim3 forKey:@"lightning1"];
    
    //lightning bolt 2 move animation coinciding with the cloud 2 movement
    CAKeyframeAnimation *moveAnim4 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    UIBezierPath *particlePath4 = [UIBezierPath bezierPath];
    [particlePath4 moveToPoint:self.lightning2.layer.position];
    [particlePath4 addQuadCurveToPoint:CGPointMake(self.imageView.bounds.size.width / 3, self.lightning2.layer.position.y)
                          controlPoint:self.lightning2.layer.position];
    moveAnim4.path = particlePath4.CGPath;
    moveAnim4.delegate = self;
    moveAnim4.fillMode=kCAFillModeForwards;
    moveAnim4.duration = 1;
    moveAnim4.beginTime = CACurrentMediaTime() + 0.2;
    moveAnim4.removedOnCompletion = NO;
    NSArray *timingFunctions4 = [NSArray arrayWithObjects:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],nil];
    [moveAnim4 setTimingFunctions:timingFunctions4];
    [self.lightning2.layer addAnimation:moveAnim4 forKey:@"lightning2"];
    
    //lightning bolt 1 from left to right diagonal projection animation
    CAKeyframeAnimation *moveAnim5 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    UIBezierPath *particlePath5 = [UIBezierPath bezierPath];
    [particlePath5 moveToPoint:CGPointMake(self.imageView.bounds.size.width / 3, self.lightning1.layer.position.y)];
    [particlePath5 addQuadCurveToPoint:CGPointMake(self.imageView.bounds.size.width, 1300)
                          controlPoint:CGPointMake(self.imageView.bounds.size.width / 3, self.lightning1.layer.position.y)];
    moveAnim5.path = particlePath5.CGPath;
    moveAnim5.delegate = self;
    moveAnim5.fillMode=kCAFillModeForwards;
    moveAnim5.duration = 2.0;
    moveAnim5.beginTime = CACurrentMediaTime() + 1.2;
    moveAnim5.removedOnCompletion = NO;
    NSArray *timingFunctions5 = [NSArray arrayWithObjects:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],nil];
    [moveAnim5 setTimingFunctions:timingFunctions5];
    [self.lightning1.layer addAnimation:moveAnim5 forKey:@"lightning1p2"];
    
    //lightning bolt 2 from right to left diagonal projection animation
    CAKeyframeAnimation *moveAnim6 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    [moveAnim6 setValue:self.lightning2.layer forKey:@"lightning2p2"];
    UIBezierPath *particlePath6 = [UIBezierPath bezierPath];
    [particlePath6 moveToPoint:CGPointMake((self.imageView.bounds.size.width / 3) * 2, self.lightning1.layer.position.y)];
    [particlePath6 addQuadCurveToPoint:CGPointMake(0, 1300)
                          controlPoint:CGPointMake((self.imageView.bounds.size.width / 3) * 2, self.lightning1.layer.position.y)];
    moveAnim6.path = particlePath6.CGPath;
    moveAnim6.delegate = self;
    moveAnim6.fillMode=kCAFillModeForwards;
    moveAnim6.duration = 2.0;
    moveAnim6.beginTime = CACurrentMediaTime() + 1.2;
    moveAnim6.removedOnCompletion = NO;
    NSArray *timingFunctions6 = [NSArray arrayWithObjects:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],nil];
    [moveAnim6 setTimingFunctions:timingFunctions6];
    [self.lightning2.layer addAnimation:moveAnim6 forKey:@"lightning2p2"];
    
    //fade title in animation
    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.delegate = self;
    opacityAnim.fromValue = [NSNumber numberWithFloat:0.0f];
    opacityAnim.toValue = [NSNumber numberWithFloat:1.0f];
    opacityAnim.removedOnCompletion = NO;
    opacityAnim.fillMode =kCAFillModeForwards;
    opacityAnim.beginTime = CACurrentMediaTime() + 1.7;
    opacityAnim.duration = 1.0;
    [self.appLabel.layer addAnimation:opacityAnim forKey:@"label"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    CALayer *layer = [anim valueForKey:@"lightning2p2"];
    if (layer) {
        [self.imageView removeFromSuperview];
        [UIApplication sharedApplication].statusBarHidden = NO;
    }
}


@end
