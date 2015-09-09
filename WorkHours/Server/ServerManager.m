//
//  SeverManager.m
//  WalkItOff
//
//  Created by Donald Pae on 7/2/14.
//  Copyright (c) 2014 daniel. All rights reserved.
//

#import "ServerManager.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"
#import "AFNetworking.h"
#import "SBJson.h"
#import "ServiceErrorCodes.h"
#import "AppContext.h"
#import "NSDate+Utilities.h"


#import "Job.h"
#import "UserInfo.h"
#import "LabourType.h"
#import "TimeSheet.h"
#import "UserPin.h"

static ServerManager *_sharedServerManager = nil;

NSString * const WhereNowErrorDomain = @"com.wherenow";

#define kDescriptionNotReachable    @"Network error"
#define ErrorFromNotReachable   ([NSError errorWithDomain:WhereNowErrorDomain code:ServiceErrorNetwork userInfo:@{NSLocalizedDescriptionKey:kDescriptionNotReachable}])

@implementation ServerManager

+ (ServerManager *)sharedManager
{
    if (_sharedServerManager == nil)
        _sharedServerManager = [[ServerManager alloc] init];
    return _sharedServerManager;
}

- (BOOL)hasConnectivity
{
    // test reachability
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    Reachability *reachability = [Reachability reachabilityWithAddress:&zeroAddress];
    if (reachability != nil)
    {
        if ([reachability isReachable])
            return YES;
        return NO;
    }
    return NO;
}

- (void)callMethodName:(NSString *)methodName isGet:(BOOL)isGet params:(NSDictionary *)params completion:(void (^)(NSString *, NSDictionary *, NSError *))handler
{
    if (![self hasConnectivity])
    {
        NSLog(@"Request error, network error");
        handler(nil, nil, ErrorFromNotReachable);
        return;
    }
    
    NSURL  *url = nil;
    url = [NSURL URLWithString:API_URL];
    NSLog(@"requesting : %@%@\n%@", url, methodName, params);
    
	AFHTTPClient  *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    void (^successHandler)(AFHTTPRequestOperation *operation, id responseObject)  = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        if (responseObject == nil)
        {
            NSLog(@"Request error, responseObject = nil");
            handler(nil, nil, [NSError errorWithDomain:WhereNowErrorDomain code:ServiceErrorNoResponse userInfo:nil]);
        }
        else
        {
            NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            // remove <pre> tag if exists
            
            if (responseStr.length > 0)
            {
                if ([[responseStr substringToIndex:5] isEqualToString:@"<pre>"])
                    responseStr = [responseStr substringFromIndex:5];
                // remove prefix till to meet {
                NSRange range = [responseStr rangeOfString:@"{" options:0 range:NSMakeRange(0, responseStr.length)];
                NSRange range1 = [responseStr rangeOfString:@"[" options:0 range:NSMakeRange(0, responseStr.length)];
                
                NSRange range2;
                range2.length = 0;
                range2.location = NSNotFound;
                
                if (range.location != NSNotFound && range1.location != NSNotFound)
                {
                    if (range1.location < range.location)
                        range2 = range1;
                    else
                        range2 = range;
                }
                else if (range.location != NSNotFound)
                {
                    range2 = range;
                }
                else if (range1.location != NSNotFound)
                {
                    range2 = range1;
                }
                    
                if (range2.location != NSNotFound && range2.location > 0)
                {
                    responseStr = [responseStr substringFromIndex:range2.location];
                }
                
                NSDictionary *responseDic = [responseStr JSONValue];
                if (responseStr == nil)
                {
                    NSLog(@"Request successful, response string is nil");
                }
                else
                {
                    if (responseStr.length >= 3000)
                        NSLog(@"Request Successful, response '%@'", [responseStr substringToIndex:3000]);
                    else
                        NSLog(@"Request Successful, response '%@'", responseStr);
                }
                
                handler(responseStr, responseDic, nil);
            }
        }
        
    };
    
    void (^errorHandler)(AFHTTPRequestOperation *operation, NSError *error)  = ^ (AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        handler(nil, nil, error);
    };
    
    if (isGet)
    {
        [httpClient getPath:methodName parameters:params success:successHandler failure:errorHandler];
    }
    else
    {
        [httpClient postPath:methodName parameters:params success:successHandler failure:errorHandler];
    }
    
}

