//
//  PCSpeechSynthesizer.m
//  Pica
//
//  Created by Fancy on 2022/4/13.
//  Copyright © 2022 fancy. All rights reserved.
//

#import "PCSpeechSynthesizer.h"
#import <AVFoundation/AVFoundation.h>

@interface PCSpeechSynthesizer () <AVSpeechSynthesizerDelegate>

@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;

@end

@implementation PCSpeechSynthesizer

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static PCSpeechSynthesizer *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (void)speakText:(NSString *)string {
//    AVSpeechUtteranceMinimumSpeechRate   0
//    AVSpeechUtteranceMaximumSpeechRate   1
//    AVSpeechUtteranceDefaultSpeechRate   0.5
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:string];
    utterance.rate = 0.6;
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    [self.synthesizer speakUtterance:utterance];
}

- (void)stopSpeak {
    [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}

#pragma mark - AVSpeechSynthesizerDelegate
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance;{
     
}

#pragma mark - Get
- (AVSpeechSynthesizer *)synthesizer{
    if (!_synthesizer) {
        _synthesizer = [[AVSpeechSynthesizer alloc] init];
        _synthesizer.delegate = self;
    }
    return _synthesizer;
}

@end
