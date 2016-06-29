#import "CityModel.h"

@implementation CityModel



-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.cityID forKey:@"cityID"];
    [aCoder encodeObject:self.cityName forKey:@"cityName"];
    [aCoder encodeObject:self.citylat forKey:@"citylat"];
    [aCoder encodeObject:self.citylng forKey:@"citylng"];
    [aCoder encodeObject:self.cityPinYin forKey:@"cityPinYin"];
}


-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        self.cityID     = [aDecoder decodeObjectForKey:@"cityID"];
        self.cityName   = [aDecoder decodeObjectForKey:@"cityName"];
        self.citylat    = [aDecoder decodeObjectForKey:@"citylat"];
        self.citylng    = [aDecoder decodeObjectForKey:@"citylng"];
        self.cityPinYin = [aDecoder decodeObjectForKey:@"cityPinYin"];
    }
    
    return self;
}


@end
