//
//  PCOrderListController.m
//  Pica
//
//  Created by Fancy on 2022/2/10.
//  Copyright © 2022 fancy. All rights reserved.
//

#import "PCOrderListController.h"

@interface PCOrderListController ()

@property (nonatomic, strong) QMUIOrderedDictionary *orderDictionary;
@property (nonatomic, strong) UIView *extendLayer;

@end

@implementation PCOrderListController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)initSubviews {
    [super initSubviews];
    
    [self.view addSubview:self.extendLayer];
    self.view.clipsToBounds = NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.extendLayer.frame = CGRectMake(0, self.view.qmui_height, self.view.qmui_width, SafeAreaInsetsConstantForDeviceWithNotch.bottom);
}

- (void)initTableView {
    [super initTableView]; 
}

#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.orderDictionary.allKeys.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    QMUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[QMUITableViewCell alloc] initForTableView:tableView withStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.detailTextLabel.numberOfLines = 0;
    }
    cell.textLabel.text = self.orderDictionary.allKeys[indexPath.row];
    cell.detailTextLabel.text = self.orderDictionary.allValues[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    !self.orderBlock ? : self.orderBlock(self.orderDictionary.allKeys[indexPath.row]);
}

- (CGSize)preferredContentSizeInModalPresentationViewController:(QMUIModalPresentationViewController *)controller keyboardHeight:(CGFloat)keyboardHeight limitSize:(CGSize)limitSize {
    return CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT * 0.7);
}

#pragma mark - Get
- (QMUIOrderedDictionary *)orderDictionary {
    if (!_orderDictionary) {
        _orderDictionary = [[QMUIOrderedDictionary alloc] initWithKeysAndObjects:@"@搶紅包", @"搶地上的嗶咔幣",
                            @"@我的紅包", @"顯示你擁有的嗶咔幣和財富榜排名",
                            @"@發紅包 ", @"發紅包，例：@發紅包 1000",
                            @"@搶劫", @"搶別人的嗶咔幣，但成功搶劫的機會比較低喔，而且搶劫失敗會令你損失嗶咔幣",
                            @"@轉嗶咔幣 ", @"把你的嗶咔幣轉移給有需要的人，例：@轉嗶咔幣 100",
                            @"@財富榜", @"顯示嗶咔財富排行榜",
                            @"@神偷榜", @"顯示神偷排行榜",
                            @"@我的屠怪記錄", @"顯示你屠殺怪獸的記錄和屠怪榜排名",
                            @"@屠怪榜", @"顯示嗶咔怪獸屠殺榜",
                            @"✊ ✋ ✌", @"發以上任何一個表情符號屠殺怪獸",
                            @"@展覽框 ", @"顯示頭像框的目錄，頁碼是數字喔，例：@展覽框 5",
                            @"@買框", @"購買頭像框，編號是數字喔，例：@買框 10（編號可透過@展覽框得知）",
                            @"@展覽色彩 ", @"顯示文字顏色的目錄，頁碼是數字喔，例：@展覽色彩 2",
                            @"@買色彩 ", @"購買文字顏色，編號是數字喔，例：@買色彩 2（編號可透過@展覽色彩得知）",
                            @"@改稱號 ", @"花費 50,000 嗶咔幣更改稱號，例：@改稱號 我是丟人的萌新",
                            @"@送禮 ", @"送禮物給聊天室指定的人，編號是數字喔，例：@送禮 3（編號可透過@展覽禮物得知）",
                            @"@禮物榜", @"顯示嗶咔收禮榜，這榜上都是嗶咔的人氣王",
                            @"@展覽禮物 ", @"顯示禮物的目錄，頁碼是數字喔，例：@展覽禮物 1",
                            @"@我的框 ", @"顯示你擁有的框，頁碼是數字喔，例：@我的框 1",
                            @"@設定框 ", @"更換框，編號是數字喔，例：@設定框 12（編號可透過@我的框得知）",
                            @"@檢視框 ", @"檢視某一個指定的框，例：@檢視框 13（編號可透過@展覽框得知）",
                            @"@色子", @"花費 100 嗶咔幣召喚出【巨型蛇球色子】，色子會使用技能在空中隨機劃出 1到6 道🌈",
                            @"@公告 ", @"花費 10,000 嗶咔幣發出公告，如果需要針對某人發出公告，請點一下人名再發出公告",
                            @"@神抽", @"花費 100 嗶咔幣進行抽獎，獎品包括頭框和嗶咔幣",
                            @"@神連抽", @"花費 1,000 嗶咔幣進行11次抽獎，獎品包括頭框和嗶咔幣",
                            @"@我的登入訊息", @"檢視我的登入訊息和狀態",
                            @"@改登入訊息 ", @"花費 5,000 嗶咔幣更改登入訊息",
                            @"@開啟登入訊息", @"開啟你的登入訊息（你進入聊天室時會顯示你的華麗登入訊息）",
                            @"@關閉登入訊息", @"關閉你的登入訊息（進入聊天室時會不再顯示你的登入訊息）",
                            @"@我的色彩 ", @"顯示你擁有的色彩，頁碼是數字喔，例：@我的色彩 1",
                            @"@設定色彩 ", @"更換色彩，編號是數字喔，例：@設定色彩 12（編號可透過@我的色彩得知）",
                            @"@開始拼大小 ", @"發起抽卡拼大小對戰，頁碼是數字喔，例：@開始拼大小 1000",
                            @"@拼大小", @"參加抽卡拼大小對戰",
                            @"@提醒拼大小", @"提醒別人抽卡拼大小對戰開始了",
                            @"@結束拼大小", @"結束抽卡拼大小對戰看結果",
                            @"@求婚", @"向某人提出求婚要求，婚禮成功開始後需要支付 450,000 嗶咔幣。每次求婚需先只付 50,000 嗶咔幣",
                            @"@我答應你求婚", @"當某人向你發出求婚要求後，你可以發這指令答應求婚，如果在一段時間內不回應，系統會自動拒絕要求",
                            @"@新人時間", @"開始新人時間，在新人時間期間只有新人和親友可以說話，新人合共發出20個訊息後，新人時間會完結",
                            @"@加親友", @"把某人加入你的親友名單，上限為3人",
                            @"@祝福紅包 ", @"在婚禮期間，發紅包祝福新人",
                            @"@新人榜", @"觀看新人收到紅包的排行榜",
                            @"@離婚", @"向某人提出離婚協議，每次提出協議都要花費 50,000 嗶咔幣，對方同意離婚後會收取餘下 400,000 嗶咔幣手續費",
                            @"@分開亦是朋友", @"同意對手的離婚協議",
                            @"@單方面離婚", @"花億點嗶咔幣🤑跟你的愛人強行離婚", nil
        ];
    }
    return _orderDictionary;
}

- (UIView *)extendLayer {
    if (!_extendLayer) {
        _extendLayer = [[UIView alloc] init];
        _extendLayer.backgroundColor = UIColorWhite;
    }
    return _extendLayer;
}


@end
