//
//  PCAPIHeader.h
//  Pica
//
//  Created by fancy on 2020/11/2.
//

#ifndef PCAPIHeader_h
#define PCAPIHeader_h

//HOST
#define PC_API_HOST_IOS             @"https://api.tipatipa.xyz/"
#define PC_API_HOST_ANDROID         @"https://picaapi.picacomic.com/"
//登录
#define PC_API_AUTH_SIGN_IN     @"auth/sign-in"
//注册
#define PC_API_AUTH_REGIST      @"auth/register"
//忘记密码
#define PC_API_AUTH_FORGOT_PSD  @"auth/forgot-password"
//分类
#define PC_API_CATEGORIES       @"categories"
//搜索推荐关键字
#define PC_API_KEYWORDS         @"keywords"
//漫画
#define PC_API_COMICS           @"comics"
//漫画详情
#define PC_API_COMICS_DETAIL    @"comics/%@"
//漫画ep
#define PC_API_COMICS_EPS       @"comics/%@/eps"
//漫画like
#define PC_API_COMICS_LIKE      @"comics/%@/like"
//漫画favourite
#define PC_API_COMICS_FAVOURITE @"comics/%@/favourite"
//漫画图片详情
#define PC_API_COMICS_IMAGE     @"comics/%@/order/%@/pages"
//漫画评论
#define PC_API_COMICS_COMMENTS  @"comics/%@/comments"
//高级搜索
#define PC_API_SEARCH_ADVANCED  @"comics/advanced-search?page=%@"
//漫画排行
#define PC_API_COMICS_RANK      @"comics/leaderboard"
#define PC_API_COMICS_COLLECTION @"collections"
//骑士排行
#define PC_API_COMICS_KNIGHT    @"comics/knight-leaderboard"
//随机本子
#define PC_API_COMICS_RANDOOM   @"comics/random"
//漫画子评论
#define PC_API_COMMENTS_CHILD       @"comments/%@/childrens?page=%@"
#define PC_API_COMMENTS_CHILD_REPLY @"comments/%@"
//漫画评论点赞
#define PC_API_COMICS_COMMENTS_LIKE  @"comments/%@/like"
//评论举报
#define PC_API_COMICS_COMMENTS_REPORT @"comments/%@/report"
//个人信息
#define PC_API_USERS_PROFILE_ME @"users/profile"
#define PC_API_USERS_PROFILE    @"users/%@/profile"
//签到
#define PC_API_USERS_PUNCH_IN   @"users/punch-in"
//头像
#define PC_API_USERS_AVATAR     @"users/avatar"
//slogan
#define PC_API_USERS_SLOGAN     @"users/profile"
//密码
#define PC_API_USERS_PASSWORD   @"users/password"
//name
#define PC_API_USERS_NAME       @"users/update-id"
//我的收藏
#define PC_API_USERS_FAVOURITE  @"users/favourite?s=%@&page=%@"
//我的评论
#define PC_API_USERS_COMMENT    @"users/my-comments?page=%@"
//聊天
#define PC_API_CHAT             @"chat"
//游戏
#define PC_API_GAME_LIST        @"games?page=%@"
//游戏详细
#define PC_API_GAME_DETAIL      @"games/%@"
//游戏评论
#define PC_API_GAME_COMMENTS    @"games/%@/comments"
//游戏like
#define PC_API_GAME_LIKE        @"games/%@/like"


//未使用api
#define PC_API_SOURCE                   @"sources"
#define PC_API_INIT                     @"init?platform=%@"

#endif /* PCAPIHeader_h */
