//
//  HWMDIDListAbnormalTableViewCell.m
//  elastos wallet
//
//  Created by 韩铭文 on 2019/10/30.
//

#import "HWMDIDListAbnormalTableViewCell.h"

@interface HWMDIDListAbnormalTableViewCell ()
@property (weak, nonatomic) IBOutlet UIView *BGView;
@property (weak, nonatomic) IBOutlet UILabel *DIDNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation HWMDIDListAbnormalTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.BGView.layer.cornerRadius=5.f;
    self.BGView.layer.masksToBounds=YES;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
