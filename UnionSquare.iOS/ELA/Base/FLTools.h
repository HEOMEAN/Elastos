//
//  FLTools.h
//  FLWALLET
//
//  Created by fxl on 2018/4/19.
//  Copyright © 2018年 fxl. All rights reserved.
//

#import <Foundation/Foundation.h>
//待用
@interface FLFLUser : NSObject
@property (nonatomic, copy)NSString *userId;
@property (nonatomic, copy)NSString *loginId;
@property (nonatomic, copy)NSString *deviceId;
@property (nonatomic, copy)NSString *mobilePhone;
@property (nonatomic, copy)NSString *loginToken;
@property (nonatomic, copy)NSString *passWord;
@property (nonatomic, copy)NSString *nickName;
@property (nonatomic, copy)NSString *headImg;

@property (nonatomic, copy)NSString *borrmeUserId;
@property (nonatomic, assign)NSInteger certificated;
@property (nonatomic, assign)NSInteger  currencyType; //
@property (nonatomic, assign)NSInteger  CNTOCurrencyWallteIndex;
@property (nonatomic, copy)NSString * CNTOWallteWallteAddress;
/*
 *<# #>
 */
@property(copy,nonatomic)NSString *firstFriends;
/*
 *<# #>
 */
@property(copy,nonatomic)NSString *isNode;
/*
 *<# #>
 */
@property(copy,nonatomic)NSString *tradingPassword;
/*
 *
 */
@property(copy,nonatomic)NSString *areaCode;
/*
 *<# #>
 */
@property(copy,nonatomic)NSString *channelType;
/*
 *<# #>
 */
@property(copy,nonatomic)NSString *channelId;

@end

@interface FLWallet :NSObject
@property (nonatomic, copy)NSString *walletAddress;
@property (nonatomic, copy)NSString *privateKey;
@property (nonatomic, copy)NSString *keyStore;
@property (nonatomic, copy)NSString *walletName;
@property (nonatomic, copy)NSString *passWord;
@property (nonatomic, copy)NSString *balance;
@property (nonatomic,assign)NSInteger curretIndex;
@property (nonatomic, copy) NSString* mnemonic;
@property (nonatomic, copy)NSString *logoNumber;//indexIcion
/*
 *<# #>
 */
@property(assign,nonatomic)BOOL isSingleAddress;
@property (nonatomic, copy) NSString* mnemonicPWD;
@property (nonatomic, copy) NSString* walletID;
/*
 *<# #>
 */
@property(copy,nonatomic)NSString *masterWalletID;
@end

@class YYCache;
@interface FLTools : NSObject
@property (nonatomic,readonly)YYCache *cache;
@property (nonatomic, strong)FLFLUser *user;
@property(nonatomic,strong)FLWallet *SUPMTCurrencyWallte;


+(instancetype)share;
-(void)saveUserModel;
-(void)clearlist;
//-(NSMutableArray*)getWalletList;
- (NSString *)getTimeFromTimesTamp:(NSString *)timeStr;
//YYYY/MM/dd HH:mm:ss
- (NSString *)YMDHMSgetTimeFromTimesTamp:(NSString *)timeStr;
//
- (NSString *)CNTOYMDHMSgetTimeFromTimesTamp:(NSString *)timeStr;
-(void)showLoadingView;
-(void)showErrorInfo:(NSString*)info;
-(CGFloat)gasETHwithGasPrice:(NSString*)gasPrice withLimetPrice:(NSString*)LimetPrice;
-(BOOL)isNineKeyBoard:(NSString *)string;
- (BOOL)hasEmoji:(NSString*)string;
- (BOOL)stringContainsEmoji:(NSString *)string;
-(NSString *)notRounding:(NSString *)priceString afterPoint:(int)position;
-(BOOL)checkWhetherThePassword:(NSString*)passWord;
-(NSInteger)isStringContainTheLetterNumberSpecialCharactersWith:(NSString *)str;
//YYYY.MM.dd"
- (NSString *)YMDCommunityTimeConversionTimeFromTimesTamp:(NSString *)timeStr;

// YYYY.MM.dd HH:mm:ss
-(NSString *)YMDCommunityTimeConversToAllFromTimesTamp:(NSString *)timeStr;
-(void)copiedToTheClipboardWithString:(NSString*)str;
-(NSString*)pastingTextFromTheClipboard;
-(BOOL)checkWalletName:(NSString*)walletName;
-(NSArray*)stringToArray:(NSString*)str;
-(NSString *)getNowTimeTimestamp;
-(NSString *)getRandomStringWithNum:(NSInteger)num;
-(NSString*)getCurrentTimes;
-(NSString *)formattermnemonicWord:(NSString *)string;
-(NSString*)elaScaleConversionWith:(NSString*)el;

-(NSString *)contryNameTransLateByCode:(NSInteger)code;
-(NSString *)elsToSela:(NSString*)ela;
-(BOOL)changeisEnglish:(NSString*)m;
-(NSString *)getImageViewURLWithURL:(NSString*)urlString;
@end
