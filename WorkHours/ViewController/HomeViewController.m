//
//  HomeViewController.m
//  WorkHours
//
//  Created by Admin on 5/12/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "HomeViewController.h"
#import "UIManager.h"
#import "MarkerView.h"
#import "AddWorkViewController.h"
#import "NSDate+timeZone.h"
#import "ServerManager.h"
#import "GDIInfinitePageScrollViewController.h"
#import "DayEventViewController.h"
#import "NSDate+Utilities.h"
#import "SVProgressHUD+WorkHours.h"
#import "AppContext.h"
#import "UserContext.h"
#import "UserLocationManager.h"
#import "UserPin.h"
#import "LabourType.h"


#define kAssignedPinImage           "purple_pin.png"
#define kUnassignedPinImage       "red_pin.png"

#define kMapZoom                6//12

@interface HomeViewController () <GMSMapViewDelegate, MarkerViewDelegate, JTCalendarDataSource, GDIInfinitePageScrollViewControllerDelegate, PinMapDelegate> {
    
    BOOL isTestMode;
    
    BOOL isMapviewMode;
    NSDate *selDate;
    
    double prevUserLat;
    double prevUserLon;
    
    GMSMapView *userJobMapView;
    
    GDIInfinitePageScrollViewController *eventScrollerVC;
    
    NSInteger dateOffsetDays;
    NSUInteger maxEventPageIndex;
    NSUInteger prevPageIndex;
    
    NSArray *timesheetVCArray;
    
    NSTimer *userLocationRefreshTimer;
    NSTimeInterval intervalSecs;
    
   
    NSDate *todayWorkTimeBegin;
    NSDate *todayWorkTimeEnd;
    
    AppContext *appContext;
    UserContext *userContext;
    
}

@property (weak, nonatomic) IBOutlet UIView *viewMap;
@property (weak, nonatomic) IBOutlet UIView *viewList;
@property (weak, nonatomic) IBOutlet UIButton *btnMapview;
@property (weak, nonatomic) IBOutlet UIButton *btnListview;
@property (weak, nonatomic) IBOutlet UIView *viewCalendar;
@property (weak, nonatomic) IBOutlet JTCalendarMenuView *calendarMenu;
@property (weak, nonatomic) IBOutlet JTCalendarContentView *calendarContent;

@property (weak, nonatomic) IBOutlet UIView *viewDayEvent;
@property (weak, nonatomic) IBOutlet UILabel *lblNoneJobs;

@end

@implementation HomeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIManager sharedInstance] isVisibleStatusBar:self.navigationController isShow:YES];
    self.navigationItem.hidesBackButton = YES;
    
    // Do any additional setup after loading the view.
    
    [self initLocalVariables];
    
}

