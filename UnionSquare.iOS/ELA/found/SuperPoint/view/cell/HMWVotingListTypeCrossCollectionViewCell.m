//
//  HMWVotingListTypeCrossCollectionViewCell.m
//  elastos wallet
//
//  Created by 韩铭文 on 2019/6/17.
//

#import "HMWVotingListTypeCrossCollectionViewCell.h"


@interface HMWVotingListTypeCrossCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *nickName;
@property (weak, nonatomic) IBOutlet UILabel *contryName;
@property (weak, nonatomic) IBOutlet UILabel *indexLab;
@property (weak, nonatomic) IBOutlet UILabel *percentLab;
@property (weak, nonatomic) IBOutlet UILabel *tickNumberLab;
@property (weak, nonatomic) IBOutlet UIImageView *coinIconImageView;

@end
@implementation HMWVotingListTypeCrossCollectionViewCell


-(void)setModel:(FLCoinPointInfoModel *)model
{
    _model  = model;
    self.nickName.text = model.nickname;
    self.contryName.text = [[FLTools share]contryNameTransLateByCode: model.location.integerValue];
    self.indexLab.text = [@""stringByAppendingString:@(model.index+1).stringValue];
    self.percentLab.text = [NSString stringWithFormat:@"%.5lf %@",model.voterate.floatValue*100,@"%"];
    self.tickNumberLab.text=[NSString stringWithFormat:@"%ld %@",[model.votes longValue],NSLocalizedString(@"票", nil)];
     [self.coinIconImageView sd_setImageWithURL:[NSURL URLWithString:model.iconImageUrl] placeholderImage:[UIImage imageNamed:@"found_vote_initial"]];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    [[HMWCommView share]makeBordersWithView:self];
}

@end
