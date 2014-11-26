//
//  CMD_DefaultCMD.m
//  ParseOSXStarterProject
//
//  Created by Zack Matthews on 11/24/14.
//  Copyright (c) 2014 Parse. All rights reserved.
//

#import "CMD_DefaultCMD.h"

@implementation CMD_DefaultCMD

NSString* ZACK_WEATHER_CONST = @"http://zackmatthews.com/weather.php";
NSString* GOOGLE_PLAY_THUMBSUP_CONST = @"https://play.google.com/music/listen#/ap/auto-playlist-thumbs-up";


/********** Weather php grab**********/
+(NSString*) getWeather{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:ZACK_WEATHER_CONST] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    [request setHTTPMethod: @"GET"];
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    NSString *responseString = [[NSString alloc] initWithData:response encoding:NSASCIIStringEncoding];
    NSLog(@"responseData: %@", responseString);
    return responseString;
}
/********** Ghetto Applescript to play music from Google Play **********/
+(void) playMusicFromGoogle{
    NSURL *url = [[NSURL alloc] initWithString:GOOGLE_PLAY_THUMBSUP_CONST];
    [[NSWorkspace sharedWorkspace] openURL:url];
    [NSThread sleepForTimeInterval:10];
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"google_play" ofType:@"scpt"];
    NSURL* scriptURL = [[NSURL alloc] initFileURLWithPath:path];
    NSAppleScript *key = [[NSAppleScript alloc] initWithContentsOfURL:scriptURL error:nil];
    [key executeAndReturnError:nil];
}
@end
