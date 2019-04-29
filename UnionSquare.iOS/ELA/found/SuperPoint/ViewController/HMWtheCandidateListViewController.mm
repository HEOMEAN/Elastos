//
//  HMWtheCandidateListViewController.m
//  ELA
//
//  Created by 韩铭文 on 2019/1/6.
//  Copyright © 2019 HMW. All rights reserved.
//

#import "HMWtheCandidateListViewController.h"
#import "HMWtheCandidateListTableViewCell.h"
#import "FLNotePointDBManager.h"
#import "HMWinputVotesPopupWindowView.h"
#import "ELWalletManager.h"
#import "HMWpwdPopupView.h"
#import "HMWSendSuccessPopuView.h"
#import "HMWToDeleteTheWalletPopView.h"
static NSString *cellString=@"HMWtheCandidateListTableViewCell";
@interface HMWtheCandidateListViewController ()<UITableViewDelegate,UITableViewDataSource,HMWpwdPopupViewDelegate,VotesPopupViewDelegate,HMWToDeleteTheWalletPopViewDelegate>
@property(strong,nonatomic)HMWSendSuccessPopuView *sendSuccessPopuV;//交易成功 提示;
@property (weak, nonatomic) IBOutlet UILabel *TagtatolVoteLab;

@property (weak, nonatomic) IBOutlet UITableView *baseTableView;
@property(nonatomic,strong)UIImageView *placeHolferImage;

@property(nonatomic,strong)NSMutableArray *dataSource;
@property(nonatomic,strong)UIButton *editBtn;//右 btn

//下三uibutton
@property (weak, nonatomic) IBOutlet UILabel *hasSelectNumber;
@property (weak, nonatomic) IBOutlet UIButton *selectAllBtn;
@property (weak, nonatomic) IBOutlet UIButton *immediatelyToVoteButton;

@property(nonatomic,strong)NSMutableArray *voteArray;
@property(nonatomic,strong)NSMutableArray *deleteArray;

@property(nonatomic,strong)HMWinputVotesPopupWindowView *inputVoteTicketView;//票数视图
@property(strong,nonatomic)HMWpwdPopupView *pwdPopupV;//密码视图
@property(nonatomic,assign)NSInteger ticket;

@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UILabel *persentLab;
/*
 *<# #>
 */
@property(strong,nonatomic)HMWToDeleteTheWalletPopView *moreThan36View;

@end

@implementation HMWtheCandidateListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self defultWhite];
    [self setBackgroundImg:@"tab_bg"];
    self.title=NSLocalizedString(@"我的候选列表", nil);
    self.TagtatolVoteLab.text=NSLocalizedString(@"全网投票比例：", nil);
    [self.immediatelyToVoteButton setTitle:NSLocalizedString(@"立即投票", nil) forState:UIControlStateNormal];

    [[HMWCommView share]makeBordersWithView:self.immediatelyToVoteButton];
    [self getDBRecored];
    [self makeView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.editBtn];
    self.progress.progress = self.persent.floatValue;
    self.persentLab.text = self.persent;
//    self.persentLab.text = [self.persent stringByAppendingString:@"%"];
    [self.selectAllBtn setImage:[UIImage imageNamed:@"found_vote_selected"] forState:UIControlStateSelected];
    [self.selectAllBtn setImage:[UIImage imageNamed:@"found_vote_border"] forState:UIControlStateNormal];
}
-(HMWToDeleteTheWalletPopView *)moreThan36View{
    if (!_moreThan36View) {
        _moreThan36View =[[HMWToDeleteTheWalletPopView alloc]init];
        _moreThan36View.delegate=self;
        _moreThan36View.deleteType=moreThan36SelectList;
    }
    return _moreThan36View;
}
-(void)selectMoreThan36{
    UIView *maView=[self mainWindow];
    [maView addSubview:self.moreThan36View];
    [self.moreThan36View mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(maView);
    }];
   
    
}
#pragma mark ---------HMWToDeleteTheWalletPopViewDelegate----------
-(void)sureToDeleteViewWithPWD:(NSString*)pwd{
     [self clearVoteArray];
    for (int i= 0; i<36; i++) {
        NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
        [self.baseTableView selectRowAtIndexPath:index animated:YES scrollPosition:UITableViewScrollPositionNone];
        [self tableView:self.baseTableView didSelectRowAtIndexPath:index];
    }
    self.selectAllBtn.selected=YES;
    [self toCancelOrCloseDelegate];
}
-(void)toCancelOrCloseDelegate{
    [self.moreThan36View removeFromSuperview];
    self.moreThan36View=nil;
}