- (void)viewDidLayoutSubviews {
    [self.calendar repositionViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIManager sharedInstance] isVisibleStatusBar:self.navigationController isShow:NO];
    
    if (isMapviewMode)
    {
        NSDate *currDate = [NSDate date];
        
        [self getTimesheetUserPins:currDate];
        
    } else {
        // refresh calendar event view
        [self getEventFromDate:selDate eventPageIndex:prevPageIndex];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateButtonUI {
    if (isMapviewMode) {
        [[UIManager sharedInstance] applySelectedButtonStyle:self.btnMapview];
        [[UIManager sharedInstance] applyUnselectedButtonStyle:self.btnListview];
        
        self.navigationItem.rightBarButtonItem = nil;
    }
    else {
        [[UIManager sharedInstance] applyUnselectedButtonStyle:self.btnMapview];
        [[UIManager sharedInstance] applySelectedButtonStyle:self.btnListview];
        
        [self getEventFromDate:selDate eventPageIndex:prevPageIndex];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)onMapviewClicked:(id)sender {
    if (isMapviewMode == NO) {
        isMapviewMode = YES;
        self.viewMap.hidden = NO;
        self.viewList.hidden = YES;
        [self updateButtonUI];
        
        NSDate *currDate = [NSDate date];
        
        [self getTimesheetUserPins:currDate];
    }
}

- (IBAction)onListviewClicked:(id)sender {
    if (isMapviewMode == YES) {
        isMapviewMode = NO;
        self.viewMap.hidden = YES;
        self.viewList.hidden = NO;
        [self updateButtonUI];
    }
}

- (IBAction)onNewEventClicked:(id)sender {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    
    NSDate *todayTime = [NSDate date];

    NSString *startDateTime = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:00",
                                 (int)selDate.year, (int)selDate.month, (int)selDate.day, (int)todayTime.hour, (int)todayTime.minute];
    
    NSDate *startTime = [[NSDate alloc] init];
    startTime = [dateFormat dateFromString:startDateTime];
    
    NSDate *endTime = [[NSDate alloc] initWithTimeInterval:3600 sinceDate:startTime];
    
    [self gotoAddNewEvent:startTime endTime:endTime initLabourTypeId:kLabourTypeId_Labour];
}


- (void)initLocalVariables
{
    isTestMode = kTestMode;

    // init local variables
    {
        appContext = [AppContext sharedInstance];
        userContext = [UserContext sharedInstance];
        
        userContext.mapDelegate = self;
        
        // init arrUserPins
        [userContext initUserPinArray:nil];
        
    }
    
    isMapviewMode = YES;
    [self updateButtonUI];
    
    
    // init calendar views
    {
        [self initCalendarView];
        
        selDate = self.calendar.currentDate;
        
        NSDate *todayDate = [NSDate date];
        NSInteger todayOffsetDays = [todayDate distanceInDaysToDate:selDate];
        
        // int work begin-end time
        {
            NSString *szWorkTimeBegin = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:00",
                                         (int)todayDate.year, (int)todayDate.month, (int)todayDate.day, kDayWorkTime_BeginHour, kDayWorkTime_BeginMin];
            NSString *szWorkTimeEnd = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:00",
                                       (int)todayDate.year, (int)todayDate.month, (int)todayDate.day, kDayWorkTime_EndHour, kDayWorkTime_EndMin];
            
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            todayWorkTimeBegin = [[NSDate alloc] init];
            todayWorkTimeEnd = [[NSDate alloc] init];
            
            todayWorkTimeBegin = [dateFormat dateFromString:szWorkTimeBegin];
            todayWorkTimeEnd = [dateFormat dateFromString:szWorkTimeEnd];
        }


        dateOffsetDays = todayOffsetDays;
        
        [self initDayEventView];
        
        self.lblNoneJobs.hidden = YES;
    }
    
    
    // init user location refresh
}


//================================================
//          Map View development for event list
//================================================

// get user pins by date from server
- (void)getUserPinsFromServer
{
    int user_id = [ appContext loadUserID];
    NSDate *selectDate = [NSDate date];
    
    
    [ [ServerManager sharedManager] getUserPins:user_id date:selectDate success:^(NSMutableArray *arrPins)
     {
         HIDE_PROGRESS;
         
         [userContext initUserPinArray:arrPins];
         [userContext.mapDelegate displayUserLocation];
         [userContext.mapDelegate displayPins];
         
         
     } failure:^(NSString *failure)
     {
         HIDE_PROGRESS_WITH_FAILURE(failure);
     }];
    
}


- (void)setMapMarkWithUserPins
{
    NSMutableArray *arrUserPins = userContext.arrUserPins;
    
    // add map marker with user pins in today
    for (UserPin *onePin in arrUserPins)
    {
        GMSMarker *jobMarker = [[GMSMarker alloc] init];
        
        jobMarker.position = CLLocationCoordinate2DMake(onePin.lat, onePin.lon);
        jobMarker.title = @"";
        jobMarker.snippet = @"";
        jobMarker.map = userJobMapView;
        jobMarker.userData = onePin;
        
        if ([userContext getCoveredTimesheet:onePin.creationTime] == nil) {
            jobMarker.icon = [UIImage imageNamed:@kUnassignedPinImage];
        }
        else {
            jobMarker.icon = [UIImage imageNamed:@kAssignedPinImage];
        }
    }
}



