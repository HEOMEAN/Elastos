//
//  FLAssetTableCell.h
//  FLWALLET
//
//  Created by fxl on 2018/4/16.
//  Copyright © 2018年 fxl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLAssetTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UILabel *biName;
@property (weak, nonatomic) IBOutlet UILabel *updatetime;
@property (weak, nonatomic) IBOutlet UILabel *detailLab;
@property (weak, nonatomic) IBOutlet UIView *ProgressCentent;

@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UILabel *progressLab;

@end
