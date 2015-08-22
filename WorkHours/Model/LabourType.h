//
//  LabourType.h
//  WorkHours
//
//  Created by Admin on 7/20/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kLabourTypeId_Labour         1
#define kLabourTypeId_Travel           2
#define kLabourTypeId_Holiday         3
#define kLabourTypeId_PHoliday      4
#define kLabourTypeId_Sick              5
#define kLabourTypeId_Training        6
#define kLabourTypeId_Admin          7
#define kLabourTypeId_Break          8
#define kLabourTypeId_LWP            9



@interface LabourType : NSObject

@property (nonatomic) int typeID;
@property (nonatomic, retain) NSString *typeName;

- (void)initWithParam:(int)typeId typename:(NSString *)typename;

@end
