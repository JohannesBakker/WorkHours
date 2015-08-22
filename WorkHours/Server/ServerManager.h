//
//  SeverManager.h
//  WalkItOff
//
//  Created by Donald Pae on 7/2/14.
//  Copyright (c) 2014 daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HOST_URL    @"http://dev.scmedical.com.au/"
#define API_URL     @"http://dev.scmedical.com.au/mobile/index.php/"


// v2
#define kAPIBaseUrlV2               @"api/v2/"

#define kMethodForLoginV2           @"user"

#define kMethodForGetJobsByLocation        @"getjobsbylocation"
#define kMethodForGetUserList                    @"getuserlist"
#define kMethodForGetLabourType              @"getlabourtype"
#define kMethodForGetTimesheetByDate     @"gettimesheetbydate"
#define kMethodForGetUserPins                   @"getuserpins"
#define kMethodForInsertUserPin                  @"insertuserpin"
#define kMethodForInsertTimesheet              @"inserttimesheet"


#define DEF_SERVERMANAGER   ServerManager *manager = [ServerManager sharedManager];

typedef void (^ServerManagerRequestHandlerBlock)(NSString *, NSDictionary *, NSError *);

@interface ServerManager : NSObject

+ (ServerManager *)sharedManager;

- (void)getMethod:(NSString *)methodName params:(NSDictionary *)params handler:(ServerManagerRequestHandlerBlock)handler;
- (void)postMethod:(NSString *)methodName params:(NSDictionary *)params handler:(ServerManagerRequestHandlerBlock)handler;


- (void)loginUser:(NSString *)userName pwd:(NSString *)pwd success:(void (^)(NSString *sessionId, NSString *userId, NSString *fullname))success failure:(void (^)(NSString *))failure;

- (void)getJobsByLocation:(double)lat lon:(double)lon success:(void (^)(NSMutableArray *))sucess failure:(void (^)(NSString *))failure;
- (void)getUserList:(void (^)(NSMutableArray *))sucess failure:(void (^)(NSString *))failure;
- (void)getLabourType:(void (^)(NSMutableArray *))sucess failure:(void (^)(NSString *))failure;
- (void)getTimesheetByDate:(int)userId selectedDate:(NSDate*)selectedDate success:(void (^)(NSMutableArray *))sucess failure:(void (^)(NSString *))failure;
- (void)getUserPins:(int)userId date:(NSDate*)date success:(void (^)(NSMutableArray *))sucess failure:(void (^)(NSString *))failure;
- (void)insertUserPin:(int)userId lat:(double)lat lon:(double)lon creationDateTime:(NSDate*)creationDateTime success:(void (^)(BOOL))sucess failure:(void (^)(NSString *))failure;
- (void)insertTimesheet:(int)userId startTime:(NSDate*)startTime endTime:(NSDate*)endTime jobID:(int)jobID companyName:(NSString *)companyName labourTypeId:(int)labourTypeId notes:(NSString *)notes success:(void (^)(BOOL))sucess failure:(void (^)(NSString *))failure;



@end