- (void)getMethod:(NSString *)methodName params:(NSDictionary *)params handler:(ServerManagerRequestHandlerBlock)handler
{
    [self callMethodName:methodName isGet:YES params:params completion:handler];
}

- (void)postMethod:(NSString *)methodName params:(NSDictionary *)params handler:(ServerManagerRequestHandlerBlock)handler
{
    [self callMethodName:methodName isGet:NO params:params completion:handler];
}


#pragma mark - User Login
- (void)loginUser:(NSString *)userName pwd:(NSString *)pwd success:(void (^)(NSString *sessionId, NSString *userId, NSString *fullname))success failure:(void (^)(NSString *))failure
{
    NSDictionary *params = @{@"uname": userName, @"upass": pwd};
    DEF_SERVERMANAGER
    NSString *methodName = [NSString stringWithFormat:@"%@%@.json", kAPIBaseUrlV2, kMethodForLoginV2];
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response, NSError *error){
        
        if (error != nil)
        {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil)
        {
            failure(@"Invalid response from server!");
            
            return;
        }
        else
        {
            NSString *status = [response objectForKey:@"status"];
            if ([status isEqualToString:@"failed"]) {
                failure([response objectForKey:@"ERROR"]);
            }
            else {
                NSDictionary *retVal = [response objectForKey:@"result"];
                NSString *userId = [retVal objectForKey:@"UID"];
                if (userId == nil || [userId isEqual:[NSNull null]])
                {
                    NSString *msg = [retVal objectForKey:@"ERROR"];
                    if (msg == nil)
                        msg = @"Unknown error";
                    failure(msg);
                }
                else
                {
                    NSString *sessionId = [retVal objectForKey:@"ID"];
                    NSString *fullname = [retVal objectForKey:@"NAME"];
                    if (sessionId == nil || [sessionId isEqual:[NSNull null]])
                        failure(@"Invalid response");
                    else
                    {
                        success(sessionId, userId, fullname);
                    }
                }
            }
        }
    }];
}


- (void)getJobsByLocation:(double)lat lon:(double)lon success:(void (^)(NSMutableArray *))sucess failure:(void (^)(NSString *))failure
{
    NSString *sessionId = [[AppContext sharedInstance] loadSession];
    NSDictionary *params = @{@"lat": [NSString stringWithFormat:@"%f", lat],
                             @"lon": [NSString stringWithFormat:@"%f", lon] };
    
    DEF_SERVERMANAGER
    NSString *methodName = [NSString stringWithFormat:@"%@%@/%@", kAPIBaseUrlV2, sessionId, kMethodForGetJobsByLocation];
    
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response,  NSError *error) {
        if (error != nil) {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil) {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"]) {
                failure(@"Invalid Parameters!");
            } else {
                failure(@"Invalid response");
            }
            
            return;
            
        } else {
            
            NSMutableArray *arrResponse = [response objectForKey:@"data"];
            NSMutableArray *arrResult = [NSMutableArray array];
            id valForObject;
            
            if (arrResponse) {
                
                if ([arrResponse isKindOfClass:[NSArray class]]) {
                    
                    for (NSDictionary *dictionary in arrResponse) {
                        
                        Job *oneJob = [[Job alloc] init];
                        
                        oneJob.jobID = [[dictionary objectForKey:@"job_id"] intValue];
                        oneJob.distance = [[dictionary objectForKey:@"distance"] doubleValue];
                        
                        valForObject = [dictionary objectForKey:@"company_name"] ;
                        if (valForObject == [NSNull null])
                            oneJob.companyName = @"";
                        else
                            oneJob.companyName = (NSString *)valForObject;
                        
                        valForObject = [dictionary objectForKey:@"notes"] ;
                        if (valForObject == [NSNull null])
                            oneJob.notes = @"";
                        else
                            oneJob.notes = (NSString *)valForObject;
                        
                        [arrResult addObject:oneJob];
                    } // end for
                    
                } else {
                    // no jobs
                }
                
                sucess(arrResult);
            }
            else {
                failure(@"Invalid response");
            }
        }
    }];
    
}


