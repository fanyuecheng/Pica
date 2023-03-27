//
//  PCRecordView.h
//  Pica
//
//  Created by Fancy on 2021/6/18.
//  Copyright © 2021 fancy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  录音状态枚举
 */
typedef NS_ENUM(NSUInteger, PCVoiceRecordStatus) {
    PCVoiceRecordStatusTooShort,  //录音时长过短。
    PCVoiceRecordStatusTooLong,   //录音时长超过时间限制。
    PCVoiceRecordStatusRecording, //正在录音。
    PCVoiceRecordStatusCancel     //录音被取消。
};


@interface PCRecordView : UIView

/**
 *  录音图标视图。
 *  本图标包含了各个音量大小下的对应图标（1 - 8 格音量示意共8个）。
 */
@property (nonatomic, strong) UIImageView *recordImageView;

/**
 *  视图标签。
 *  负责基于当前录音状态向用户提示。如“松开发送”、“手指上滑，取消发送”、“说话时间太短”等。
 */
@property (nonatomic, strong) UILabel *titleLabel;

/**
 *  背景视图
 *  作为语音当前视图的背景，将其与聊天视图区分开来。
 *  一般背景视图的显示元素（背景颜色等）可以根据当前录音状态改变，区分各个状态。
 */
@property (nonatomic, strong) UIView *backgroundView;

/**
 *  设置当前录音的音量。
 *  便于录音图标视图中的图像根据音量进行改变。
 *  例如：power < 25时，使用“一格”图标；power >25时，根据一定的公式计算图标格式并进行替换当前图标。
 *
 *  @param power 想要设置为的音量。
 */
- (void)setPower:(NSInteger)power;

/**
 *  设置当前录音状态。
 *  Record_Status_TooShort 录音时长过短。
 *  Record_Status_TooLong 录音时长超过时间限制。
 *  Record_Status_Recording 正在录音。
 *  Record_Status_Cancel 录音被取消。
 *
 *  @param status 想要设置为的状态。
 */
- (void)setStatus:(PCVoiceRecordStatus)status;

@end

NS_ASSUME_NONNULL_END
