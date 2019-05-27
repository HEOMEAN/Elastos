//
//  FirstViewController.m
//  FLWALLET
//
//  Created by fxl on 2018/4/11.
//  Copyright © 2018年 fxl. All rights reserved.
//

#import "FirstViewController.h"
#import "FLAssetTableCell.h"
#import "FLPrepareVC.h"
#import "FLQRVC.h"
#import "FLCreatAcountVC.h"
#import "FLAllKindBi.h"
#import "MJRefresh.h"
#import "WCQRCodeScanningVC.h"
#import "FLCapitalView.h"
#import "FLAllAssetListVC.h"
#import "IMasterWalletManager.h"
#import "HMWaddFooterView.h"
#import "HMWAssetDetailsViewController.h"
#import "HMWAddTheCurrencyListViewController.h"
#import "HMWTheWalletListViewController.h"
#import "HMWTheWalletManagementViewController.h"
#import "ELWalletManager.h"
#import "assetsListModel.h"
#import "HMWFMDBManager.h"
#import "FLPrepareVC.h"
#import "sideChainInfoModel.h"




@interface FirstViewController ()<FLCapitalViewDelegate,UITableViewDelegate,UITableViewDataSource,HMWaddFooterViewDelegate,HMWTheWalletListViewControllerDelegate>
{
    FLWallet *_currentWallet;
}
@property (nonatomic,strong) UITableView *table;

@property (nonatomic, strong)FLCapitalView *headerView;
//@property (nonatomic, strong)
@property (nonatomic, strong)NSMutableArray *dataSoureArray;
@property (nonatomic, strong)NSMutableDictionary*tokenAddresses;
@property (nonatomic, strong)FLPrepareVC *prepare;
@property (nonatomic, strong)UIButton *rightBtn;
@property (nonatomic, strong)UIButton *addBtn;
/*
 *<# #>
 */
@property(assign,nonatomic)NSInteger currentWalletIndex;
@property(copy,nonatomic)NSArray *walletIDListArray;
@property(nonatomic,strong)FLWallet *currentWallet;


@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self setBackgroundImg:@"tab_bg"];
    [self setView];
    self.title = NSLocalizedString(@"资产", nil);
    
//    [self NewStateView:defultColor];

