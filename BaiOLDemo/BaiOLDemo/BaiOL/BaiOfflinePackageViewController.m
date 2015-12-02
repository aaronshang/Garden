//
//  BaiOfflinePackageViewController.m
//  walktour
//
//  Created by kai.shang on 15/11/18.
//
//

#import "BaiOfflinePackageViewController.h"
#import "BaiDownPackageViewController.h"
#import "BaiCityListViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface BaiOfflinePackageViewController()<PassCityIDDelegate, BMKGeneralDelegate>

@property(nonatomic, strong) UISegmentedControl *mSegment;
@property(nonatomic, strong) BaiDownPackageView *mPackageView;
@property(nonatomic, strong) BaiCityListView  *mCityListView;
@property(nonatomic, strong) BMKOfflineMap *mOfflineMapService;
@end

@implementation BaiOfflinePackageViewController

- (void)viewDidLoad{

    [super viewDidLoad];
    
    BMKMapManager *_mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [_mapManager start:@"Di3C6VGl5E8I3BifaLzvyf14"  generalDelegate: self];
    if (!ret) {
        NSLog(@"baidu map manager start failed!");
    }
    
    BMKMapView *map = [[BMKMapView alloc] init];
    
    self.mOfflineMapService = [[BMKOfflineMap alloc] init];
    
    self.mPackageView = [[BaiDownPackageView alloc] initWithFrame:self.mContainerView.bounds withOfflineMapService:self.mOfflineMapService];
    self.mCityListView = [[BaiCityListView alloc] initWithFrame:self.mContainerView.bounds withOfflineMap:self.mOfflineMapService];
    self.mCityListView.delegate=self;

    [self.mContainerView addSubview: self.mPackageView];
    [self.mContainerView  addSubview: self.mCityListView];
    
}

- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        NSLog(@"联网成功");
    }
    else{
        NSLog(@"onGetNetworkState %d",iError);
    }
    
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        NSLog(@"授权成功");
    }
    else {
        NSLog(@"onGetPermissionState %d",iError);
    }
}


- (void)viewDidUnload{
    
    self.mOfflineMapService = nil;
    self.mPackageView = nil;
    self.mCityListView = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
}

-(void)backBarButtonItemClicked{
    
//    [DLKit popViewControllerAnimated:YES];
}

-(void) segmentChanged:(id) sender{

    UISegmentedControl *control = (UISegmentedControl*)sender;
    if (control.selectedSegmentIndex==0) {
        [self.mContainerView bringSubviewToFront:self.mPackageView];
        [self.mPackageView flushView];
    }else if(control.selectedSegmentIndex==1){
        [self.mContainerView bringSubviewToFront:self.mCityListView];
    }
}


#pragma mark

-(void) PassCityID:(NSInteger) cityID{
    [self.mPackageView startDownCityID:cityID];
}

@end
