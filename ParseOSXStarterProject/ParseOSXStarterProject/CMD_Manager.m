//
//  CMD_Manager.m
//  CMD_Listener_OSX
//
//  Created by Zack Mathews on 8/18/14.
//  Copyright (c) 2014 Zack Matthews. All rights reserved.
//

#import "CMD_Manager.h"

@implementation CMD_Manager

@synthesize timer;

static NSString *CMD_PARAM_DELIMITER = @"//";
NSURL *url;

-(id) initWithStatusTextAndHost: (NSTextField*) mStatus :(NSString*) host{
    self = [super init];
    if (self)
    {
        self.status = mStatus;
        url = [[NSURL alloc] initWithString:host];
    }
    return self;
}

/********** Executes when CMD is recieved, parses CMD, executes action **********/
-(void)executeCMD:(NSString *)cmd : (NSString*) param{

    [self setStatusText:@"Executing" :cmd :param];
    
    if([cmd isEqualToString:@"open"]){
        //Validation
        if(param.length > 3){
            [[NSWorkspace sharedWorkspace] launchApplication: param];
            
        }
    }
    
  
    if([cmd isEqualToString:@"view"]){
      
        if(param.length > 3){
            if([param isEqualToString:@"screen"]){
                //OUTDATED: SEE CMD_Castscreen.h
                  //Previously took a screenshot and uploaded to Google Drive, but I thought that full on remote desktop would be better
            }
        }
    }
    
}

/********** Begins polling for CMD's **********/
-(void) beginListening{
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(asyncListen) userInfo:nil repeats:YES];
        [timer fire];
}
/**********                           **********/


/********** Turns off CMD listener **********/
-(void) stopListening{
    [timer invalidate];
}
/**********                        **********/


/********** Helper function to set status based on args **********/
-(void) setStatusText:(NSString*) statusText : (NSString*) cmd : (NSString*)param{
    NSString *tempTXT = @"Status: ";
    tempTXT = [tempTXT stringByAppendingString:statusText];
    
    if(cmd != nil && cmd.length > 1){
        
        tempTXT = [tempTXT stringByAppendingString:@" cmd: "];
        tempTXT = [tempTXT stringByAppendingString:cmd];
        
        if(param != nil && param.length > 1){
            
            tempTXT = [tempTXT stringByAppendingString:@" params:"];
            tempTXT = [tempTXT stringByAppendingString:param];
        }
        
    }
    [self.status setStringValue:tempTXT];
}

/**********                                             **********/


/********** Helper function to create URL request that pops the CMD off the stack **********/
-(NSURL*) buildDELURL: (NSString*) param{
  
    NSString *baseURL = url.absoluteString;
     //?del= is hardcoded but could always be changed if the need arised
    NSString *delCmdURL = [baseURL stringByAppendingString:@"?del="];
    delCmdURL = [delCmdURL stringByAppendingString: param];
    
    NSURL *delURL = [[NSURL alloc] initWithString:delCmdURL];
    
    return delURL;
}
/**********                                                                        **********/

/********** Executes delete CMD **********/
-(void) deleteCMD: (NSString*) cmd{
  
    [self setStatusText:@"Deleting from the stack" : cmd : @""];
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[self buildDELURL:cmd]];
    NSHTTPURLResponse *response = nil;
    NSError *error;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"Response: %@", responseString);
    
    [self setStatusText:@"Successfully deleted" : cmd : @""];

    
}

/********** Polls for available CMDs **********/
-(void) asyncListen{
    
    [self setStatusText:@"Listening..." : @"" : @""];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    
    NSHTTPURLResponse *response = nil;
    NSError *error;
    
    //Fully aware that this is sychronously operating on the UI thread. This build was purely for test purposes and proof of concept rather than efficiency. Given a real product this would be optimized with an Asynchronous request
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"Response: %@", responseString);
    
    
    NSArray *results = [responseString componentsSeparatedByString:CMD_PARAM_DELIMITER];
    NSString *cmd = [results objectAtIndex:0];
    NSString *param = [results objectAtIndex:1];
   
    if(![cmd isEqualToString:CMD_PARAM_DELIMITER] && ![cmd isEqualToString:@""]){
        [self setStatusText:@"Loaded: " : cmd : param];
    
        [self deleteCMD:cmd];
        [self executeCMD:cmd : param];
    
    }
}


/**********                         **********/
@end
