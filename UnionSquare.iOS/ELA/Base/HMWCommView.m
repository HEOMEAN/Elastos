//
//  HMWCommView.m
//  ELA
//
//  Created by  on 2018/12/26.
//  Copyright © 2018 HMW. All rights reserved.
//

#import "HMWCommView.h"


@implementation HMWCommView

static HMWCommView *tool;

+(instancetype)share{
    if (!tool) {
        tool = [[self alloc]init];
    }
    return tool;
    
}
-(instancetype)init{
    self = [super init];

    return self;
}
-(void)makeBordersWithView:(UIView*)view{
    
    view.layer.borderWidth=1.f;
    view.layer.borderColor=RGBA(255, 255, 255, 1).CGColor;
//    view.layer.masksToBounds=YES;
    
    
    
}
-(void)makeTextFieldPlaceHoTextColorWithTextField:(UITextField*)textf{
    [textf setValue:RGBA(255, 255, 255, 0.5) forKeyPath:@"_placeholderLabel.textColor"];
    
    
}
@end
