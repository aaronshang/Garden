//
//  BaiCityListViewController.h
//  walktour
//
//  Created by kai.shang on 15/11/18.
//
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>

@protocol PassCityIDDelegate <NSObject>
@optional
-(void) PassCityID:(NSInteger) cityID;
@end

@interface  CityRecord: NSObject

@end


@interface BaiCityListView : UIView
@property(nonatomic, assign) id<PassCityIDDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame withOfflineMap:(BMKOfflineMap*)mapServrice;

@end