#pragma Google Map View
- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    //    MarkerView *view = [[MarkerView alloc] init];
    
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"MarkerView" owner:self options:nil] lastObject];
    MarkerView *tmpView = (MarkerView *)view;
    
    UserPin *onePin = (UserPin *)marker.userData;
    TimeSheet *sheet = [userContext getCoveredTimesheet:onePin.creationTime];
    
    NSDateFormatter *timeFormat = [NSDateFormatter new];
    timeFormat.dateFormat = @"hh:mm a";
    
    NSString *jobTitle = [NSString stringWithFormat:@"%d - %@", sheet.jobID, sheet.companyName];
    
    [tmpView initWithTimeJobMark:[timeFormat stringFromDate:sheet.startTime]
                         endTime:[timeFormat stringFromDate:sheet.endTime]
                        jobTitle:jobTitle
                      jobContent:sheet.jobDescription];
    
    [[UIManager sharedInstance] applyViewRoundRect:view cornerRadius:5];
    
    return view;
}


// marker selecting event
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    UserPin *onePin = (UserPin *)marker.userData;
    
    TimeSheet *sheet = [userContext getCoveredTimesheet:onePin.creationTime];

    if (sheet == nil) {
        // go to new event page
        
        NSDate *endTime = [[NSDate alloc] initWithTimeInterval:3600 sinceDate:onePin.creationTime];
        
        [self gotoAddNewEvent:onePin.creationTime endTime:endTime initLabourTypeId:kLabourTypeId_Labour];
    }
    else {
        // set selected marker for info window showing
        [mapView setSelectedMarker:marker];
    }
    
    return YES;
}


#pragma MarkerView delegate
- (void)didDetailTap {
    ;
}


//================================================
//          Calendar View development for event list
//================================================

- (void)initCalendarView
{
    self.calendar = [JTCalendar new];
    
    // All modifications on calendarAppearance have to be done before setMenuMonthsView and setContentView
    // Or you will have to call reloadAppearance
    {
        self.calendar.calendarAppearance.calendar.firstWeekday = 2; // Sunday == 1, Saturday == 7
        self.calendar.calendarAppearance.dayCircleRatio = 9. / 10.;
        self.calendar.calendarAppearance.ratioContentMenu = 2.;
        self.calendar.calendarAppearance.focusSelectedDayChangeMode = YES;
        
        // Customize the text for each month
        self.calendar.calendarAppearance.monthBlock = ^NSString *(NSDate *date, JTCalendar *jt_calendar){
            NSCalendar *calendar = jt_calendar.calendarAppearance.calendar;
            NSDateComponents *comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
            NSInteger currentMonthIndex = comps.month;
            
            static NSDateFormatter *dateFormatter;
            if(!dateFormatter){
                dateFormatter = [NSDateFormatter new];
                dateFormatter.timeZone = jt_calendar.calendarAppearance.calendar.timeZone;
            }
            
            while(currentMonthIndex <= 0) {
                currentMonthIndex += 12;
            }
            
            NSString *monthText = [[dateFormatter standaloneMonthSymbols][currentMonthIndex - 1] capitalizedString];
            
            return [NSString stringWithFormat:@"%ld\n%@", (long)comps.year, monthText];
        };
    }
    
    [self.calendar setMenuMonthsView:self.calendarMenu];
    [self.calendar setContentView:self.calendarContent];
    [self.calendar setDataSource:self];
    
    [self.calendar reloadData];
}

#pragma mark - JTCalendarDataSource

- (BOOL)calendarHaveEvent:(JTCalendar *)calendar date:(NSDate *)date
{
    return NO;
}

- (void)calendarDidDateSelected:(JTCalendar *)calendar date:(NSDate *)date {
    selDate = date;
    
    NSDate *tmpDate = [NSDate date];
    NSInteger todayOffsetDays = [tmpDate distanceInDaysToDate:selDate];
    
    dateOffsetDays = todayOffsetDays;
    
    NSInteger offsetMin = [tmpDate minutesBeforeDate:selDate];
    dateOffsetDays = offsetMin / 1440;
    
    if (offsetMin % 1440 != 0) {
        if (offsetMin >  0)
            dateOffsetDays ++;
    }
    
    [self getEventFromDate:selDate eventPageIndex:prevPageIndex];
}

- (void)calendarDidLoadPreviousPage
{
    NSLog(@"Previous page loaded");
}

