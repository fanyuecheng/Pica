//
//  PCSpeechSynthesizer.h
//  Pica
//
//  Created by Fancy on 2022/4/13.
//  Copyright © 2022 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PCSpeechSynthesizer : NSObject

+ (instancetype)sharedInstance;

- (void)speakText:(NSString *)string;
- (void)stopSpeak;

@end

NS_ASSUME_NONNULL_END
