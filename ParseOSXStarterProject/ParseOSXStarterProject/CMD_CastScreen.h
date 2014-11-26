//
//  CMD_CastScreen.h
//  CMD_Listener_OSX
//
//  Created by Zack Matthews on 11/14/14.
//  Copyright (c) 2014 Zack Matthews. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseOSX/Parse.h>
@interface CMD_CastScreen : NSObject

-(void)beginCast;
-(NSImage*) getScreen;
-(void) enableDebugText :(NSTextField*) debugText;

@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic, strong) NSOperationQueue *imageOperationQueue;
@property (strong, nonatomic) NSImageView *screenPreview;
@property (strong) NSTimer *screenUpdateTimer;
@property (strong) NSTimer *cleanupTimer;
@property (strong) NSTimer *idleCleanupTimer;
@property (strong) NSTextField* debugText;

@end
