//
//  CMD_MasterViewController.m
//  CMD_Listener_OSX
//
//  Created by Zack Mathews on 8/18/14.
//  Copyright (c) 2014 Zack Matthews. All rights reserved.
//

#import "CMD_MasterViewController.h"
#import "CMD_Manager.h"
@interface CMD_MasterViewController ()

@end

@implementation CMD_MasterViewController

@synthesize isListening;
@synthesize manager;
@synthesize startCMDButton;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}



-(void)loadView{
    [super loadView];
    /*********** Set default state to offline and not listening for CMD's ***********/
    [self setGlobalStatus:@"Offline"];
    isListening = NO;
    /*********** ***********/
}

/*********** Sets text of status label to string parameter ***********/
-(void) setGlobalStatus: (NSString*) status{
    NSString *statusText = @"Status: ";
    statusText = [statusText stringByAppendingString:status];
    [self.statusText setStringValue:statusText];
}

/***********                                                ***********/

/*********** Initializes CMD_SpeechManager class and begins listening for recognized CMD's ***********/
- (IBAction)listenForSpeechButton:(id)sender {
    if(_speechManager == nil){
        _speechManager = [[CMD_SpeechManager alloc] init];
        [_speechManager listen:sender];
    }
}

/***********                                                                                ***********/


/*********** Ease of access function to set status of latency label  ***********/
-(void) setLatencyStatus: (NSString*) status{
    NSString *statusText = @"Latency to client: ";
    statusText = [statusText stringByAppendingString:status];
    [_latencyMonitorLabel setStringValue:statusText];
}

/***********  Host text should point to hosted php to listen for queries on ***********/
- (IBAction)startCMDListenerOnClick:(id)sender {
    
    if(isListening == NO){
        
        //Simple validation
        if(self.hostTextField.stringValue.length < 3){
           [self setGlobalStatus:@"Invalid host"];
        }
        
        else{
            manager = [[CMD_Manager alloc] initWithStatusTextAndHost:self.statusText :
                       self.hostTextField.stringValue];
            
            //Begins polling php script for a CMD response
            //Once response is recieved CMD_Manager will parse the response
            [manager beginListening];
            [self setGlobalStatus:@"Listening..."];
            }
        
            [startCMDButton setTitle:@"Stop"];
            isListening = YES;
        }
    
    else{
        [manager stopListening];
        [startCMDButton setTitle:@"Start"];
        isListening = NO;

        }
    }
/***********                                                                ***********/

/*********** Updates UIImageView with preview of what the remote desktop stream will look like ***********/
-(void)updateScreenPreview{
    if(_castTask){
        NSImage *image = [_castTask getScreen];
        [_screenPreview setImage:image];
        
    }
}

/***********                                                                                   ***********/

/*********** Action to initialize CMD_CastScreen begin streaming desktop to Parse backend ***********/
- (IBAction)startScreenShare:(id)sender {
  
    _castTask = [[CMD_CastScreen alloc] init];
    [_castTask beginCast];
    [_castTask enableDebugText:_latencyMonitorLabel];
    //At this point any platform could be used, but I've chosen to target Google glass because it's awesome
    [self setGlobalStatus:@"Broadcasting screen to Google Glass..."];
}

/***********                                                                                ***********/
@end
