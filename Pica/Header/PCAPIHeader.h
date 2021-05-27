//
//  PCAPIHeader.h
//  Pica
//
//  Created by fancy on 2020/11/2.
//

#ifndef PCAPIHeader_h
#define PCAPIHeader_h

//HOST
#define PC_API_HOST             @"https://picaapi.picacomic.com/"
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
#define PC_API_SEARCH_ADVANCED  @"comics/advanced-search"
//漫画排行
#define PC_API_COMICS_RANK      @"comics/leaderboard"
//骑士排行
#define PC_API_COMICS_KNIGHT    @"comics/knight-leaderboard"
//随机本子
#define PC_API_COMICS_RANDOOM   @"comics/random"

#endif /* PCAPIHeader_h */
