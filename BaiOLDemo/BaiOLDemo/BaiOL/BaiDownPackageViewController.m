//
//  BaiDownPackageViewController.m
//  walktour
//
//  Created by kai.shang on 15/11/18.
//
//

#import "BaiDownPackageViewController.h"
#import "DLShare.h"

@implementation DownPackageState

-(id) init{
    self = [super init];
    if (self) {
        self.cityIdDownloading=-1;
        self.downloading = NO;
    }
    return self;
}

@end

@implementation CityActionSheet

@end


@interface BaiDownPackageView()<UITableViewDataSource, UITableViewDelegate, BMKOfflineMapDelegate, UIActionSheetDelegate>

@property(nonatomic, strong) UITableView *mPackageTableView;
@property(nonatomic, strong) NSMutableArray *mPackageSourceMAry;
@property(nonatomic, strong) BMKOfflineMap *mOfflineMap; //离线服务，需开启地图模式
@property(nonatomic, strong) DownPackageState *mDownState;

-(void) getDataSource;
@end

@implementation BaiDownPackageView

- (instancetype)initWithFrame:(CGRect)frame withOfflineMapService:(BMKOfflineMap*) offlineMap{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.mPackageSourceMAry = [NSMutableArray array];
        self.mOfflineMap = offlineMap;
        self.mOfflineMap.delegate = self;
    
        [self getDataSource];
        
        self.mPackageTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        self.mPackageTableView.delegate = self;
        self.mPackageTableView.dataSource = self;
        [self addSubview:self.mPackageTableView];
        
        self.mDownState = [[DownPackageState alloc] init];
    }
    
    return self;
}

-(void) flushView{
    [self getDataSource];
    [self.mPackageTableView reloadData];
}

-(void) getDataSource{
    
    [self.mPackageSourceMAry removeAllObjects];
    NSArray *allSelectedCityIDAry = [DLShare getAllCityID];
    for (BMKOLSearchRecord *record in allSelectedCityIDAry) {
        
        BMKOLUpdateElement *element = [BMKOLUpdateElement alloc];
        element.cityName = record.cityName;
        element.size = record.size;
        element.cityID = record.cityID;
        element.ratio = 0;
        
        BMKOLUpdateElement *netInfo = [self.mOfflineMap getUpdateInfo:record.cityID];
        if (netInfo) {
            element.ratio=netInfo.ratio;
            element.update=netInfo.update;
            element.status=netInfo.status;
        }
        
        [self.mPackageSourceMAry addObject:element];
    }
}

- (void)onGetOfflineMapState:(int)type withState:(int)state{

    NSLog(@"type %d, state %d", type, state);
    
    if (type == TYPE_OFFLINE_UPDATE) {
        //id为state的城市正在下载或更新，start后会毁掉此类型
        BMKOLUpdateElement* updateInfo;
        updateInfo = [self.mOfflineMap getUpdateInfo:state];
        NSLog(@"城市名：%@,下载比例:%d,Status:%d",updateInfo.cityName,updateInfo.ratio,updateInfo.status);
        [self showProcessWithCityID:updateInfo.cityID withProgress:updateInfo.ratio];
        
        if (updateInfo.status>=2 && updateInfo.status<=9) {
            self.mDownState.downloading = NO;
        }else if(updateInfo.status==1){
            self.mDownState.downloading = YES;
            self.mDownState.cityIdDownloading=updateInfo.cityID;
        }
        
    }
    if (type == TYPE_OFFLINE_NEWVER) {
        //id为state的state城市有新版本,可调用update接口进行更新
        BMKOLUpdateElement* updateInfo;
        updateInfo = [self.mOfflineMap getUpdateInfo:state];
        NSLog(@"是否有更新%d",updateInfo.update);
    }
    if (type == TYPE_OFFLINE_UNZIP) {
        //正在解压第state个离线包，导入时会回调此类型
    }
    if (type == TYPE_OFFLINE_ZIPCNT) {
        //检测到state个离线包，开始导入时会回调此类型
        NSLog(@"检测到%d个离线包",state);
        if(state==0)
        {
            
        }
    }
    if (type == TYPE_OFFLINE_ERRZIP) {
        //有state个错误包，导入完成后会回调此类型
        NSLog(@"有%d个离线包导入错误",state);
    }
    if (type == TYPE_OFFLINE_UNZIPFINISH) {
        NSLog(@"成功导入%d个离线包",state);
        //导入成功state个离线包，导入成功后会回调此类型
    }
}