- (void)calendarDidLoadNextPage
{
    NSLog(@"Next page loaded");
}

#pragma mark - Fake data

- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd-MM-yyyy";
    }
    
    return dateFormatter;
}


//================================================
//          Day Event View development for event list
//================================================

- (void)initDayEventView
{
    DayEventViewController *dayEvent1 = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"dayEventVC"];
    DayEventViewController *dayEvent2 = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"dayEventVC"];
    DayEventViewController *dayEvent3 = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"dayEventVC"];
    
    
    timesheetVCArray = [NSArray arrayWithObjects:dayEvent1, dayEvent2, dayEvent3, nil];
    eventScrollerVC = [[GDIInfinitePageScrollViewController alloc] initWithViewControllers:timesheetVCArray];
    eventScrollerVC.delegate = self;
    
    CGRect eventRect = self.viewDayEvent.frame;
    eventRect.origin.x = 0;
    eventRect.origin.y = 0;
    
    
    dateOffsetDays = 0;
    maxEventPageIndex = [eventScrollerVC countOfPages];
    if (maxEventPageIndex > 0)
        maxEventPageIndex --;
    prevPageIndex = 0;
    
    
    [self.viewDayEvent addSubview:eventScrollerVC.view];
    [eventScrollerVC.view setFrame:eventRect ];
}

- (void)getEventFromDate:(NSDate *)date eventPageIndex:(NSUInteger)index
{
    [self getTimesheetByDateFromServer:date isShowEvent:YES eventPageIndex:index];
}


- (void)displayDayTimesheets:(TimeSheetPerDay* )daySheets eventPageIndex:(NSUInteger)eventPageIndex
{
    DayEventViewController *nextVC = [timesheetVCArray objectAtIndex:eventPageIndex];
    
    BOOL isHasJobs = YES;
    
    
    if (daySheets != nil && daySheets.dayDate != nil) {
        [nextVC initWithTimesheets:daySheets.dayDate TimesheetList:daySheets.arrTimesheets];
    }
    
    if (daySheets == nil || daySheets.arrTimesheets == nil || daySheets.arrTimesheets.count == 0)
        isHasJobs = NO;
    
    self.lblNoneJobs.hidden = isHasJobs;
    
}


- (void)getTimesheetByDateFromServer:(NSDate*)select_date isShowEvent:(BOOL)isShowEvent eventPageIndex:(NSUInteger)eventPageIndex
{
    
    int user_id = [appContext loadUserID];
    
    SHOW_PROGRESS(@"Fetching data...");
    
    [[ServerManager sharedManager] getTimesheetByDate:user_id selectedDate:select_date success:^(NSMutableArray *arrSheets)
    {
        HIDE_PROGRESS;
        
        TimeSheetPerDay *dayTimesheets = [[TimeSheetPerDay alloc] init];
        
        [dayTimesheets initWithParam:select_date arrTimeSheets:arrSheets];
        [userContext addDayTimesheets:dayTimesheets];
        
        if (isShowEvent) {
            [self displayDayTimesheets:dayTimesheets eventPageIndex:eventPageIndex];
        }
        
    } failure:^(NSString *failure)  {
        HIDE_PROGRESS_WITH_FAILURE(failure);
        
        if (isShowEvent) {
            [self displayDayTimesheets:nil eventPageIndex:eventPageIndex];
        }
        
    }];
}

- (void)getTimesheetUserPins:(NSDate*)select_date
{
    
    int user_id = [appContext loadUserID];
    
    
    SHOW_PROGRESS(@"Fetching data...");
    
    [[ServerManager sharedManager] getTimesheetByDate:user_id selectedDate:select_date success:^(NSMutableArray *arrSheets)
     {
         [userContext initTodayTimesheets:arrSheets];
         
         [self getUserPinsFromServer];
         
         
     } failure:^(NSString *failure)  {
         HIDE_PROGRESS_WITH_FAILURE(failure);
         
     }];
}


#pragma GDIInfinitePageScrollViewControllerDelegate

