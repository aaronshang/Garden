//
//  BaiCityListViewController.m
//  walktour
//
//  Created by kai.shang on 15/11/18.
//
//

#import "BaiCityListViewController.h"
#import "DLShare.h"

#define DLMAP_RECORD @"DLMAP_RECORD"
#define DLMAP_SUBCITY @"DLMAP_SUBCITY"

@interface CityRecord()
@property(nonatomic, strong) BMKOLSearchRecord *record;
@property(nonatomic, assign) BOOL expanded;
@end

@implementation CityRecord

@end


@interface BaiCityListView()<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) NSArray *mCityAry;
@property(nonatomic, strong) NSMutableArray *mDataSourceMAry;
@property(nonatomic, strong) UITableView *mCityTableView;
@property(nonatomic, assign) NSInteger mCurrentExpendIndex;
@end


@implementation BaiCityListView

- (instancetype)initWithFrame:(CGRect)frame withOfflineMap:(BMKOfflineMap*)mapServrice{

    self = [super initWithFrame:frame];
    if (self) {
        
        NSArray *_list = [mapServrice getOfflineCityList];
        self.mCityAry = [NSArray arrayWithArray:_list];
        self.mDataSourceMAry = [NSMutableArray array];
        for(BMKOLSearchRecord *record in self.mCityAry){
            CityRecord *city = [[CityRecord alloc] init];
            city.record = record;
            city.expanded = NO;
            [self.mDataSourceMAry addObject:city];
        }
        
        self.mCityTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        self.mCityTableView.delegate = self;
        self.mCityTableView.dataSource = self;
        [self addSubview:self.mCityTableView];
        self.mCurrentExpendIndex=-1;
    }
    
    return self;
}

#pragma mark-
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   
    NSInteger rvt = [self getRowsInSection];
    return rvt;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CITYLISTCELLIDENTIER = @"CITYLISTCELLIDENTIER";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CITYLISTCELLIDENTIER];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CITYLISTCELLIDENTIER];
    }
    
    NSDictionary *dic = [self searchRecordWithRow:indexPath.row];
    BMKOLSearchRecord *record = [dic objectForKey:DLMAP_RECORD];
    BOOL subCity = [[dic objectForKey:DLMAP_SUBCITY] boolValue];
    cell.textLabel.text = record.cityName;
    cell.backgroundColor = [UIColor whiteColor];
    
    if (record.cityType==0 || record.cityType==2 || record.cityType==3) {//全国基础、城市
        cell.detailTextLabel.text = [DLShare getDataSizeString:record.size];
        
        if (subCity) {
            cell.backgroundColor = [UIColor colorWithRed:(242/255.0) green:(242/255.0) blue:(242/255.0) alpha:1];
        }
    }else if(record.cityType==1) {
        
        if(self.mCurrentExpendIndex==indexPath.row){
             cell.detailTextLabel.text = @"△";
        }else{
            cell.detailTextLabel.text = @"▽";
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BMKOLSearchRecord *currentRecord = [[self searchRecordWithRow:indexPath.row] objectForKey:DLMAP_RECORD];
    
    if (currentRecord.cityType==0 || currentRecord.cityType==2 || currentRecord.cityType==3) {
        //城市、全国
        
        if (currentRecord.cityType==3) {
            NSLog(@"全省,%@", currentRecord.cityName);
            
            for (CityRecord *oriRecord in self.mDataSourceMAry) {
                
                if (oriRecord.record.cityID==currentRecord.cityID) {
                    
                    for (BMKOLSearchRecord *sub in oriRecord.record.childCities) {
                        
                        if (sub.cityType==2) {
                            [DLShare writeCityRecord:sub];
                        }
                        
                    }
                    break;
                }
            }
        }else{
            [DLShare writeCityRecord:currentRecord];
        }
        
        
        if (self.delegate) {
            [self.delegate PassCityID:currentRecord.cityID];
        }
        
        NSString *titleName = @"您选中的城市已经进入下载序列";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message: titleName delegate:nil cancelButtonTitle:(@"OK") otherButtonTitles:nil, nil];
        
        [alertView show];
    }else if(currentRecord.cityType==1){
        //省份展开或收缩
        CityRecord *city = [self findCityRecordWithCityID:currentRecord.cityID];
       
        if(city.expanded){
            [self foldAllExpandRow];
            self.mCurrentExpendIndex=-1;
            [tableView reloadData];
        }else{
            [self foldAllExpandRow];
            self.mCurrentExpendIndex=indexPath.row;
            city.expanded = YES;
            [tableView reloadData];
            NSInteger topNumRow = [self.mDataSourceMAry indexOfObject:city];
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:topNumRow inSection:0]  atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}

//收缩所有Row
- (void) foldAllExpandRow{
    for (CityRecord *record in self.mDataSourceMAry) {
        record.expanded=NO;
    }
}

- (CityRecord*) findCityRecordWithCityID:(NSInteger) cityID{

    for (CityRecord *record in self.mDataSourceMAry) {
        if (cityID == record.record.cityID) {
            return record;
        }
    }
    return nil;
}

- (NSDictionary*) searchRecordWithRow:(NSInteger) row{
    
    NSInteger num = -1;
    for (CityRecord *city in self.mDataSourceMAry) {
        num++;
        if (num==row) {
            return @{DLMAP_RECORD:city.record, DLMAP_SUBCITY:@NO};
        }
        if (city.expanded==YES) {
            
            for (BMKOLSearchRecord *record in city.record.childCities) {
                num++;
                if (num == row) {
                    return @{DLMAP_RECORD:record, DLMAP_SUBCITY:@YES};
                }
            }
        }
    }
    return nil;
}

- (NSInteger) getRowsInSection{
    NSInteger rvt = 0;
    for (CityRecord *city in self.mDataSourceMAry) {
        rvt++;
        if (city.expanded) {
            rvt+=city.record.childCities.count;
        }
    }
    return rvt;
}


@end
