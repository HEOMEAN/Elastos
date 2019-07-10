//
//  HWMImportTheMnemonicWordViewController.h
//  elastos wallet
//
//  Created by 韩铭文 on 2019/7/3.
//

#import <UIKit/UIKit.h>

@protocol HWMImportTheMnemonicWordViewControllerDelegate <NSObject>
-(void)ImportTheMnemonicWordViewWithMnemonic:(NSString*)Mnemonic withPWD:(NSString*)PWD withPhrasePassword:(NSString*)phrasePassword;


@end
NS_ASSUME_NONNULL_BEGIN

@interface HWMImportTheMnemonicWordViewController : UIViewController
/*
 *
 */
@property(strong,nonatomic)id<HWMImportTheMnemonicWordViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
