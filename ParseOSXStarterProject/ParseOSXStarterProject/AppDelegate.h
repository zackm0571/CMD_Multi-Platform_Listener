//
//  AppDelegate.h
//  ParseOSXStarterProject
//
//  Copyright 2014 Parse, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AppKit/AppKit.h>
#include "CMD_MasterViewController.h"
@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) IBOutlet CMD_MasterViewController *mViewController;


@end