- (void)getUserList:(void (^)(NSMutableArray *))sucess failure:(void (^)(NSString *))failure
{
    NSString *sessionId = [[AppContext sharedInstance] loadSession];
    
    DEF_SERVERMANAGER
    NSString *methodName = [NSString stringWithFormat:@"%@%@/%@", kAPIBaseUrlV2, sessionId, kMethodForGetUserList];
    
    [manager postMethod:methodName params:nil handler:^(NSString *responseStr, NSDictionary *response,  NSError *error) {
        if (error != nil) {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil) {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"]) {
                failure(@"Invalid Parameters!");
            } else {
                failure(@"Invalid response");
            }
            
            return;
            
        } else {
            
            NSMutableArray *arrResponse = [response objectForKey:@"data"];
            NSMutableArray *arrResult = [NSMutableArray array];
            id valForObject;
            
            if (arrResponse) {
                
                if ([arrResponse isKindOfClass:[NSArray class]]) {
                    
                    for (NSDictionary *dictionary in arrResponse) {
                        
                        UserInfo *oneUser = [[UserInfo alloc] init];
                        
                        oneUser.userID = [[dictionary objectForKey:@"user_id"] intValue];
                        
                        valForObject = [dictionary objectForKey:@"first_name"] ;
                        if (valForObject == [NSNull null])
                            oneUser.firstName = @"";
                        else
                            oneUser.firstName = (NSString *)valForObject;
                        
                        valForObject = [dictionary objectForKey:@"last_name"] ;
                        if (valForObject == [NSNull null])
                            oneUser.lastName = @"";
                        else
                            oneUser.lastName = (NSString *)valForObject;
                        
                        [arrResult addObject:oneUser];
                    } // end for
                    
                } else {
                    // no jobs
                }
                
                sucess(arrResult);
            }
            else {
                failure(@"Invalid response");
            }
        }
    }];
    
}


- (void)getLabourType:(void (^)(NSMutableArray *))sucess failure:(void (^)(NSString *))failure
{
    NSString *sessionId = [[AppContext sharedInstance] loadSession];
    
    DEF_SERVERMANAGER
    NSString *methodName = [NSString stringWithFormat:@"%@%@/%@", kAPIBaseUrlV2, sessionId, kMethodForGetLabourType];
    
    [manager postMethod:methodName params:nil handler:^(NSString *responseStr, NSDictionary *response,  NSError *error) {
        if (error != nil) {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil) {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"]) {
                failure(@"Invalid Parameters!");
            } else {
                failure(@"Invalid response");
            }
            
            return;
            
        } else {
            
            NSMutableArray *arrResponse = [response objectForKey:@"data"];
            NSMutableArray *arrResult = [NSMutableArray array];
            id valForObject;
            
            if (arrResponse) {
                
                if ([arrResponse isKindOfClass:[NSArray class]]) {
                    
                    for (NSDictionary *dictionary in arrResponse) {
                        
                        LabourType *oneLabour = [[LabourType alloc] init];
                        
                        oneLabour.typeID = [[dictionary objectForKey:@"labour_type_id"] intValue];
                        
                        valForObject = [dictionary objectForKey:@"labour_type"] ;
                        if (valForObject == [NSNull null])
                            oneLabour.typeName = @"";
                        else
                            oneLabour.typeName = (NSString *)valForObject;
                        
                        [arrResult addObject:oneLabour];
                    } // end for
                    
                } else {
                    // no jobs
                }
                
                sucess(arrResult);
            }
            else {
                failure(@"Invalid response");
            }
        }
    }];
    
}

