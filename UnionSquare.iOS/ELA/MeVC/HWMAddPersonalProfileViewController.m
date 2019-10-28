//
//  HWMAddPersonalProfileViewController.m
//  elastos wallet
//
//  Created by 韩铭文 on 2019/10/28.
//

#import "HWMAddPersonalProfileViewController.h"
#import "HWMAddSocialAccountViewController.h"
static NSString *placeHText=@"请输入个人简介（不超过800个字符）";
@interface HWMAddPersonalProfileViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *textInfoLabel;
/*
 *<# #>
 */
@property(strong,nonatomic)UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end

@implementation HWMAddPersonalProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
         [self defultWhite];
     [self setBackgroundImg:@""];
     
     self.title=NSLocalizedString(@"添加个人简介", nil);
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:self.skipButton];
    self.textInfoLabel.text=NSLocalizedString(@"温馨提示：本页内容均为非必填项。", nil);
    self.infoTextView.delegate=self; self.infoTextView.layer.cornerRadius=5.f;
    self.infoTextView.layer.borderWidth=1.f;
    self.infoTextView.layer.borderColor=RGBA(255, 255, 255, 0.5).CGColor;
    
    [[HMWCommView share]makeBordersWithView:self.nextButton];
}
-(UIButton *)skipButton{
    if (!_skipButton) {
        _skipButton =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        [_skipButton setTitle:NSLocalizedString(@"跳过", nil) forState:UIControlStateNormal];
        [_skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _skipButton.titleLabel.font=[UIFont systemFontOfSize:14];
        [_skipButton addTarget:self action:@selector(skipVCEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    return _skipButton;
}
-(void)skipVCEvent{
    HWMAddSocialAccountViewController *AddSocialAccountVC=[[HWMAddSocialAccountViewController alloc]init];
    [self.view endEditing:YES];
    [self.navigationController pushViewController:AddSocialAccountVC animated:YES];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
}
- (IBAction)nextAndSkipVC:(id)sender {
    [self skipVCEvent];
}
- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([self.infoTextView.text isEqualToString:placeHText]) {
        self.infoTextView.text=@"";
        self.infoTextView.textColor=[UIColor whiteColor];
    }
    
    
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    
    if ([self.infoTextView.text isEqualToString:placeHText]||self.infoTextView.text.length==0) {
           self.infoTextView.text=placeHText;
           self.infoTextView.textColor=RGBA(255, 255, 255, 0.5);
       }
    
}
@end
