//
//  DLShare.m
//

#import "DLShare.h"

@implementation DLShare


+(instancetype) Instance{
    
    static DLShare *gShare = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        gShare = [[DLShare alloc] init];
    });
    
    return gShare;
}
+ (NSString *)getDataSizeString:(int) nSize
{
    NSString *string = nil;
    if (nSize<1024)
    {
        string = [NSString stringWithFormat:@"%dB", nSize];
    }
    else if (nSize<1048576)
    {
        string = [NSString stringWithFormat:@"%dK", (nSize/1024)];
    }
    else if (nSize<1073741824)
    {
        if ((nSize%1048576)== 0 )
        {
            string = [NSString stringWithFormat:@"%dM", nSize/1048576];
        }
        else
        {
            int decimal = 0; //小数
            NSString* decimalStr = nil;
            decimal = (nSize%1048576);
            decimal /= 1024;
            
            if (decimal < 10)
            {
                decimalStr = [NSString stringWithFormat:@"%d", 0];
            }
            else if (decimal >= 10 && decimal < 100)
            {
                int i = decimal / 10;
                if (i >= 5)
                {
                    decimalStr = [NSString stringWithFormat:@"%d", 1];
                }
                else
                {
                    decimalStr = [NSString stringWithFormat:@"%d", 0];
                }
                
            }
            else if (decimal >= 100 && decimal < 1024)
            {
                int i = decimal / 100;
                if (i >= 5)
                {
                    decimal = i + 1;
                    
                    if (decimal >= 10)
                    {
                        decimal = 9;
                    }
                    
                    decimalStr = [NSString stringWithFormat:@"%d", decimal];
                }
                else
                {
                    decimalStr = [NSString stringWithFormat:@"%d", i];
                }
            }
            
            if (decimalStr == nil || [decimalStr isEqualToString:@""])
            {
                string = [NSString stringWithFormat:@"%dMss", nSize/1048576];
            }
            else
            {
                string = [NSString stringWithFormat:@"%d.%@M", nSize/1048576, decimalStr];
            }
        }
    }
    else	// >1G
    {
        string = [NSString stringWithFormat:@"%dG", nSize/1073741824];
    }
    
    return string;
}

+ (void) writeCityRecord:(BMKOLSearchRecord*) record{
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSArray *array = [settings objectForKey:@"LocalCityRecordAry"];
    NSMutableArray *tmpAry = [[NSMutableArray alloc] initWithCapacity:10];
    for (NSDictionary* dic in array) {
        [tmpAry addObject:dic];
    }

    if([self hasUniqueCityID:record.cityID withAry:array]==NO){
        [tmpAry addObject:@{@"cityName":record.cityName,
                            @"size":[NSString stringWithFormat:@"%d", record.size],
                            @"cityID":[NSString stringWithFormat:@"%d", record.cityID]}];
    }
    
    
    [settings setObject:tmpAry forKey:@"LocalCityRecordAry"];
    [settings synchronize];
}

+(BOOL) hasUniqueCityID:(NSInteger) cityID withAry:(NSArray*) array{
    
    BOOL rvt = NO;
    for (NSDictionary *dic in array) {
        NSString *cityIDStr = [dic objectForKey:@"cityID"];
        if (cityID == [cityIDStr integerValue]) {
            rvt = YES;
            break;
        }
    }
    return rvt;
}

+ (NSArray*) getAllCityID{
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSArray *array = [settings objectForKey:@"LocalCityRecordAry"];
    
    NSMutableArray *rvtMary = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        BMKOLSearchRecord *record = [[BMKOLSearchRecord alloc] init];
        record.cityName = [dic objectForKey:@"cityName"];
        record.size = [[dic objectForKey:@"cityName"] integerValue];
        record.cityID = [[dic objectForKey:@"cityID"] integerValue];
        [rvtMary addObject:record];
    }
    return rvtMary;
}

+ (void) deleteCityID:(NSInteger) cityID{
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSArray *array = [settings objectForKey:@"LocalCityRecordAry"];
    NSMutableArray *tmpAry = [[NSMutableArray alloc] initWithCapacity:10];
    for (NSDictionary* dic in array) {
        
        NSInteger tmpCityID = [[dic objectForKey:@"cityID"] integerValue];
        if (tmpCityID!=cityID) {
            [tmpAry addObject:dic];
        }
    }
    
    [settings setObject:tmpAry forKey:@"LocalCityRecordAry"];
    [settings synchronize];
}



@end