#pragma mark-

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  [self.mPackageSourceMAry count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *PACKAGECELLID = @"PACKAGECELLID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PACKAGECELLID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:PACKAGECELLID];
    }
    
    BMKOLUpdateElement *element = [self.mPackageSourceMAry objectAtIndex:indexPath.row];
    cell.textLabel.text = element.cityName;
    
    NSMutableString *deatilContent = [[NSMutableString alloc] init];
    
    if (element.status==2) {
        [deatilContent appendString:(@"等待下载")];
        [deatilContent appendString:@" "];
    }else if(element.status==3){
        [deatilContent appendString:(@"已暂停")];
        [deatilContent appendString:@" "];
    }
    
    if (element.update) {
        [deatilContent appendString:(@"有更新")];
    }
    [deatilContent appendString:@" "];
    if(element.ratio==100){
        [deatilContent appendString:(@"完成")];
    }else{
        [deatilContent appendString:[NSString stringWithFormat:@"%d%%", element.ratio]];
    }
    
    cell.detailTextLabel.text = deatilContent;
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:12]];
    [cell.detailTextLabel setTextColor:[UIColor colorWithRed:(0) green:(120/255.0) blue:(230/255.0) alpha:1]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    BMKOLUpdateElement *element = [self.mPackageSourceMAry objectAtIndex:indexPath.row];
    
    CityActionSheet *_actionSheet;
    
    if (self.mDownState.downloading==NO) {
        //未下载时，cell均可下载、删除离线包;若有更新，可更新；
        
        NSString *title;
        if (element.update) {
            title = (@"开始更新");
        }else{
            title = (@"开始下载");
        }
        
        if (element.ratio==100 && element.update==NO){
            _actionSheet = [[CityActionSheet alloc] initWithTitle:nil delegate:self
                                                cancelButtonTitle:(@"取消")
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:(@"删除"), nil];
        }else{
            _actionSheet = [[CityActionSheet alloc] initWithTitle:nil delegate:self
                                                cancelButtonTitle:(@"取消")
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:title, (@"删除"), nil];
        }
        _actionSheet.update=element.update;
        _actionSheet.radio=element.ratio;
        _actionSheet.tag=0;
    }else{
        //下载中，当前离线包可停止，不可以删除
        if (self.mDownState.cityIdDownloading==element.cityID) {
            _actionSheet = [[CityActionSheet alloc] initWithTitle:nil delegate:self
                                                cancelButtonTitle:(@"Cancel")
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:(@"StopDownload"), nil];
            _actionSheet.tag=1;
        }
        //下载中，非当前下载中的离线包可删除
        else{
            _actionSheet = [[CityActionSheet alloc] initWithTitle:nil delegate:self
                                                cancelButtonTitle:(@"Cancel")
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:(@"Delete"), nil];
            _actionSheet.tag=2;
        }
    }
    
    [_actionSheet showInView:self];
    _actionSheet.delegate=self;
    _actionSheet.row = indexPath.row;
    _actionSheet.cityID = element.cityID;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{

    CityActionSheet *citySheet = (CityActionSheet*) actionSheet;
    
    switch (citySheet.tag) {
        case 0:
        {
            if (citySheet.radio==100 && citySheet.update==NO) {
                if (buttonIndex==0) {
                    [self deleOLPackageWithCityID:citySheet.cityID withRow:citySheet.row];
                }
            }else{
                if (buttonIndex==0) {//开始下载 or 更新
                    if(citySheet.update){
                        [self.mOfflineMap update:citySheet.cityID];
                    }else{
                        [self.mOfflineMap start:citySheet.cityID];
                    }
                    self.mDownState.downloading = YES;
                }else if(buttonIndex==1){
                    [self deleOLPackageWithCityID:citySheet.cityID withRow:citySheet.row];
                }

            }
            
        }
            break;
        case 1:
        {
            if (buttonIndex==0) {//停止下载
                [self.mOfflineMap pause:citySheet.cityID];
            }
        }
            break;
        case 2:
        {
            if (buttonIndex==0) {//删除
                [self deleOLPackageWithCityID:citySheet.cityID withRow:citySheet.row];
            }
        }
            break;
        default:
            break;
    }
}

- (void) deleOLPackageWithCityID:(NSInteger) cityID withRow:(NSInteger) row{
    
    [DLShare deleteCityID:cityID];
    [self getDataSource];
    [self.mPackageTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    if(![self.mOfflineMap remove:cityID]){
        NSLog(@"Delete City Record(%d) Failure", cityID);
    }
}

#pragma mark-

- (void) showProcessWithCityID:(NSInteger) cityID withProgress:(NSInteger) radio{

    int row = -1;
    for (BMKOLUpdateElement *element in self.mPackageSourceMAry) {
        row++;
        if (element.cityID==cityID) {
            element.ratio=radio;
            break;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mPackageTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    });
}


#pragma mark

-(void) startDownCityID:(NSInteger) cityID{

    if (self.mOfflineMap) {
        [self.mOfflineMap start:cityID];
        self.mDownState.downloading = YES;
    }
}

@end
