//
//  PCChatInputBar.h
//  Pica
//
//  Created by Fancy on 2021/6/18.
//  Copyright © 2021 fancy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PCChatInputBar, QMUIButton, QMUITextView;
 
@protocol PCChatInputBarDelegate <NSObject>
 
- (void)inputBarDidTouchImage:(PCChatInputBar *)inputBar;
- (void)inputBarDidTouchVoice:(PCChatInputBar *)inputBar;
- (void)inputBar:(PCChatInputBar *)inputBar didChangeInputHeight:(CGFloat)height;
- (void)inputBar:(PCChatInputBar *)inputBar didSendText:(NSString *)text;
- (void)inputBar:(PCChatInputBar *)inputBar didSendVoice:(NSString *)path;
- (void)inputBarDidInputAt:(PCChatInputBar *)inputBar;
- (void)inputBar:(PCChatInputBar *)inputBar didDeleteAt:(NSString *)text;
- (void)inputBarDidTouchKeyboard:(PCChatInputBar *)inputBar;

@end

@interface PCChatInputBar : UIView

@property (nonatomic, strong) UIView     *lineView;
@property (nonatomic, strong) QMUIButton *micButton;
@property (nonatomic, strong) QMUIButton *picButton;
@property (nonatomic, strong) QMUIButton *recordButton;
@property (nonatomic, strong) QMUITextView *inputTextView;
@property (nonatomic, weak) id <PCChatInputBarDelegate> delegate;

- (void)backDelete;
- (void)clearInput;
- (NSString *)getInput;
- (void)updateTextViewFrame;

@end

NS_ASSUME_NONNULL_END
