//
//  FLPastWordVC.h
//  FLWALLET
//
//  Created by  on 2018/8/15.
//  Copyright © 2018年 . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FLPastWordVCDelegate <NSObject>
-(void)backTheWallet:(FLWallet*)wallet;


@end
@interface FLPastWordVC : UIViewController
@property (nonatomic, strong)FLWallet*Wallet;
/*
 *<# #>
 */
@property(strong,nonatomic)id<FLPastWordVCDelegate>delegate;

@end