- (void)infiniteScrollView:(GDIInfinitePageScrollViewController *)scrollViewController didScrollToIndex:(NSUInteger)index {
    NSLog(@"new Page Index = %d\n", (int)index);
    
    NSDateFormatter *newFormat = [NSDateFormatter new];
    newFormat.dateFormat = @"yyyy-MM-dd";
    
    NSString *curDateString = [newFormat stringFromDate:selDate];
    NSLog(@"Curr date  = %@\n", curDateString);
    
    dateOffsetDays = 0;
    
    if (index == maxEventPageIndex) {
        if (prevPageIndex == (maxEventPageIndex - 1))
            dateOffsetDays ++;
        else
            dateOffsetDays --;
    } else if (index == 0) {
        if (prevPageIndex == maxEventPageIndex)
            dateOffsetDays ++;
        else
            dateOffsetDays --;
    } else {
        if (index > prevPageIndex)
            dateOffsetDays ++;
        else
            dateOffsetDays --;
    }
    
    prevPageIndex = index;
    
    NSDate *nextDate = [selDate dateByAddingDays:dateOffsetDays];
    
    // get event data for selected date
    [self getEventFromDate:nextDate eventPageIndex:index];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kJTCalendarDaySelected" object:nextDate];
    
    // Store currentDateSelected
    [self.calendar setCurrentDateSelected:nextDate];
    
    
    // change page
    if ([selDate month] != [nextDate month]) {
        
        if([selDate compare:nextDate]  == NSOrderedAscending) {
            [self.calendar loadNextPage];
        }
        else {
            [self.calendar loadPreviousPage];
        }
    }
    
    selDate = nextDate;
    
    
    curDateString = [newFormat stringFromDate:nextDate];
    NSLog(@"seleted date  = %@\n", curDateString);
}



//================================================
//          goto New Event Add window
//================================================

- (void)gotoAddNewEvent:(NSDate *)startTime endTime:(NSDate*)endTime initLabourTypeId:(int)initLabourTypeId
{
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    AddWorkViewController *vc = [stb instantiateViewControllerWithIdentifier:@"addWorkViewController"];
    
    vc.startTime = [[NSDate alloc] initWithTimeInterval:0 sinceDate:startTime];
    vc.endTime = [[NSDate alloc] initWithTimeInterval:0 sinceDate:endTime];
    vc.initLabourTypeId = initLabourTypeId;
    vc.isTestMode = isTestMode;
    [self.navigationController pushViewController:vc animated:YES];
}


//================================================
//          PinMap delegate
//================================================
- (void)displayUserLocation
{
    double user_lat = [ appContext loadUserLocationLat];
    double user_lon = [ appContext loadUserLocationLng];
    
    NSLog(@"latitude = %.8f\nlongitude = %.8f\n", user_lat, user_lon);
    
    // display current location on google map
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:user_lat
                                                            longitude:user_lon
                                                                 zoom:kMapZoom];
    userJobMapView = [GMSMapView mapWithFrame:self.view.bounds camera:camera];
    userJobMapView.delegate = self;
    userJobMapView.myLocationEnabled = YES;
    [self.viewMap addSubview:userJobMapView];
}

- (void)displayPins
{
    NSMutableArray *arrUserPins = userContext.arrUserPins;
    
    // add map marker with user pins in today
    for (UserPin *onePin in arrUserPins)
    {
        GMSMarker *jobMarker = [[GMSMarker alloc] init];
        
        jobMarker.position = CLLocationCoordinate2DMake(onePin.lat, onePin.lon);
        jobMarker.title = @"";
        jobMarker.snippet = @"";
        jobMarker.map = userJobMapView;
        jobMarker.userData = onePin;
        
        if ([userContext getCoveredTimesheet:onePin.creationTime] == nil) {
            jobMarker.icon = [UIImage imageNamed:@kUnassignedPinImage];
        }
        else {
            jobMarker.icon = [UIImage imageNamed:@kAssignedPinImage];
        }
    }
}

- (void)gotoNewEventWindow:(NSDate *)startTime endTime:(NSDate*)endTime initLabourTypeId:(int)initLabourTypeId
{
    [self gotoAddNewEvent:startTime endTime:endTime initLabourTypeId:initLabourTypeId];
}

@end
