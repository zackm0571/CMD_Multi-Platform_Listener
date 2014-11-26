//
//  CMD_SpeechManager.m
//  ParseOSXStarterProject
//
//  Created by Zack Matthews on 11/24/14.
//  Copyright (c) 2014 Parse. All rights reserved.
//

#import "CMD_SpeechManager.h"
#import "CMD_DefaultCMD.h"
@implementation CMD_SpeechManager

BOOL isOn = YES;
- (id)init {
    self = [super init];
    if (self) {
        
        //A more dynamic CMD list will be added in future builds
        NSArray *cmds = [NSArray arrayWithObjects:@"OK Mac tell me what I already know", @"OK Mac what's the weather", @"OK Mac play me some music", nil];
        _recog = [[NSSpeechRecognizer alloc] init];
        [_recog setCommands:cmds];
        [_recog setDelegate:self];
        
        _synth = [[NSSpeechSynthesizer alloc] initWithVoice:[NSSpeechSynthesizer defaultVoice]];
    }
    return self;
}
- (IBAction)listen:(id)sender
{
    //Listen toggle
    if (isOn) {
        [_recog startListening];
        isOn = NO;
        
        
    } else {
        [_recog stopListening];
        isOn = YES;
    }
}

/********** Parses speech as string. Too many possibilities **********/
- (void)speechRecognizer:(NSSpeechRecognizer *)sender didRecognizeCommand:(id)aCmd {
    
    if ([(NSString *)aCmd isEqualToString:@"OK Mac play me some music"]) {
        //Ghetto Applescript to open web browser and execute javascript that toggles play / pause
        [CMD_DefaultCMD playMusicFromGoogle];
    }
    if ([(NSString *)aCmd isEqualToString:@"OK Mac what's the weather"]) {
        //Weather php script hosted on my website
        [_synth startSpeakingString:[CMD_DefaultCMD getWeather]];
        return;
    }
   
}
/**********                                                 **********/


@end
