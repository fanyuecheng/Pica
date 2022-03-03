//
//  PCVersion.h
//  Pica
//
//  Created by Fancy on 2022/3/3.
//  Copyright © 2022 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PCVersion : NSObject

@property (nonatomic, copy)   NSString *name;
@property (nonatomic, copy)   NSString *tag_name;
@property (nonatomic, copy)   NSString *body;
@property (nonatomic, strong) NSDate *created_at;

- (NSString *)version;
- (BOOL)isNewVersion;

@end

/*
 {
 url: "https://api.github.com/repos/fanyuecheng/Pica/releases/60850646",
 assets_url: "https://api.github.com/repos/fanyuecheng/Pica/releases/60850646/assets",
 upload_url: "https://uploads.github.com/repos/fanyuecheng/Pica/releases/60850646/assets{?name,label}",
 html_url: "https://github.com/fanyuecheng/Pica/releases/tag/v1.2.2",
 id: 60850646,
 author: {
     login: "fanyuecheng",
     id: 34535969,
     node_id: "MDQ6VXNlcjM0NTM1OTY5",
     avatar_url: "https://avatars.githubusercontent.com/u/34535969?v=4",
     gravatar_id: "",
     url: "https://api.github.com/users/fanyuecheng",
     html_url: "https://github.com/fanyuecheng",
     followers_url: "https://api.github.com/users/fanyuecheng/followers",
     following_url: "https://api.github.com/users/fanyuecheng/following{/other_user}",
     gists_url: "https://api.github.com/users/fanyuecheng/gists{/gist_id}",
     starred_url: "https://api.github.com/users/fanyuecheng/starred{/owner}{/repo}",
     subscriptions_url: "https://api.github.com/users/fanyuecheng/subscriptions",
     organizations_url: "https://api.github.com/users/fanyuecheng/orgs",
     repos_url: "https://api.github.com/users/fanyuecheng/repos",
     events_url: "https://api.github.com/users/fanyuecheng/events{/privacy}",
     received_events_url: "https://api.github.com/users/fanyuecheng/received_events",
     type: "User",
     site_admin: false
 },
 node_id: "RE_kwDOEpwT984DoIHW",
 tag_name: "v1.2.2",
 target_commitish: "main",
 name: "Pica version 1.2.2 release ",
 draft: false,
 prerelease: false,
 created_at: "2022-03-03T02:33:54Z",
 published_at: "2022-03-03T02:41:23Z",
 assets: [
     {
     url: "https://api.github.com/repos/fanyuecheng/Pica/releases/assets/58397983",
     id: 58397983,
     node_id: "RA_kwDOEpwT984DexUf",
     name: "Pica.ipa",
     label: null,
     uploader: {
         login: "fanyuecheng",
         id: 34535969,
         node_id: "MDQ6VXNlcjM0NTM1OTY5",
         avatar_url: "https://avatars.githubusercontent.com/u/34535969?v=4",
         gravatar_id: "",
         url: "https://api.github.com/users/fanyuecheng",
         html_url: "https://github.com/fanyuecheng",
         followers_url: "https://api.github.com/users/fanyuecheng/followers",
         following_url: "https://api.github.com/users/fanyuecheng/following{/other_user}",
         gists_url: "https://api.github.com/users/fanyuecheng/gists{/gist_id}",
         starred_url: "https://api.github.com/users/fanyuecheng/starred{/owner}{/repo}",
         subscriptions_url: "https://api.github.com/users/fanyuecheng/subscriptions",
         organizations_url: "https://api.github.com/users/fanyuecheng/orgs",
         repos_url: "https://api.github.com/users/fanyuecheng/repos",
         events_url: "https://api.github.com/users/fanyuecheng/events{/privacy}",
         received_events_url: "https://api.github.com/users/fanyuecheng/received_events",
         type: "User",
         site_admin: false
     },
     content_type: "application/octet-stream",
     state: "uploaded",
     size: 2116341,
     download_count: 0,
     created_at: "2022-03-03T02:41:09Z",
     updated_at: "2022-03-03T02:41:12Z",
     browser_download_url: "https://github.com/fanyuecheng/Pica/releases/download/v1.2.2/Pica.ipa"
     }
 ],
 tarball_url: "https://api.github.com/repos/fanyuecheng/Pica/tarball/v1.2.2",
 zipball_url: "https://api.github.com/repos/fanyuecheng/Pica/zipball/v1.2.2",
 body: "feat:
 本子详情增加看了这个本子的人也在看功能"
 }
 */

NS_ASSUME_NONNULL_END