- (void)getTimesheetByDate:(int)userId selectedDate:(NSDate*)selectedDate success:(void (^)(NSMutableArray *))sucess failure:(void (^)(NSString *))failure
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDateFormatter *timesheetFormatter = [[NSDateFormatter alloc] init];
    [timesheetFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    
    NSString *sessionId = [[AppContext sharedInstance] loadSession];
    NSDictionary *params = @{@"user_id": [NSString stringWithFormat:@"%d", userId],
                             @"selected_date": [dateFormatter stringFromDate:selectedDate] };
    
    DEF_SERVERMANAGER
    NSString *methodName = [NSString stringWithFormat:@"%@%@/%@", kAPIBaseUrlV2, sessionId, kMethodForGetTimesheetByDate];
    
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response,  NSError *error) {
        if (error != nil) {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil) {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"]) {
                failure(@"Invalid Parameters!");
            } else {
                failure(@"Invalid response");
            }
            
            return;
            
        } else {
            
            NSMutableArray *arrResponse = [response objectForKey:@"data"];
            NSMutableArray *arrResult = [NSMutableArray array];
            id valForObject;
            
            if (arrResponse) {
                
                if ([arrResponse isKindOfClass:[NSArray class]]) {
                    
                    for (NSDictionary *dictionary in arrResponse) {
                        
                        TimeSheet *oneSheet = [[TimeSheet alloc] init];
                        
                        oneSheet.labourID = [[dictionary objectForKey:@"labour_id"] intValue];
                        oneSheet.jobID = [[dictionary objectForKey:@"job_id"] intValue];
                        oneSheet.labourTypeID = [[dictionary objectForKey:@"labour_type_id"] intValue];
                        
                        valForObject = [dictionary objectForKey:@"start_time"] ;
                        if (valForObject == [NSNull null])
                            continue;
                        oneSheet.startTime = [[NSDate alloc] init];
                        oneSheet.startTime = [timesheetFormatter dateFromString:(NSString *)valForObject];

                        valForObject = [dictionary objectForKey:@"end_time"] ;
                        if (valForObject == [NSNull null])
                            continue;
                        oneSheet.endTime = [[NSDate alloc] init];
                        oneSheet.endTime = [timesheetFormatter dateFromString:(NSString *)valForObject];

                        
                        valForObject = [dictionary objectForKey:@"company_name"] ;
                        if (valForObject == [NSNull null])
                            oneSheet.companyName = @"";
                        else
                            oneSheet.companyName = (NSString *)valForObject;
                        
                        valForObject = [dictionary objectForKey:@"description"] ;
                        if (valForObject == [NSNull null])
                            oneSheet.labourDescription = @"";
                        else
                            oneSheet.labourDescription = (NSString *)valForObject;

                        [arrResult addObject:oneSheet];
                    } // end for
                    
                } else {
                    // no jobs
                }
                
                sucess(arrResult);
            }
            else {
                failure(@"Invalid response");
            }
        }
    }];
    
}

