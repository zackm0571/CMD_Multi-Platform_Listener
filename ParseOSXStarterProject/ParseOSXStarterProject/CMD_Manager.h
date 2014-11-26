//
//  CMD_Manager.h
//  CMD_Listener_OSX
//
//  Created by Zack Mathews on 8/18/14.
//  Copyright (c) 2014 Zack Matthews. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMD_CastScreen.h"
@interface CMD_Manager : NSObject

-(id) initWithStatusTextAndHost: (NSTextField*) status : (NSString*) host;

-(void) beginListening;
-(void) stopListening;


@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSTextField *status;
@end
