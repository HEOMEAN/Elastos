//
//  HMWImTheMnemonicWordView.m
//  ELA
//
//  Created by 韩铭文 on 2019/1/4.
//  Copyright © 2019 HMW. All rights reserved.
//

#import "HMWImTheMnemonicWordView.h"
#import "UIViewController+FLVCExt.h"



@interface HMWImTheMnemonicWordView ()<UITextViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *whetherTheSingleAddressButton;
@property (weak, nonatomic) IBOutlet UITextView *theMnemonicWordTextView;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextFiedl;
@property (weak, nonatomic) IBOutlet UITextField *walletNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *againPWDTextField;
@property (weak, nonatomic) IBOutlet UITextField *theMnemonicWordPWDTextField;

@property (weak, nonatomic) IBOutlet UIButton *confirmTheImportButton;
@property (weak, nonatomic) IBOutlet UISwitch *showOrHideThePasswordSwitch;
@property (weak, nonatomic) IBOutlet UILabel *walletWordSwitchInfoTextLabel;
@property (weak, nonatomic) IBOutlet UIView *passWordContentView;
/*
 *<# #>
 */
@property(copy,nonatomic)NSString *palceString;
@property (weak, nonatomic) IBOutlet UILabel *pwdShowInfoTextLabel;

@end

@implementation HMWImTheMnemonicWordView

-(instancetype)init{
    self =[super init];
    if (self) {
        self =[[NSBundle mainBundle]loadNibNamed:@"HMWImTheMnemonicWordView" owner:nil options:nil].firstObject;
    self.walletWordSwitchInfoTextLabel.text=NSLocalizedString(@"助记词密码（可选）", nil);
        self.palceString=NSLocalizedString(@"助记词之间请使用空格隔开", nil);
      self.theMnemonicWordPWDTextField.placeholder=NSLocalizedString(@"请输入当前钱包的助记词密码", nil); self.pwdTextFiedl.placeholder=NSLocalizedString(@"请输入8至16位钱包密码", nil); self.theMnemonicWordTextView.text=self.palceString;
        [self.confirmTheImportButton setTitle:NSLocalizedString(@"确认导入", nil) forState:UIControlStateNormal];
      [[HMWCommView share]makeBordersWithView:self.theMnemonicWordTextView];
        [[HMWCommView alloc]makeTextFieldPlaceHoTextColorWithTextField:self.pwdTextFiedl];
         [[HMWCommView alloc]makeTextFieldPlaceHoTextColorWithTextField:self.walletNameTextField];
          [[HMWCommView alloc]makeTextFieldPlaceHoTextColorWithTextField:self.againPWDTextField];
         [[HMWCommView alloc]makeTextFieldPlaceHoTextColorWithTextField:self.theMnemonicWordPWDTextField];
        [[HMWCommView share]makeBordersWithView:self.confirmTheImportButton];
        self.showOrHideThePasswordSwitch.layer.borderColor=[UIColor whiteColor].CGColor;
        self.showOrHideThePasswordSwitch.layer.borderWidth=2.f;
        self.showOrHideThePasswordSwitch.layer.cornerRadius=15.f; self.showOrHideThePasswordSwitch.layer.masksToBounds=YES;
        
        self.showOrHideThePasswordSwitch.transform=CGAffineTransformMakeScale(0.75, 0.75);
        self.passWordContentView.hidden = !self.showOrHideThePasswordSwitch.isOn;
        self.theMnemonicWordTextView.delegate=self;
        self.againPWDTextField.secureTextEntry=YES;
        self.pwdTextFiedl.secureTextEntry=YES;
        self.theMnemonicWordPWDTextField.secureTextEntry=YES;
        self.walletNameTextField.placeholder=NSLocalizedString(@"请输入钱包名称", nil);
        self.againPWDTextField.placeholder=NSLocalizedString(@"请再次输入确认密码", nil);
        self.whetherTheSingleAddressButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.whetherTheSingleAddressButton setTitle:NSLocalizedString(@"单地址钱包", nil) forState:UIControlStateNormal];
        self.pwdShowInfoTextLabel.text=NSLocalizedString(@"长度8-16位，且至少包含字母、数字和特殊字符中的2种", nil);
        self.theMnemonicWordPWDTextField.delegate=self;
    }
    
    return self;
    
    
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    if ([self.theMnemonicWordTextView.text isEqualToString:self.palceString]) {
          self.theMnemonicWordTextView.text=@"";
    }
    
    self.theMnemonicWordTextView.textColor=[UIColor whiteColor];
    
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    if (self.theMnemonicWordTextView.text.length==0) {
        self.theMnemonicWordTextView.text=self.palceString;
        self.theMnemonicWordTextView.textColor=RGBA(255, 255, 255, 0.5);
    }
    
}
- (IBAction)ShowHidenView:(UISwitch*)sender {
    
    self.passWordContentView.hidden = !sender.isOn;
    
}
- (IBAction)confirmTheImportEvent:(id)sender {
    if (![[FLTools share]checkWalletName:self.walletNameTextField.text]) {
        
        
        return;
    }
    if ([[FLTools share]checkWhetherThePassword:self.pwdTextFiedl.text]) {
        return ;
    }
    if ([[FLTools share]checkWhetherThePassword:self.againPWDTextField.text]) {
        return ;
    }
    if (![self.pwdTextFiedl.text isEqualToString:self.againPWDTextField.text]) {
        [[FLTools share]showErrorInfo:NSLocalizedString(@"两次密码输入不一致", nil)];
        return;
    }
    FLWallet *wallet=[[FLWallet alloc]init];
    
    wallet.walletName=self.walletNameTextField.text;
    wallet.passWord=self.pwdTextFiedl.text;
    wallet.mnemonicPWD=self.theMnemonicWordPWDTextField.text;
    wallet.isSingleAddress=self.whetherTheSingleAddressButton.isSelected;
    wallet.mnemonic=self.theMnemonicWordTextView.text;
    
    if ([self.delegate respondsToSelector:@selector(ImTheMnemonicWordViewCompWithWallet:)]) {
        [self.delegate ImTheMnemonicWordViewCompWithWallet:wallet];
        
    }
    
    
}
- (IBAction)whetherTheSingleAddressEvent:(id)sender {
    self.whetherTheSingleAddressButton.selected=!self.whetherTheSingleAddressButton.selected;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self endEditing:YES];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if (textField==self.theMnemonicWordPWDTextField) {
        [self.VC NotificationCenter];
    }
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    if (textField==self.theMnemonicWordPWDTextField) {
        [self.VC reMovNotificationCenter];
    }
    
    
}
@end