- (void)getTimesheetByDates:(int)userId beginDate:(NSDate*)beginDate endDate:(NSDate*)endDate success:(void (^)(NSMutableArray *))sucess failure:(void (^)(NSString *))failure
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDateFormatter *timesheetFormatter = [[NSDateFormatter alloc] init];
    [timesheetFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *sessionId = [[AppContext sharedInstance] loadSession];
    NSDictionary *params = @{@"user_id": [NSString stringWithFormat:@"%d", userId],
                             @"begin_date": [dateFormatter stringFromDate:beginDate],
                             @"end_date": [dateFormatter stringFromDate:endDate]};
    
    DEF_SERVERMANAGER
    NSString *methodName = [NSString stringWithFormat:@"%@%@/%@", kAPIBaseUrlV2, sessionId, kMethodForGetTimesheetByDates];
    
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response,  NSError *error) {
        if (error != nil) {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil) {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"]) {
                failure(@"Invalid Parameters!");
            } else {
                failure(@"Invalid response");
            }
            
            return;
            
        } else {
            
            NSMutableArray *arrResponse = [response objectForKey:@"data"];
            NSMutableArray *arrResult = [NSMutableArray array];
            id valForObject;
            
            if (arrResponse) {
                
                if ([arrResponse isKindOfClass:[NSArray class]]) {
                    
                    for (NSDictionary *dictionary in arrResponse) {
                        
                        TimeSheet *oneSheet = [[TimeSheet alloc] init];
                        
                        oneSheet.labourID = [[dictionary objectForKey:@"labour_id"] intValue];
                        oneSheet.jobID = [[dictionary objectForKey:@"job_id"] intValue];
                        oneSheet.labourTypeID = [[dictionary objectForKey:@"labour_type_id"] intValue];
                        
                        valForObject = [dictionary objectForKey:@"start_time"] ;
                        if (valForObject == [NSNull null])
                            continue;
                        oneSheet.startTime = [[NSDate alloc] init];
                        oneSheet.startTime = [timesheetFormatter dateFromString:(NSString *)valForObject];
                        
                        valForObject = [dictionary objectForKey:@"end_time"] ;
                        if (valForObject == [NSNull null])
                            continue;
                        oneSheet.endTime = [[NSDate alloc] init];
                        oneSheet.endTime = [timesheetFormatter dateFromString:(NSString *)valForObject];
                        
                        
                        valForObject = [dictionary objectForKey:@"company_name"] ;
                        if (valForObject == [NSNull null])
                            oneSheet.companyName = @"";
                        else
                            oneSheet.companyName = (NSString *)valForObject;
                        
                        valForObject = [dictionary objectForKey:@"description"] ;
                        if (valForObject == [NSNull null])
                            oneSheet.labourDescription = @"";
                        else
                            oneSheet.labourDescription = (NSString *)valForObject;
                        
                        [arrResult addObject:oneSheet];
                    } // end for
                    
                } else {
                    // no jobs
                }
                
                sucess(arrResult);
            }
            else {
                failure(@"Invalid response");
            }
        }
    }];
    
}


- (void)getUserPins:(int)userId date:(NSDate*)date success:(void (^)(NSMutableArray *))sucess failure:(void (^)(NSString *))failure
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDateFormatter *timesheetFormatter = [[NSDateFormatter alloc] init];
    [timesheetFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    
    NSString *sessionId = [[AppContext sharedInstance] loadSession];
    NSDictionary *params = @{@"user_id": [NSString stringWithFormat:@"%d", userId],
                             @"selected_date": [dateFormatter stringFromDate:date] };
    
    DEF_SERVERMANAGER
    NSString *methodName = [NSString stringWithFormat:@"%@%@/%@", kAPIBaseUrlV2, sessionId, kMethodForGetUserPins];
    
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response,  NSError *error) {
        if (error != nil) {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil) {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"]) {
                failure(@"Invalid Parameters!");
            } else {
                failure(@"Invalid response");
            }
            
            return;
            
        } else {
            
            NSMutableArray *arrResponse = [response objectForKey:@"data"];
            NSMutableArray *arrResult = [NSMutableArray array];
            id valForObject;
            
            if (arrResponse) {
                
                if ([arrResponse isKindOfClass:[NSArray class]]) {
                    
                    for (NSDictionary *dictionary in arrResponse) {
                        
                        UserPin *onePin = [[UserPin alloc] init];
                        
                        onePin.locationID = [[dictionary objectForKey:@"user_location_id"] intValue];
                        onePin.userID = [[dictionary objectForKey:@"user_id"] intValue];
                        onePin.lat = [[dictionary objectForKey:@"lat"] doubleValue];
                        onePin.lon = [[dictionary objectForKey:@"lon"] doubleValue];
                        
                        valForObject = [dictionary objectForKey:@"creation_date"] ;
                        if (valForObject == [NSNull null])
                            continue;
                        onePin.creationTime = [[NSDate alloc] init];
                        onePin.creationTime = [timesheetFormatter dateFromString:(NSString *)valForObject];
                        
                        [arrResult addObject:onePin];
                    } // end for
                    
                } else {
                    // no jobs
                }
                
                sucess(arrResult);
            }
            else {
                failure(@"Invalid response");
            }
        }
    }];
    
}

