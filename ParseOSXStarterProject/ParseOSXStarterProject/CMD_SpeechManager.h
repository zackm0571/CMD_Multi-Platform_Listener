//
//  CMD_SpeechManager.h
//  ParseOSXStarterProject
//
//  Created by Zack Matthews on 11/24/14.
//  Copyright (c) 2014 Parse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMD_SpeechManager : NSObject <NSSpeechRecognizerDelegate, NSSpeechSynthesizerDelegate>

@property (strong) NSSpeechRecognizer *recog;
@property (strong) NSSpeechSynthesizer *synth;
-(IBAction)listen :(id)sender;
@end