-(void)getDBRecored{
    self.dataSource  = [[NSMutableArray alloc]initWithArray: [[FLNotePointDBManager defult]allRecord]];
    [self.baseTableView reloadData];
}
- (IBAction)actAction:(UIButton*)sender {
    
    if (self.editBtn.isSelected) {

        for (int i= 0; i<self.voteArray.count; i++) {
            FLCoinPointInfoModel *model = self.voteArray[i];

            [[FLNotePointDBManager defult]delectRecord:model];
            [self.dataSource removeObject:model];
        }
        [self.voteArray removeAllObjects];

        [self.baseTableView reloadData];
        [self updataBottomBtn];
        
    }else{
        if (self.voteArray.count == 0) {
            return;
        }
        if (self.voteArray.count>36) {
            [[FLTools share]showErrorInfo:NSLocalizedString(@"最多可选36个节点", nil)];
            return;
        }
        
        ELWalletManager *manager   =  [ELWalletManager share];
        
        IMainchainSubWallet *mainchainSubWallet = [manager getWalletELASubWallet:manager.currentWallet.masterWalletID];
       [self.view.window addSubview:self.inputVoteTicketView];
//        Elastos::ElaWallet::BalanceType type = Elastos::ElaWallet::Total;
        NSUInteger balance = mainchainSubWallet->GetBalance(Elastos::ElaWallet::Total);
        self.inputVoteTicketView.votes = balance/unitNumber;

        self.inputVoteTicketView.accountBalanceLab.text = [NSLocalizedString(@"最大表决票权 ",nil ) stringByAppendingString: @(balance/unitNumber).stringValue];
        
    }
    
}


- (IBAction)selectAllAction:(UIButton*)sender {

   
  
    if (sender.isSelected) {
         [self clearVoteArray];
        sender.selected = NO;
        for (int i= 0; i<self.dataSource.count; i++) {
            NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
            [self.baseTableView deselectRowAtIndexPath:index animated:YES];
            [self tableView:self.baseTableView didDeselectRowAtIndexPath:index];
        }
    }else{
        
        if (self.dataSource.count>36) {
            [self  selectMoreThan36];
            return;
        }
         [self clearVoteArray];
       sender.selected = YES;

    for (int i= 0; i<self.dataSource.count; i++) {
        NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
        [self.baseTableView selectRowAtIndexPath:index animated:YES scrollPosition:UITableViewScrollPositionNone];
        [self tableView:self.baseTableView didSelectRowAtIndexPath:index];
    }
    }
    
}
-(void)clearVoteArray{
    
    [self.voteArray removeAllObjects];
    [self.baseTableView reloadData];
    [self updataBottomBtn];
}
-(void)makeView{
    self.baseTableView.delegate=self;
    self.baseTableView.dataSource=self;
    self.baseTableView.rowHeight=70;
    self.baseTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.baseTableView registerNib:[UINib nibWithNibName:cellString bundle:nil] forCellReuseIdentifier:cellString];
    self.baseTableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    self.baseTableView.allowsMultipleSelection = YES;
    
    [self.baseTableView addSubview:self.placeHolferImage];
    self.placeHolferImage.center = self.baseTableView.center;
    self.placeHolferImage.hidden = self.dataSource.count!=0;
    
    [self updataBottomBtn];
}

-(void)updataBottomBtn{
    self.hasSelectNumber.text = [NSString stringWithFormat:@"%lu %@",(unsigned long)self.voteArray.count,NSLocalizedString(@"已选择", nil)];
    [self.selectAllBtn  setTitle:[NSString stringWithFormat:@"%@(%lu/%ld)",NSLocalizedString(@"全选", nil), self.voteArray.count,self.dataSource.count] forState:UIControlStateNormal]  ;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataSource.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
   HMWtheCandidateListTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellString];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor clearColor];
    FLCoinPointInfoModel *model = self.dataSource[indexPath.row];
    cell.model = model;
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FLCoinPointInfoModel *model = self.dataSource[indexPath.row];
    if (![self.voteArray containsObject:model]) {
        [self.voteArray addObject:model];
    }
   
    [self updataBottomBtn];
