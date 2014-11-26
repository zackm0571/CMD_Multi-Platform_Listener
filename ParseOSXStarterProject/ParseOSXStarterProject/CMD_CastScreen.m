//
//  CMD_CastScreen.m
//  CMD_Listener_OSX
//
//  Created by Zack Matthews on 11/14/14.
//  Copyright (c) 2014 Zack Matthews. All rights reserved.
//

#import "CMD_CastScreen.h"

@implementation CMD_CastScreen


//NOTE: Still playing with the most effective values given an unoptimal server solution
int MAX_FRAME_BUFFER = 5;
int MIN_FRAME_BUFFER = 2;

//Global resolution variable in case it needed to be changed during run time
NSSize streamResolution;
CGFloat STREAM_WIDTH = 640, STREAM_HEIGHT = 320;//480, STREAM_HEIGHT = 270;

//Latency tolerance and latency from last frame sent to backend
NSNumber *MAX_LATENCY;
NSNumber *lastFrameTime;

//Double value as constant
double MAX_LATENCY_CONST = 200;

//Server column names in the event they needed to be changed and readability for code
NSString *TIME_SERVER_CONST = @"timeLong";
NSString *RECIEVED_SERVER_CONST = @"recieved";
NSString *SERVER_CLASS_NAME = @"Screen";
NSString *IMG_SERVER_CONST = @"screen";

/********** Begins sending stream to server with timer for upload, cleanup, and idle cleanup **********/
-(void)beginCast{
    
    streamResolution = NSSizeFromCGSize(CGSizeMake(STREAM_WIDTH, STREAM_HEIGHT));
    MAX_LATENCY = [[NSNumber alloc] initWithDouble:MAX_LATENCY_CONST];

    
    //Fires timers
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(sendScreenToParse) userInfo:nil repeats:YES];
    [_timer fire];

    _cleanupTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(cleanupScreenFromParse) userInfo:nil repeats:YES];
    [_cleanupTimer fire];
    
    _idleCleanupTimer = [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(cleanupIdleScreenFromParse) userInfo:nil repeats:YES];
    [_idleCleanupTimer fire];

}
/**********                                                                                 **********/

/********** Cleans up captures that have been older than latency tolerance **********/
-(void) cleanupIdleScreenFromParse{
        NSNumber *latency = [[NSNumber alloc]initWithDouble: CFAbsoluteTimeGetCurrent() - MAX_LATENCY.doubleValue ]; //Oldest capture can be
        //Creates query sorting by oldest where time uploaded is greater than latency tolerance and screen has not been viewed by client
    
        PFQuery *query = [[PFQuery alloc] initWithClassName:SERVER_CLASS_NAME];
    
        [query addAscendingOrder:TIME_SERVER_CONST];
        [query whereKey:TIME_SERVER_CONST greaterThan:latency];
        [query whereKey:RECIEVED_SERVER_CONST equalTo:@NO];
    
        //If resulting query is greater than max buffer delete all objects found asychronously
        if([query countObjects] >= MAX_FRAME_BUFFER){
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
                for(int i = 0; i < objects.count; i++){
                        [[objects objectAtIndex:i] deleteInBackgroundWithBlock:^(BOOL succeeded, NSError* error){
                            if(succeeded){
                                NSLog(@"Deleted idle screen");
                            }
                        }];
                    }
                }];
        }
}

/**********                                                                 **********/
/********** Sets label to post latency information to **********/
-(void) enableDebugText:(NSTextField *)debugText{
    _debugText = debugText;
}
/**********                                           **********/