//    [self setWallet];
    
    NSInteger selectIndex=
    [[STANDARD_USER_DEFAULT valueForKey:selectIndexWallet] integerValue];
    
    
    if (selectIndex<0) {
        selectIndex=0;
    }
    [self loadTheWalletInformationWithIndex:selectIndex];
  
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updataWalletListInfo:) name:updataWallet object:nil];
    
      [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(iconInfoUpdate:) name:progressBarcallBackInfo object:nil];
      [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(currentWalletAccountBalanceChanges:) name: AccountBalanceChanges object:nil];
       [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(iconInfoUpdate:) name:progressBarcallBackInfo object:nil];
         [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updataCreateWalletLoadWalletInfo) name:updataCreateWallet object:nil];

}
-(void)updataCreateWalletLoadWalletInfo{
    self.walletIDListArray=nil;
 
        [self loadTheWalletInformationWithIndex:self.walletIDListArray.count-1];
    
    
}
-(void)currentWalletAccountBalanceChanges:(NSNotification *)notification{
    
    NSDictionary *dic=[[NSDictionary alloc]initWithDictionary:notification.object];
    NSArray *infoArray=[[FLTools share]stringToArray:dic[@"callBackInfo"]];
    
    NSString *walletID=infoArray.firstObject;
    NSString *chainID=infoArray[1];
    NSInteger index = [infoArray[2] integerValue];
    
//    asset":assetString,@"balance"
    
//    NSString * currentBlockHeight=dic[@"currentBlockHeight"];
    if (self.dataSoureArray.count<index) {
        return;
    }
    NSString *  balance=dic[@"balance"];
    assetsListModel *model=self.dataSoureArray[index];
    
    
    if ([model.iconName isEqualToString:chainID]&&[self.currentWallet.masterWalletID isEqualToString:walletID]){
        

        model.iconBlance=balance;
        
        self.dataSoureArray[index]=model;
        NSIndexPath *indexP=[NSIndexPath indexPathForRow:index inSection:0];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.table reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexP,nil] withRowAnimation:UITableViewRowAnimationNone];
            
        });
        
        
        
        
        
    }
}
-(void)iconInfoUpdate:(NSNotification *)notification{
    NSDictionary *dic=[[NSDictionary alloc]initWithDictionary:notification.object];
    NSArray *infoArray=[[FLTools share]stringToArray:dic[@"callBackInfo"]];
    
    NSString *walletID=infoArray.firstObject;
    NSString *chainID=infoArray[1];
    NSInteger index = [infoArray[2] integerValue];
    NSString *lastBlockTimeString=dic[@"lastBlockTimeString"];
    if (self.dataSoureArray.count<index) {
        return;
    }
    NSString * currentBlockHeight=dic[@"currentBlockHeight"];
 
     NSString *  progress=dic[@"progress"];
    assetsListModel *model=self.dataSoureArray[index];
 
    
    if ([model.iconName isEqualToString:chainID]&&[self.currentWallet.masterWalletID isEqualToString:walletID]){
        if ([chainID isEqualToString:@"ELA"]) {
            [ELWalletManager share].estimatedHeight=currentBlockHeight;
        }
 
        model.thePercentageMax=[progress floatValue];
        model.thePercentageCurr=[currentBlockHeight floatValue];
        if (lastBlockTimeString.length>0) {
            sideChainInfoModel *smodel=[[sideChainInfoModel alloc]init];
            smodel.walletID=self.currentWallet.masterWalletID;
            smodel.sideChainName=model.iconName;
            smodel.sideChainNameTime=lastBlockTimeString;
            
            [[HMWFMDBManager sharedManagerType:sideChain] sideChainUpdate:smodel];
            model.updateTime=[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"已同步区块时间", nil),smodel.sideChainNameTime];
        }
//        if (model.thePercentageMax==model.thePercentageCurr) {
        
            
//        }
        self.dataSoureArray[index]=model;
        NSIndexPath *indexP=[NSIndexPath indexPathForRow:index inSection:0];
    
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.table reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexP,nil] withRowAnimation:UITableViewRowAnimationNone];

        });
        
      
     
        
        
    }

    
    
    
}
-(void)updataWalletListInfo:(NSNotification *)notification{
    self.walletIDListArray=nil;
    if (notification.object!=nil) {
        [self loadTheWalletInformationWithIndex:self.currentWalletIndex];
    }else{
        [self loadTheWalletInformationWithIndex:0];
    }
    
    
}
-(NSArray *)walletIDListArray{
    if (!_walletIDListArray) {
  
        
        _walletIDListArray=[NSArray arrayWithArray:[[HMWFMDBManager sharedManagerType:walletType] allRecordWallet]];
    }
    return _walletIDListArray;
    
}
- (NSMutableArray *)dataSoureArray{
    if (!_dataSoureArray) {
        _dataSoureArray =[[NSMutableArray alloc]init];
    }
    return _dataSoureArray;
}

//-(FLWallet *)currentWallet{
//    if (!_currentWallet) {
//        _currentWallet =[[FLWallet alloc]init];
//    }
//    return _currentWallet;
//}

