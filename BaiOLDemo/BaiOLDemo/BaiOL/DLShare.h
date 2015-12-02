//
//  DLShare.h
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface DLShare : NSObject{

}

@property(nonatomic, assign) BOOL outMapIsShowing;

+(instancetype) Instance;

+ (BOOL)checkRange:(NSString *)rangeString withNumberString:(NSString *)numberString;

+(BOOL) hasUniqueCityID:(NSInteger) cityID withAry:(NSArray*) array;

+ (NSString *)getDataSizeString:(int) nSize;

+ (void) writeCityRecord:(BMKOLSearchRecord*) record;

+ (void) deleteCityID:(NSInteger) cityID;

+ (NSArray*) getAllCityID;

@end
