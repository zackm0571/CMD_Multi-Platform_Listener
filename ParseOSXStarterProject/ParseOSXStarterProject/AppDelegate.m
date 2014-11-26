//
//  AppDelegate.m
//  ParseOSXStarterProject
//
//  Copyright 2014 Parse, Inc. All rights reserved.
//

#import <ParseOSX/Parse.h>

#import "AppDelegate.h"

@implementation AppDelegate

#pragma mark -
#pragma mark NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    
    /*********** Parse backend. I'm not a backend developer which is why this is used ***********/
      [Parse setApplicationId:@"nil"
                  clientKey:@"nil"];
    
    [PFUser enableAutomaticUser];
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    [PFAnalytics trackAppOpenedWithLaunchOptions:nil];
    
    /***********                                                                        ***********/
    self.mViewController = [[CMD_MasterViewController alloc] initWithNibName:@"CMD_MasterViewController" bundle:nil];
    [self.window.contentView addSubview:self.mViewController.view];
    self.mViewController.view.frame = ((NSView*)self.window.contentView).bounds;

}

@end
