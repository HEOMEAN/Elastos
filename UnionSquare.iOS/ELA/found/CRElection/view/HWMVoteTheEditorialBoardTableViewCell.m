//
//  HWMVoteTheEditorialBoardTableViewCell.m
//  elastos wallet
//
//  Created by 韩铭文 on 2019/9/3.
//

#import "HWMVoteTheEditorialBoardTableViewCell.h"


@interface HWMVoteTheEditorialBoardTableViewCell ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *isSelectedImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *indexNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *AccountedLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalNumberVotesLabel;
@property (weak, nonatomic) IBOutlet UIView *BGView;

@end

@implementation HWMVoteTheEditorialBoardTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [[HMWCommView share]makeBordersWithView:self.BGView];
    [[HMWCommView share]makeTextFieldPlaceHoTextColorWithTextField:self.numberVotingTextField withTxt:NSLocalizedString(@"请输入票数", nil)];
    self.numberVotingTextField.delegate=self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
//  found_vote_select
//    found_not_select
    // Configure the view for the selected state
}
-(void)setModel:(HWMCRListModel *)model{
    self.nickNameLabel.text =model.nickname;

    dispatch_group_t group =  dispatch_group_create();
     __block NSString *locationLabelString;
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       locationLabelString= [[FLTools share]contryNameTransLateByCode:[model.location intValue]];
     });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
          self.locationLabel.text= locationLabelString;
         
     });
         self.indexNumberLabel.text = [NSLocalizedString(@"当前排名：", nil) stringByAppendingString:model.index ];
         self.AccountedLabel.text = [NSString stringWithFormat:@"%@ %@ %@",NSLocalizedString(@"投票占比：", nil),model.voterate,@"%"];
         self.totalNumberVotesLabel.text=[NSString stringWithFormat:@"%@ %ld %@",NSLocalizedString(@"得票总数：", nil),[model.votes longValue],NSLocalizedString(@"票", nil)];
    NSString *imageNameString=@"found_not_select";
    if (_model.isCellSelected) {
         imageNameString=@"found_vote_select";
    }else{
         imageNameString=@"found_not_select";
    }
    self.isSelectedImageView.image =[UIImage imageNamed:imageNameString];
    _model=model;
}
-(void)setIndex:(NSIndexPath *)index{
    _index =index;
    
}
- (IBAction)addVote:(id)sender {
    self.model.isCellSelected=!self.model.isCellSelected;
    //  found_vote_select
    //    found_not_select
    NSString *imageNameString=@"found_not_select";
    if (self.model.isCellSelected) {
        
        imageNameString=@"found_vote_select";
    }else{
     
        imageNameString=@"found_not_select";
        
    }
    self.isSelectedImageView.image =[UIImage imageNamed:imageNameString];
    if (self.deleagte) {
        [self.deleagte addVoteWithIndex:self.index withVotes:self.numberVotingTextField.text];
    }
}
-(void)valuechanged{
    if (self.deleagte) {
        [self.deleagte VoteValueChangeWithIndex:self.index withVotes:self.numberVotingTextField.text];
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([[[textField textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textField textInputMode] primaryLanguage]) {
        return NO;
    }
    NSString *NumbersWithDot = @".1234567890";
    NSString *NumbersWithoutDot = @"1234567890";
    // 判断是否输入内容，或者用户点击的是键盘的删除按钮
    if (![string isEqualToString:@""]) {
        NSCharacterSet *cs;
            NSInteger dotLocation = [textField.text rangeOfString:@"."].location;
            if (dotLocation == NSNotFound ) {
                cs = [[NSCharacterSet characterSetWithCharactersInString:NumbersWithDot] invertedSet];
                if (range.location >= 9) {
                    if ([string isEqualToString:@"."] && range.location == 9) {
                        return YES;
                    }
                    return NO;
                }
            }else {
                cs = [[NSCharacterSet characterSetWithCharactersInString:NumbersWithoutDot] invertedSet];
            }
            // 按cs分离出数组,数组按@""分离出字符串
            NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
            BOOL basicTest = [string isEqualToString:filtered];
            if (!basicTest) {
                return NO;
            }
            if (dotLocation != NSNotFound && range.location > dotLocation + 8) {
                return NO;
            }
            if (textField.text.length > 11) {
                return NO;
            }
    }
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (self.deleagte) {
        [self.deleagte textFieldDidEnd:textField];
    }
    
    
}
@end
