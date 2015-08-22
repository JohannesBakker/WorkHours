//
//  UserContext.m
//  WorkHours
//
//  Created by Admin on 7/3/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "UserContext.h"
#import "NSDate+Utilities.h"

@interface UserContext() {
    
    
}

@end

@implementation UserContext

@synthesize arrLabourType;
@synthesize arrTimesheetByDate;
@synthesize arrTodayTimesheets;
@synthesize arrUserPins;


+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^
                  {
                      sharedInstance = [self new];
                  });
    
    return sharedInstance;
}




- (void)initLabourTypeArray:(NSMutableArray *)arrType
{
    if (arrType == nil) {
        arrLabourType = [NSMutableArray array];
    }
    else {
        arrLabourType = [[NSMutableArray alloc] initWithArray:arrType];
    }
}

- (void)initTimesheetByDateArray:(NSMutableArray *)arrTimesheetPerDay
{
    if (arrTimesheetPerDay == nil) {
        arrTimesheetByDate = [NSMutableArray array];
    }
    else {
        arrTimesheetByDate = [[NSMutableArray alloc] initWithArray:arrTimesheetPerDay];
    }
}

- (void)initTodayTimesheets:(NSMutableArray *)arrTimeSheets
{
    if (arrTimeSheets == nil) {
        arrTodayTimesheets = [NSMutableArray array];
    }
    else {
        arrTodayTimesheets = [[NSMutableArray alloc] initWithArray:arrTimeSheets];
    }
}


- (void)initUserPinArray:(NSMutableArray *)arrPins
{
    if (arrPins == nil) {
        arrUserPins = [NSMutableArray array];
    }
    else {
        arrUserPins = [[NSMutableArray alloc] initWithArray:arrPins];
    }
}

- (void)addTimesheet:(TimeSheet *)oneSheet
{
    if (oneSheet == nil || oneSheet.startTime == nil)
        return;
    
    for (TimeSheetPerDay *daySheets in arrTimesheetByDate)
    {
        if ([daySheets isValidTimesheetAdding:oneSheet]) {
            [daySheets addNewTimesheet:oneSheet];
            return;
        }        
    }
    
    TimeSheetPerDay *newDaySheets = [[TimeSheetPerDay alloc] init];
    
    newDaySheets.dayDate = [[NSDate alloc] initWithTimeInterval:0 sinceDate:oneSheet.startTime];
    newDaySheets.arrTimesheets = [NSMutableArray array];
    [newDaySheets.arrTimesheets addObject:oneSheet];
    
    [arrTimesheetByDate addObject:newDaySheets];
}


- (void)addDayTimesheets:(TimeSheetPerDay *)dayTimesheets
{
    if (dayTimesheets == nil || dayTimesheets.dayDate == nil)
        return;
    
    NSDate *newDay = dayTimesheets.dayDate;
    
    for (NSUInteger i = 0; i < arrTimesheetByDate.count; i++) {
        
        TimeSheetPerDay *daySheets = [arrTimesheetByDate objectAtIndex:i];
        NSDate *selDay = daySheets.dayDate;
        
        if ([selDay isEqualToDateIgnoringTime:newDay]) {
            [arrTimesheetByDate insertObject:dayTimesheets atIndex:i];
            [arrTimesheetByDate removeObjectAtIndex:i+1];
            
            return;
        }
        else if ( [selDay isEarlierThanDate:newDay] ) {
            [arrTimesheetByDate insertObject:dayTimesheets atIndex:i];
            return;
        }
    }
    
    [arrTimesheetByDate addObject:dayTimesheets];
}

- (NSMutableArray*)getDayTimesheets:(NSDate *)date
{
    if (arrTimesheetByDate == nil)
        return nil;
    
    for (NSUInteger i = 0; i < arrTimesheetByDate.count; i++) {
        
        TimeSheetPerDay *daySheets = [arrTimesheetByDate objectAtIndex:i];
        
        if (daySheets != nil && [date isEqualToDateIgnoringTime:daySheets.dayDate])
            return daySheets.arrTimesheets;
    }
    
    return nil;
}

- (TimeSheet *)getCoveredTimesheet:(NSDate *)pinCreateTime
{
    if (pinCreateTime == nil  || arrTodayTimesheets == nil)
        return nil;
    
    for (NSUInteger i = 0; i < arrTodayTimesheets.count; i++)
    {
        TimeSheet *sheet = [arrTodayTimesheets objectAtIndex:i];
        
        if ( ([pinCreateTime isEqualToDate:sheet.startTime] || [pinCreateTime isLaterThanDate:sheet.startTime])
            && ([pinCreateTime isEqualToDate:sheet.endTime] || [pinCreateTime isEarlierThanDate:sheet.endTime])  )
        {
            return sheet;
        }
    }
    
    return nil;
}



@end
