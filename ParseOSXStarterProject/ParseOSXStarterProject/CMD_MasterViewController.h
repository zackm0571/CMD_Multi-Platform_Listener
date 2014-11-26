//
//  CMD_MasterViewController.h
//  CMD_Listener_OSX
//
//  Created by Zack Mathews on 8/18/14.
//  Copyright (c) 2014 Zack Matthews. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CMD_Manager.h"
#import "CMD_SpeechManager.h"
@interface CMD_MasterViewController : NSViewController

@property BOOL isListening;

@property (strong) IBOutlet NSTextField *statusText;
@property (strong) IBOutlet NSTextField *hostTextField;
- (IBAction)startCMDListenerOnClick:(id)sender;
- (IBAction)startScreenShare:(id)sender;

@property (strong) IBOutlet NSButton *startCMDButton;
@property (assign) IBOutlet NSButton *startScreenShareButton;
@property (assign) IBOutlet NSImageView *screenPreview;

@property (strong, nonatomic) CMD_Manager *manager;
@property (strong, nonatomic) CMD_CastScreen *castTask;
@property (strong, nonatomic) CMD_SpeechManager *speechManager;
@property (strong, nonatomic) NSTimer* screenUpdateTimer;
@property (strong) IBOutlet NSTextField *latencyMonitorLabel;

- (IBAction)listenForSpeechButton:(id)sender;

-(void) setLatencyStatus: (NSString*) status;

@end
