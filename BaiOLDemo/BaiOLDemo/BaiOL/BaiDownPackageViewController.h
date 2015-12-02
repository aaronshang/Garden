//
//  BaiDownPackageViewController.h
//  walktour
//
//  Created by kai.shang on 15/11/18.
//
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>

/*
 离线包下载管理状态
 */
@interface DownPackageState : NSObject
@property(nonatomic, assign) BOOL downloading; //是否在下载中
@property(nonatomic, assign) NSInteger cityIdDownloading; //正在下载的城市ID
@end


@interface CityActionSheet : UIActionSheet
@property(nonatomic, assign) NSInteger cityID;
@property(nonatomic, assign) NSInteger row;
@property(nonatomic, assign) BOOL update;
@property(nonatomic, assign) NSInteger radio;
@end


@interface BaiDownPackageView : UIView
- (instancetype)initWithFrame:(CGRect)frame withOfflineMapService:(BMKOfflineMap*) offlineMap;

-(void) flushView;

-(void) startDownCityID:(NSInteger) cityID;
@end