-(void)setCurrentWallet:(FLWallet *)currentWallet
{
    _currentWallet = currentWallet;
    [ELWalletManager share].currentWallet = currentWallet;
}
-(void)loadTheWalletInformationWithIndex:(NSInteger)inde{
    
    if (self.walletIDListArray.count==0) {
        FLPrepareVC *vc=[[FLPrepareVC alloc]init];
        vc.type=creatWalletType;
        [self.navigationController pushViewController:vc animated:YES];
        
        return;
    }
    [STANDARD_USER_DEFAULT setValue:[NSString stringWithFormat:@"%ld",inde] forKey:selectIndexWallet];
    [STANDARD_USER_DEFAULT synchronize];
    
    self.currentWalletIndex=inde;
    FMDBWalletModel *model=self.walletIDListArray[inde];
    
    FLWallet *wallet =[[FLWallet alloc]init];
    wallet.masterWalletID =model.walletID;
    wallet.walletName     =model.walletName;
    wallet.walletAddress  = model.walletAddress;
    
    wallet.walletID       =[NSString stringWithFormat:@"%@%@",@"wallet",[[FLTools share] getNowTimeTimestamp]];
    
    self.currentWallet    = wallet;
  self.navigationItem.title = model.walletName;
    

    invokedUrlCommand *mommand=[[invokedUrlCommand alloc]initWithArguments:@[self.currentWallet.masterWalletID] callbackId:self.currentWallet.walletID className:@"Wallet" methodName:@"getAllSubWallets"];
    
  PluginResult * result =[[ELWalletManager share]getAllSubWallets:mommand];
    NSString *status=[NSString stringWithFormat:@"%@",result.status];
    if ([status isEqualToString:@"1"]) {
        
    NSArray  *array = [[FLTools share]stringToArray:result.message[@"success"]];
        
        if (array.count>0) {
            [self getBalanceList:array];
            
        }
    
    }

}
-(void)getBalanceList:(NSArray*)arr{
    if (self.dataSoureArray.count>0) {
        [self.dataSoureArray removeAllObjects];
    }

    int index=0;
    for (NSString *currencyName in arr) {
   
        invokedUrlCommand *mommand=[[invokedUrlCommand alloc]initWithArguments:@[self.currentWallet.masterWalletID,currencyName,@2] callbackId:self.currentWallet.walletID className:@"Wallet" methodName:@"getBalance"];
        PluginResult * result =[[ELWalletManager share]getBalance:mommand];
        
        NSString *status=[NSString stringWithFormat:@"%@",result.status];
        if ([status isEqualToString:@"1"]){
            sideChainInfoModel *smodel=
            
            [[HMWFMDBManager sharedManagerType:sideChain] selectAddsideChainWithWalletID:self.currentWallet.masterWalletID andWithIconName:currencyName];
            NSString *blanceString=[NSString stringWithFormat:@"%@",result.message[@"success"]];
            
            assetsListModel *model=[[assetsListModel alloc]init];
            model.iconName=currencyName;
            model.thePercentageCurr=0.f;
            model.thePercentageMax=1.f;
            model.iconBlance=blanceString;
            if ([smodel.sideChainNameTime isEqual: [NSNull null]]||smodel.sideChainNameTime==NULL) {
                model.updateTime=[NSString stringWithFormat:@"%@:  %@",NSLocalizedString(@"已同步区块时间", nil),@"--:--"];
            }else{
                 model.updateTime=[NSString stringWithFormat:@"%@:  %@",NSLocalizedString(@"已同步区块时间", nil),smodel.sideChainNameTime];
            }
            
            [self.dataSoureArray addObject:model];
            
            
            
            invokedUrlCommand *mommand=[[invokedUrlCommand alloc]initWithArguments:@[self.currentWallet.masterWalletID,currencyName] callbackId:self.currentWallet.walletID className:@"Wallet" methodName:[NSString stringWithFormat:@"%d",index]];
            
            [[ELWalletManager share]registerWalletListener:mommand];
            
            
            
            index++;
            
            
        }
    }
    [self.table reloadData];
    [self.table.mj_header endRefreshing];
    
}
-(void)setView{
    self.table = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
//    self.table.separatorInset=UIEdgeInsetsMake(0, 10, 0, 10);
    [self.view addSubview:self.table];
    self.table.backgroundColor = [UIColor clearColor];
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.table registerNib:[UINib nibWithNibName:@"FLAssetTableCell" bundle:nil] forCellReuseIdentifier:@"FLAssetTableCell"];
    
    self.table.dataSource =self;
    self.table.delegate = self;
    self.table.rowHeight = 100;
    HMWaddFooterView *addFooterView=[[HMWaddFooterView alloc]init];
    addFooterView.delegate=self;
    
    self.table.tableFooterView =addFooterView;
//    
//    self.table.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//        [self  loadTheWalletInformationWithIndex: self.currentWalletIndex];
//    }];
    
   
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"asset_wallet_setting"] style:UIBarButtonItemStyleDone target:self action:@selector(ClickMore:)];
    
  
}
-(void)addCurrency:(UIButton*)btn{
    FLAllAssetListVC  *vc =[[FLAllAssetListVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)netWorkData{
    if (!self.currentWallet.walletAddress) {
        [self.table.mj_header endRefreshing];
        return;
    }

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self defultWhite];
     self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"aaset_wallet_list"] style:UIBarButtonItemStyleDone target:self action:@selector(swichWallet)];

   
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
}

-(void)swichWallet{
    HMWTheWalletListViewController *theWalletListVC=[[HMWTheWalletListViewController alloc]init];
    theWalletListVC.delegate=self;
    theWalletListVC.walletIDListArray=self.walletIDListArray;
    theWalletListVC.currentWalletIndex=self.currentWalletIndex;
    [self.navigationController pushViewController:theWalletListVC animated:YES];

}
- (void)ClickMore:(UIButton*)sender {
    HMWTheWalletManagementViewController *theWalletManagementVC=[[HMWTheWalletManagementViewController alloc]init];
    theWalletManagementVC.currentWallet=self.currentWallet;
    [self.navigationController pushViewController:theWalletManagementVC animated:YES];
    

    
}