//    HMWtransferTransactionDetailsViewController *transferTransactionDetailsVC=[[HMWtransferTransactionDetailsViewController alloc]init];
//    [self.navigationController pushViewController:transferTransactionDetailsVC animated:YES];
    
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FLCoinPointInfoModel *model = self.dataSource[indexPath.row];
    if ([self.voteArray containsObject:model]) {
        [self.voteArray removeObject:model];
    }
    [self updataBottomBtn];
}

-(void)editStateChange:(UIButton*)btn{
    self.editBtn.selected = !self.editBtn.isSelected;
    NSString *title = self.editBtn.isSelected ?NSLocalizedString(@"删除", nil):NSLocalizedString(@"立即投票", nil);
    [self.immediatelyToVoteButton setTitle:title forState:UIControlStateNormal];
    self.hasSelectNumber.hidden = self.editBtn.selected;
    
    [self clearVoteArray];
    self.selectAllBtn.selected = YES;
    [self selectAllAction:self.selectAllBtn];
    
}

#pragma mark 代理
-(void)didHadInputVoteTicket:(NSString *)ticketNumer
{
    [self.inputVoteTicketView removeFromSuperview];
    self.inputVoteTicketView= nil;
    self.ticket = ticketNumer.integerValue;
    [self.view.window addSubview:self.pwdPopupV];
    
}
-(void)cancelThePWDPageView
{
    [self.pwdPopupV removeFromSuperview];
    self.pwdPopupV  = nil;
}
-(void)makeSureWithPWD:(NSString*)pwd{
    
    NSMutableArray *stringArray = [NSMutableArray array];
    for (int i= 0; i<self.voteArray.count; i++) {
        FLCoinPointInfoModel *model = self.voteArray[i];
        [stringArray addObject:model.ownerpublickey];
    }
    NSString *walletId = [ELWalletManager share].currentWallet.masterWalletID;
   BOOL ret = [[ELWalletManager share]useMainchainSubWallet:walletId ToVote:stringArray tickets:self.ticket pwd:pwd isChangeVote:YES];
    if (ret) {
        
        [self showSendSuccessPopuV];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.sendSuccessPopuV removeFromSuperview];
            self.sendSuccessPopuV=nil;
        });
       
    }
    [self.pwdPopupV removeFromSuperview];
    self.pwdPopupV =  nil;
   
 
}

-(HMWSendSuccessPopuView *)sendSuccessPopuV{
    if (!_sendSuccessPopuV) {
        _sendSuccessPopuV =[[HMWSendSuccessPopuView alloc]init];
        UIView *manView=[self mainWindow];
        [manView addSubview:self.sendSuccessPopuV];
        [self.sendSuccessPopuV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(manView);
        }];
    }
    return _sendSuccessPopuV;
}
-(void)showSendSuccessPopuV{
    self.sendSuccessPopuV.hidden = NO;
}

#pragma mark lazy


-(HMWinputVotesPopupWindowView *)inputVoteTicketView
{
    if (!_inputVoteTicketView ) {
        _inputVoteTicketView = [[HMWinputVotesPopupWindowView alloc]init];
        _inputVoteTicketView.frame = [UIScreen mainScreen].bounds;
        _inputVoteTicketView.delegate = self;
    }
    return _inputVoteTicketView;
}
-(UIButton *)editBtn
{
    if (!_editBtn) {
        _editBtn = [[UIButton alloc]init];
        [_editBtn setImage:[UIImage imageNamed: @"found_vote_edit"] forState:UIControlStateNormal];
        [_editBtn setImage:[UIImage imageNamed:@"found_vote_finish"] forState:UIControlStateSelected];
        [_editBtn addTarget:self action:@selector(editStateChange:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _editBtn;
}
-(NSMutableArray *)voteArray
{
    if (!_voteArray) {
        _voteArray  =[NSMutableArray array];
    }
    return _voteArray;
}
-(NSMutableArray *)deleteArray
{
    if (!_deleteArray) {
        _deleteArray  =[NSMutableArray array];
    }
    return _deleteArray;
}
-(HMWpwdPopupView *)pwdPopupV{
    if (!_pwdPopupV) {
        _pwdPopupV=[[HMWpwdPopupView alloc]init];
        _pwdPopupV.frame = [UIScreen mainScreen].bounds;
        _pwdPopupV.delegate=self;
    }
    return _pwdPopupV;
    
}
-(UIImageView *)placeHolferImage
{
    if (!_placeHolferImage) {
        _placeHolferImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed: @"found_vote_empty_list"]];
    }
    return _placeHolferImage;
    
}

@end