/********** Deletes all captures that have been viewed and sets debug text to latency value in seconds between time uploaded and time viewed **********/
-(void) cleanupScreenFromParse{
    
        PFQuery *query = [[PFQuery alloc] initWithClassName:SERVER_CLASS_NAME];

    [query addAscendingOrder:TIME_SERVER_CONST];
    [query whereKey:RECIEVED_SERVER_CONST equalTo:@YES];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        for(int i = 0; i < objects.count; i++){
            [[objects objectAtIndex:i] deleteInBackgroundWithBlock:^(BOOL succeeded, NSError* error){
                if(succeeded){
                    NSLog(@"Deleted viewed screen");
                }
            }];
        }
        
        if(_debugText != nil){
            if(objects.count > 0){
                PFObject *lastClientRecievedObject = [objects objectAtIndex:objects.count-1];
                if(lastClientRecievedObject != nil){

                    NSNumber *clientLatency = lastClientRecievedObject[@"timeLong"];
                    NSNumber *latencyCHVal = [[NSNumber alloc] initWithLong:lastFrameTime.longValue - clientLatency.longValue];
         
                    [_debugText setStringValue:[[@"Latency to client:" stringByAppendingString: latencyCHVal.stringValue] stringByAppendingString:@" seconds"]];
                }
            }
        }
        
    }];
}


/**********                                                                                     **********/


/********** Uploads screen to Parse server NOTE: There is absolutely a better way to do this. I wanted to do something time and cost efficient because it was a cool project. I'm not a web developer! **********/
-(void) sendScreenToParse{
    
    //Captures screen with getScreen, and then resizes and returns the NSData with imageResizeData
    NSData *imageData = [self imageResizeData:[self getScreen] newSize:streamResolution];

    //Creates file that will be recognized by Parse and then initializes tuple (PFObject) to contain it
    PFFile *file = [PFFile fileWithName:@"capture.jpg" data:imageData];
    PFObject *object = [[PFObject alloc] initWithClassName:SERVER_CLASS_NAME];
   
    NSNumber *number = [[NSNumber alloc] initWithDouble: CFAbsoluteTimeGetCurrent()];
    object[TIME_SERVER_CONST] = number;
    object[IMG_SERVER_CONST] = file;
    [object setObject:@NO forKey:RECIEVED_SERVER_CONST];

    //Sets read/write access to true
    PFACL *acl = [[PFACL alloc] init];
    [acl setPublicReadAccess:YES];
    [acl setPublicWriteAccess:YES];
    
    [object setACL:acl];
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
     
        if(!succeeded){
            NSLog(@"Save failed");
        }
        else{
            lastFrameTime = [[NSNumber alloc] initWithLong:CFAbsoluteTimeGetCurrent()];
            NSLog(@"Sent screen image");
        }

    }];

}
/**********                                                                                     **********/

/********** Extremely ghetto way to do remote desktop, but it works! **********/
-(NSImage *) getScreen{

    system("screencapture -c -x");
    NSImage *imageFromClipboard=[[NSImage alloc]initWithPasteboard:[NSPasteboard generalPasteboard]];

    return imageFromClipboard;
}
/**********                                                         **********/



/********** Resizes image data **********/
- (NSData *)imageResizeData:(NSImage*)src newSize:(NSSize)newSize{
  
    NSImage *sourceImage = src;
    //Keeps ratio
    [sourceImage setScalesWhenResized:YES];
    
    //Validates image
    if (![sourceImage isValid]){
        NSLog(@"Invalid Image");
    }
    
    else{
        NSImage *smallImage = [[[NSImage alloc] initWithSize: newSize] autorelease];
        [smallImage lockFocus]; //Locks image for editing
        
        [sourceImage setSize: newSize]; //Sets size
        
        //Redraws image
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        [sourceImage drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.];
       
        //Unlocks image
        [smallImage unlockFocus];
        
        /********** Creates jpeg representation of image and returns the NSData **********/
        NSData *imageData = [smallImage  TIFFRepresentation];
        NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
        NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1] forKey:NSImageCompressionFactor];
        imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
        NSImage *resizedImage = [[NSImage alloc] initWithData:imageData];
        NSArray *representations = [resizedImage representations];
        
        NSData *bitmapData = [NSBitmapImageRep representationOfImageRepsInArray:representations
                                                                      usingType:NSJPEGFileType
                                                                     properties:imageProps];
        return bitmapData;
    }
    return nil;
}
/**********                                                                 **********/

@end
