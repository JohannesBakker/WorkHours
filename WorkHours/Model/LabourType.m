//
//  LabourType.m
//  WorkHours
//
//  Created by Admin on 7/20/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "LabourType.h"

@implementation LabourType

@synthesize typeID, typeName;

- (void)initWithParam:(int)typeId typename:(NSString *)typename {
    typeID = typeId;
    typeName = [NSString stringWithFormat:@"%@", typename];
}

+ (NSString *)labourTypeName:(int)typeId {
    switch (typeId) {
        case kLabourTypeId_Labour:
            return @"Labour";
            break;
            
        case kLabourTypeId_Travel:
            return @"Travel";
            break;
            
        case kLabourTypeId_Holiday:
            return @"Holiday";
            break;
            
        case kLabourTypeId_PHoliday:
            return @"P.Holiday";
            break;
            
        case kLabourTypeId_Sick:
            return @"Sick";
            break;
            
        case kLabourTypeId_Training:
            return @"Training";
            break;
            
        case kLabourTypeId_Admin:
            return @"Admin";
            break;
            
        case kLabourTypeId_Break:
            return @"Break";
            break;
            
        case kLabourTypeId_LWP:
            return @"Lwp";
            break;
            
            
        default:
            break;
    }
    
    return @"";
}

@end
