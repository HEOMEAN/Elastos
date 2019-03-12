//
//  FLJoinVoteInfoModel.h
//  elastos wallet
//
//  Created by 樊晓乐 on 2019/1/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLJoinVoteInfoModel : NSObject
@property(nonatomic,copy)NSString    *pubKey;
@property(nonatomic,copy)NSString    *nodePubKey;
@property(nonatomic,copy)NSString    *nickName;
@property(nonatomic,copy)NSString    *url;
@property(nonatomic,copy)NSString    *ipAddress;
@property(nonatomic,copy)NSString    *contryCode;
@property(nonatomic,copy)NSString    *pwd;
@property(nonatomic,assign)NSInteger acount;
@property(nonatomic,copy)NSString    *mark;

@end

NS_ASSUME_NONNULL_END
