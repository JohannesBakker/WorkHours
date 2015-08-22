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

@end
