//
//  FLCreatAcountVC.m
//  FLWALLET
//
//  Created by fxl on 2018/4/20.
//  Copyright © 2018年 fxl. All rights reserved.
//

#import "FLCreatAcountVC.h"
#import "FLdoubleWalletVC.h"
@interface FLCreatAcountVC ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *pwdfield1;
@property (weak, nonatomic) IBOutlet UITextField *pwdfield2;
@property (weak, nonatomic) IBOutlet UIButton *stateBtn;
@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIImageView *levelIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *sigainAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *showInfoTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *pwdShowInfoTextLabel;

@end

@implementation FLCreatAcountVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = NSLocalizedString(@"创建钱包", nil);
    self.nameField.placeholder=NSLocalizedString(@"请输入钱包名称", nil);
    self.pwdfield1.placeholder=NSLocalizedString(@"请输入8至16位钱包密码", nil);
    self.pwdfield2.placeholder=NSLocalizedString(@"请再次输入确认钱包密码", nil);
    self.sigainAddressLabel.text=NSLocalizedString(@"单地址钱包", nil); self.nameField.delegate = self;
    self.pwdShowInfoTextLabel.text=NSLocalizedString(@"长度8-16位，且至少包含字母、数字和特殊字符中的2种", nil);
    [self.btn1 setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.15] boldColor:[UIColor whiteColor] corner:0];
    self.pwdfield1.secureTextEntry=YES;
    self.pwdfield2.secureTextEntry=YES;
    [self.pwdfield1 addTarget:self action:@selector(pwdfieldValuChange) forControlEvents:UIControlEventEditingChanged];
    self.showInfoTextLabel.text=NSLocalizedString(@"   密码用于保护私钥和交易授权，强度非常重要. elastos不存储密码，也无法帮您找回，请务必牢记", nil);
    
    [self.btn1 setTitle:NSLocalizedString(@"确认创建", nil) forState:UIControlStateNormal];
   
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self defultWhite];
    self.levelIconImageView.image=[UIImage imageNamed:@"security0"];

    

}
-(void)pwdfieldValuChange{
    NSInteger imagNumber=[[FLTools share]  isStringContainTheLetterNumberSpecialCharactersWith:self.pwdfield1.text];
    self.levelIconImageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"security%ld",imagNumber]];
}
- (IBAction)changeState:(UIButton *)sender {
    sender.selected = !sender.isSelected;
}
- (IBAction)click1:(id)sender {
    
    if (![[FLTools share]checkWalletName:self.nameField.text]) {
        return;
    }
    if ([[FLTools share]checkWhetherThePassword:self.pwdfield1.text]) {
        return ;
    }
    if ([[FLTools share]checkWhetherThePassword:self.pwdfield2.text]) {
        return ;
    }
    if (![self.pwdfield1.text isEqualToString:self.pwdfield2.text]) {
        [[FLTools share]showErrorInfo:NSLocalizedString(@"两次密码输入不一致", nil)];
        return;
    }
    FLWallet *wallet=[[FLWallet alloc]init];
    wallet.walletName=self.nameField.text;
    wallet.passWord=self.pwdfield1.text;
    wallet.isSingleAddress=self.stateBtn.selected;
    FLdoubleWalletVC *vc = [[FLdoubleWalletVC alloc]init];
    vc.Wallet=wallet;
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    [textField becomeFirstResponder];
    
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string

{
    
 

    
    if ([string isEqualToString:@""]) {
        return YES;
    }
 
    
    if ([textField isEqual:self.nameField]) {
        
        if ([[[textField textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textField textInputMode] primaryLanguage]) {
            return NO;
        }
        
//        //判断键盘是不是九宫格键盘
//        if ([[FLTools share] isNineKeyBoard:textField.text] ){
//            return YES;
//        }else{
//            if ([[FLTools share] hasEmoji:textField.text] || [[FLTools share] stringContainsEmoji:textField.text]){
//                return NO;
//            }
//        }
//    
    }
//    if (textField.text.length>11) {
//         textField.text= [textField.text substringToIndex:11];
//    }
//    if ([textField isEqual:self.nameField] &&self.nameField.text.length>6) {
//        textField.text= [self.nameField.text substringToIndex:6];
//    }
    return YES;
 
//       return textField.text.length>11? NO:YES;
}
//- (IBAction)clickbeifen:(id)sender {
//    FLImportWalletVC *vc = [[FLImportWalletVC alloc]init];
//    [self.navigationController pushViewController:vc animated:YES];
//}
//- (IBAction)GoToProtocol:(id)sender {
//    DC_DealTextViewController *vc= [[DC_DealTextViewController alloc]init];
//    vc.dealTextStyle = resgiterStyle;
//    [self.navigationController pushViewController:vc animated:YES];
//}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
@end