- (void)insertUserPin:(int)userId lat:(double)lat lon:(double)lon creationDateTime:(NSDate*)creationDateTime success:(void (^)(BOOL))sucess failure:(void (^)(NSString *))failure
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *sessionId = [[AppContext sharedInstance] loadSession];
    NSDictionary *params = @{@"user_id": [NSString stringWithFormat:@"%d", userId],
                             @"lat": [NSString stringWithFormat:@"%f", lat],
                             @"lon": [NSString stringWithFormat:@"%f", lon],
                             @"creation_date": [dateFormatter stringFromDate:creationDateTime] };
    
    DEF_SERVERMANAGER
    NSString *methodName = [NSString stringWithFormat:@"%@%@/%@", kAPIBaseUrlV2, sessionId, kMethodForInsertUserPin];
    
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response,  NSError *error) {
        if (error != nil) {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil) {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"]) {
                failure(@"Invalid Parameters!");
            } else {
                failure(@"Invalid response");
            }
            
            return;
            
        } else {
            sucess(YES);
        }
    }];
    
}


- (void)insertTimesheet:(int)userId startTime:(NSDate*)startTime endTime:(NSDate*)endTime jobID:(int)jobID companyName:(NSString *)companyName labourTypeId:(int)labourTypeId notes:(NSString *)notes success:(void (^)(BOOL))sucess failure:(void (^)(NSString *))failure
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *sessionId = [[AppContext sharedInstance] loadSession];
    NSDictionary *params = @{@"user_id": [NSString stringWithFormat:@"%d", userId],
                             @"start_time": [dateFormatter stringFromDate:startTime],
                             @"end_time": [dateFormatter stringFromDate:endTime],
                             @"job_id": [NSString stringWithFormat:@"%d", jobID],
                             @"company_name": companyName,
                             @"labour_type_id": [NSString stringWithFormat:@"%d", labourTypeId],
                             @"description": notes } ;
    
    DEF_SERVERMANAGER
    NSString *methodName = [NSString stringWithFormat:@"%@%@/%@", kAPIBaseUrlV2, sessionId, kMethodForInsertTimesheet];
    
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response,  NSError *error) {
        if (error != nil) {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil) {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"]) {
                failure(@"Invalid Parameters!");
            } else {
                failure(@"Invalid response");
            }
            
            return;
            
        } else {
            sucess(YES);
        }
    }];
    
}

- (void)changetimesheet:(int)userId labourID:(int)labourID updateStartTime:(NSDate*)updateStartTime updateEndTime:(NSDate*)updateEndTime jobID:(int)jobID labourTypeId:(int)labourTypeId notes:(NSString*)notes success:(void (^)(BOOL))sucess failure:(void (^)(NSString *))failure
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *sessionId = [[AppContext sharedInstance] loadSession];
    NSDictionary *params = @{@"user_id": [NSString stringWithFormat:@"%d", userId],
                             @"labour_id": [NSString stringWithFormat:@"%d", labourID],
                             @"update_start_time": [dateFormatter stringFromDate:updateStartTime],
                             @"update_end_time": [dateFormatter stringFromDate:updateEndTime],
                             @"job_id": [NSString stringWithFormat:@"%d", jobID],
                             @"labour_type_id": [NSString stringWithFormat:@"%d", labourTypeId],
                             @"description": notes   };
    
    DEF_SERVERMANAGER
    NSString *methodName = [NSString stringWithFormat:@"%@%@/%@", kAPIBaseUrlV2, sessionId, kMethodForChangeTimesheet];
    
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response,  NSError *error) {
        if (error != nil) {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil) {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"]) {
                failure(@"Invalid Parameters!");
            } else {
                failure(@"Invalid response");
            }
            
            return;
            
        } else {
            sucess(YES);
        }
    }];
    
}



@end
