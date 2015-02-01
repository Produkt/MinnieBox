//
//  AppDelegate.m
//  MinnieDisk
//
//  Created by Daniel García on 23/01/15.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "MinnieBoxViewController.h"
#import "LinkerViewController.h"
#import <DropboxSDK/DropboxSDK.h>

@interface AppDelegate ()
@property (strong,nonatomic) NSMutableSet *draftedInodes;
@property (nonatomic, strong) LinkerViewController *linkerVC;
@property (strong,nonatomic) ViewController *dropboxVC;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    ViewController *viewController = [[ViewController alloc] init];
    viewController.draftedInodes = self.draftedInodes;
    UINavigationController *firstNavController = [[UINavigationController alloc]initWithRootViewController:viewController];
    MinnieBoxViewController *minnieBoxVC = [[MinnieBoxViewController alloc]initWithDraftedInodes:self.draftedInodes];
    self.dropboxVC = viewController;
    UINavigationController *secondNavController = [[UINavigationController alloc]initWithRootViewController:minnieBoxVC];
    UITabBarController *tabbarController = [[UITabBarController alloc]init];
    tabbarController.viewControllers = @[firstNavController, secondNavController];
    self.window.rootViewController = tabbarController;
    [self.window makeKeyAndVisible];
    
    DBSession *dbSession = [[DBSession alloc]
                            initWithAppKey:@"nzdo2tzsr752sep"
                            appSecret:@"x0z2kqsnfar3s9s"
                            root:kDBRootDropbox]; // either kDBRootAppFolder or kDBRootDropbox
    [DBSession setSharedSession:dbSession];
    
    if (![[DBSession sharedSession] isLinked]) {
        self.linkerVC = [[LinkerViewController alloc]init];
        [tabbarController presentViewController:self.linkerVC animated:YES completion:nil];
    } 

    return YES;
}

- (NSMutableSet *)draftedInodes{
    if (!_draftedInodes) {
        _draftedInodes = [NSMutableSet set];
    }
    return _draftedInodes;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"Dropbox Account Linked");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.linkerVC dismissViewControllerAnimated:YES completion:nil];
            });
            [self.dropboxVC getInodeRepresentation];
        }
        return YES;
    }
    
    return NO;
}

@end
