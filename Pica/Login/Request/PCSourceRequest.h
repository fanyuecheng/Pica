//
//  PCSourceRequest.h
//  Pica
//
//  Created by Fancy on 2021/8/3.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCRequest.h"

NS_ASSUME_NONNULL_BEGIN
/* 无用
 {
     message = "success";
     data = {
         sources = (
             {
                 title = "CG 1";
                 url = "https://uat.picaapi.picacomic.com";
                 code = "CG1";
             },
             {
                 title = "CG 2";
                 url = "https://uat.picaapi2.picacomic.com";
                 code = "CG2";
             },
             {
                 title = "Pica";
                 url = "https://picaapi.picacomic.com";
                 code = "PICA";
             }
         );
     };
     code = 200;
 }
 */
@interface PCSourceRequest : PCRequest

@end

NS_ASSUME_NONNULL_END