-(void)capitalViewDidClick:(NSInteger)index
{
  
    switch (index) {
        case 11:
        case 1:
            {
                FLQRVC *vc = [[FLQRVC alloc]init];
//                vc.addr = self.currentWallet.walletAddress;
//                vc.Wallet = self.currentWallet;
                [self.navigationController pushViewController:vc animated:YES];
            }
            break;
        case 3:{
//            FLWalletDeleteVC *vc= [[FLWalletDeleteVC alloc]init];
//            vc.currentWallet = self.currentWallet;
//            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
            {
//                FLAllAssetListVC *vc = [[FLAllAssetListVC alloc]init];
//                vc.addr = self.currentWallet.walletAddress;
//                [self.navigationController pushViewController:vc animated:YES];
            }
            break;
            case 10:
        {
           // [self jumpToSelectTradeBiVC:nil];
        }
            break;
        case 12:
        {
//            FLBuyAndSellVC *vc = [[FLBuyAndSellVC alloc]init];
//            [self.navigationController pushViewController:vc animated:YES];
            [[FLTools share]showErrorInfo:@"敬请期待"];
        }
            break;
        default:
            break;
    }
}
//-(void)jumpToSelectTradeBiVC:(NSString*)addr{
//    FLSelectTradeBiVC *vc = [[FLSelectTradeBiVC alloc]init];
//    vc.dataSource = self.dataSource;
//    vc.toAddress = addr;
//    vc.currentWallet=self.currentWallet;
//    [self.navigationController pushViewController:vc animated:YES];
//
//}
//刷新通知
//-(void)walletRefresh:(NSNotification*)message
//{
//    switch ([message.object integerValue]) {
//        case 1://跟新
//            {
////                [self setWallet];
//                [self netWorkData];
//
//            }
//            break;
//        case 2://换
//            {
//                self.currentWallet = nil;
////                [self setWallet];
//            }
//            break;
//        default:
//            break;
//    }
//}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FLAssetTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FLAssetTableCell"];
    
    
    assetsListModel *model=self.dataSoureArray[indexPath.row];
 cell.biName.text=model.iconName;
   cell.updatetime.text=model.updateTime;
    cell.detailLab.text=[[FLTools share]elaScaleConversionWith: model.iconBlance];
    cell.progress.progress=model.thePercentageCurr/model.thePercentageMax;
    NSString * symbolString=@"%";
    if (cell.progress.progress==1&&model.thePercentageCurr!=model.thePercentageMax) {
         cell.progressLab.text=[NSString stringWithFormat:@"%.f%@",0.99*100,symbolString];
    }else{
         cell.progressLab.text=[NSString stringWithFormat:@"%.f%@",cell.progress.progress*100,symbolString];
    }
   
    
    
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSoureArray.count;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HMWAssetDetailsViewController *vc = [[ HMWAssetDetailsViewController alloc]init];
      assetsListModel *model=self.dataSoureArray[indexPath.row];
    vc.title=model.iconName;
    vc.currentWallet  = self.currentWallet;
    vc.elaModel=self.dataSoureArray.firstObject;
    vc.model=model;
    vc.supportOfTheCurrencyArray=self.dataSoureArray;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark param
-(FLPrepareVC *)prepare
{
    if (!_prepare) {
        _prepare = [[FLPrepareVC alloc]init];
    }
    return _prepare;
}
-(NSMutableDictionary *)tokenAddresses
{
    if (!_tokenAddresses) {
        _tokenAddresses = [NSMutableDictionary dictionary];
    }
    return _tokenAddresses;
}
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
#pragma mark ---------HMWaddFooterViewDelegate----------
-(void)addTheAssetEvent{
    
    HMWAddTheCurrencyListViewController *AddTheCurrencyListVC=[[HMWAddTheCurrencyListViewController alloc]init];
    AddTheCurrencyListVC.wallet=self.currentWallet;
    AddTheCurrencyListVC.openedTheSubstringArrayList=self.dataSoureArray;
    [self.navigationController pushViewController:AddTheCurrencyListVC animated:YES];
    
}
-(void)needUpdateInfo:(FLWallet *)wallet withSelectIndex:(NSInteger)index{
    self.currentWallet=wallet;
    [self loadTheWalletInformationWithIndex:index];
}
- (void)sendPluginResult:(PluginResult*)result callbackId:(NSString*)callbackId{
    
    
    
    
}
@end
