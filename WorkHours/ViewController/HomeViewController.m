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
#import "TimeSheet.h"


#define kAssignedPinImage           "purple_pin.png"
#define kUnassignedPinImage       "red_pin.png"

#define kMapZoom                13//6//12

@interface HomeViewController () <GMSMapViewDelegate, MarkerViewDelegate, JTCalendarDataSource, GDIInfinitePageScrollViewControllerDelegate, PinMapDelegate, HomeViewDelegate> {
    
    BOOL isTestMode;
    
    BOOL isMapviewMode;
    NSDate *selDate;
    
    double prevUserLat;
    double prevUserLon;
    
    GMSMapView *userJobMapView;
    
    GDIInfinitePageScrollViewController *eventScrollerVC;
    
    NSUInteger maxEventPageIndex;
    NSUInteger prevPageIndex;
    
    NSArray *timesheetVCArray;
    
    NSTimer *userLocationRefreshTimer;
    NSTimeInterval intervalSecs;
    
    AppContext *appContext;
    UserContext *userContext;
    
    NSMutableDictionary *dictTimesheets;
    
    // alert view variable
    int resAlertType;
    NSString *resAlertTitle;
    NSString *resAlertMsg;
    
}

@property (weak, nonatomic) IBOutlet UIView *viewMap;
@property (weak, nonatomic) IBOutlet UIView *viewList;
@property (weak, nonatomic) IBOutlet UIView *viewCalendar;
@property (weak, nonatomic) IBOutlet JTCalendarMenuView *calendarMenu;
@property (weak, nonatomic) IBOutlet JTCalendarContentView *calendarContent;

@property (weak, nonatomic) IBOutlet UIView *viewDayEvent;
@property (weak, nonatomic) IBOutlet UILabel *lblNoneTimesheets;

@property (weak, nonatomic) IBOutlet UIView *viewMapTitle;
@property (weak, nonatomic) IBOutlet UIView *viewConnection;
@property (weak, nonatomic) IBOutlet UILabel *lblMapTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblCalendarConnection;
@property (weak, nonatomic) IBOutlet UIButton *btnYear;


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
    
    // hide navigationController
    [[UIManager sharedInstance] isVisibleStatusBar:self.navigationController isShow:NO];
    
    // current VC is Home
    [userContext setActiveVC:VC_HOME];
    
    // download labour type list
    if (userContext.arrLabourType == nil || userContext.arrLabourType.count == 0)
    {
        SHOW_PROGRESS(@"Fetching data...");
        
        [[ServerManager sharedManager] getLabourType:^(NSMutableArray *arrLabourList) {
            
            HIDE_PROGRESS;
            
            [userContext initLabourTypeArray:arrLabourList];
            
        } failure:^(NSString *failure) {
            
            HIDE_PROGRESS_WITH_FAILURE(failure);
        }];
    }
    
    // display reserved alert
    if (userContext.isAlertReserved && !userContext.isAlertDisplay) {
        [userContext displayAlert];
    }
    
    if (isMapviewMode)
    {
        // update UI
        [self updateMapUI];

        // refresh map
        NSDate *currDate = [NSDate date];
        [self getTimesheetUserPins:currDate];
    }
    else {
        
        // refresh UI
        [self updateCalendarUI];
        
        // download timesheets for current month
        [self getTimesheetsByMonthFromServer:selDate];
    }
   
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // status bar text color change with default color
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// update Map UI
- (void)updateMapUI {
    
    //self.navigationItem.rightBarButtonItem = nil;
    
    NSDate *currDate = [NSDate date];
    
    // refresh Map title
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, dd MMMM"];
    self.lblMapTitle.text = [dateFormatter stringFromDate:currDate];
    
    // change view color with mapTitle color
    self.view.backgroundColor = self.viewMapTitle.backgroundColor;
    
    // status bar text color change with default color
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

// update Calendar UI
- (void)updateCalendarUI {
    
    // change view color with connection color
    self.view.backgroundColor = self.viewConnection.backgroundColor;
    
    // status bar text color change with white color
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // change Year button title
    [self changeCalendarYearButton];
}

// display Personal hospital connections in Timesheet window
- (void)displayPersonalPospitalConnections:(NSDate *)selectedDate {
    
    NSUInteger nConnections = [userContext getTimesheetsConnections:selectedDate];
    self.lblCalendarConnection.text = [NSString stringWithFormat:@"%d", (int)nConnections];
}

// change year button title
- (void)changeCalendarYearButton {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM YYYY"];
    
    [self.btnYear setTitle:[dateFormatter stringFromDate:self.calendar.currentDate] forState:UIControlStateNormal];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// Year button event on Calendar UI
- (IBAction) onCalendarYearClicked:(id)sendor {
    NSLog(@"Clicked Calendar year button");
    
    
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

- (IBAction)onChangedViewType:(id)sender {
    UISegmentedControl *segType = (UISegmentedControl*)sender;
    
    if (segType.selectedSegmentIndex == 0) {
        isMapviewMode = YES;
        self.viewMap.hidden = NO;
        self.viewList.hidden = YES;
        
        // update Map UI
        [self updateMapUI];
        
        
        NSDate *currDate = [NSDate date];
        
        [self getTimesheetUserPins:currDate];
        
    }
    else {
        isMapviewMode = NO;
        self.viewMap.hidden = YES;
        self.viewList.hidden = NO;

        // update Calendar UI
        [self updateCalendarUI];
        
        // download timesheets for current month
        [self getTimesheetsByMonthFromServer:selDate];
    }
}


- (void)initLocalVariables
{
    isTestMode = kTestMode;

    // init local variables
    {
        appContext = [AppContext sharedInstance];
        userContext = [UserContext sharedInstance];
        
        userContext.mapDelegate = self;
        userContext.homeViewDelegate = self;
    }
    
    // init calendar view
    {
        [self initCalendarView];
        
        selDate = self.calendar.currentDate;
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        [self initDayEventView];
        
        self.lblNoneTimesheets.hidden = YES;
    }
    
    // init Map data
    isMapviewMode = YES;
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
         [self displayUserLocation];
         [self displayPins];
         
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
    
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"MarkerView" owner:self options:nil] lastObject];
    MarkerView *tmpView = (MarkerView *)view;
    
    UserPin *onePin = (UserPin *)marker.userData;
    TimeSheet *sheet = [userContext getCoveredTimesheet:onePin.creationTime];
    
    NSDateFormatter *timeFormat = [NSDateFormatter new];
    timeFormat.dateFormat = @"HH:mm";
    
    NSString *jobTitle = [NSString stringWithFormat:@"%d - %@", sheet.jobID, sheet.companyName];
    
    [tmpView initWithTimeJobMark:[timeFormat stringFromDate:sheet.startTime]
                         endTime:[timeFormat stringFromDate:sheet.endTime]
                        jobTitle:jobTitle
                      jobContent:sheet.labourDescription];
    
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
    NSUInteger events = [userContext getTimesheetsCount:date];
    
    if (events > 0)
        return YES;
    return NO;
}

- (void)calendarDidDateSelected:(JTCalendar *)calendar date:(NSDate *)date {
    selDate = date;
    
    [self displayTimesheets:selDate eventPageIndex:prevPageIndex];
}

- (void)calendarDidLoadPreviousPage
{
    NSLog(@"Previous page loaded");
    
    // change year button title
    [self changeCalendarYearButton];
    
    // download timesheets for current month
    [self getTimesheetsByMonthFromServer:self.calendar.currentDate];
}

- (void)calendarDidLoadNextPage
{
    NSLog(@"Next page loaded");
    
    // change year button title
    [self changeCalendarYearButton];
    
    // download timesheets for current month
    [self getTimesheetsByMonthFromServer:self.calendar.currentDate];
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
    
    maxEventPageIndex = [eventScrollerVC countOfPages];
    if (maxEventPageIndex > 0)
        maxEventPageIndex --;
    prevPageIndex = 0;
    
    [self.viewDayEvent addSubview:eventScrollerVC.view];
    [eventScrollerVC.view setFrame:eventRect ];
}

// display timesheets for selected date
- (void)displayTimesheets:(NSDate *)date eventPageIndex:(NSUInteger)eventPageIndex
{
    DayEventViewController *nextVC = [timesheetVCArray objectAtIndex:eventPageIndex];
    
    BOOL isHasJobs = YES;
    NSArray *arrTimesheets = [userContext getTimesheets:date];
    
    [nextVC initWithTimesheets:date TimesheetList:arrTimesheets];
    if (arrTimesheets == nil || arrTimesheets.count == 0) {
        isHasJobs = NO;
    }
    
    self.lblNoneTimesheets.hidden = isHasJobs;
    
    // display connections
    [self displayPersonalPospitalConnections:date];
}


- (void)getTimesheetUserPins:(NSDate*)select_date
{
    
    int user_id = [appContext loadUserID];
    
    SHOW_PROGRESS(@"Fetching data...");
    
    [[ServerManager sharedManager] getTimesheetByDate:user_id selectedDate:select_date success:^(NSMutableArray *arrSheets)
     {
         // set date timesheets
         [userContext addTimesheets:select_date arrSheets:arrSheets];
         
         [self getUserPinsFromServer];
         
         
     } failure:^(NSString *failure)  {
         HIDE_PROGRESS_WITH_FAILURE(failure);
         
     }];
}

// download timesheets for selected month
// duration : before 7 days ~ after 7 days
- (void)getTimesheetsByMonthFromServer:(NSDate*)selectedMonth
{
    // create current date with month
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    [comps setMonth:selectedMonth.month];
    [comps setYear:selectedMonth.year];
    
    int user_id = [appContext loadUserID];
    NSDate *newDate = [[NSCalendar currentCalendar] dateFromComponents:comps];
    
    NSDate *beginDate = [newDate dateBySubtractingDays:7];
    NSDate *endDate = [newDate dateByAddingDays:38];    // 38 : 31+7
    
    SHOW_PROGRESS(@"Fetching data...");
    
    [[ServerManager sharedManager] getTimesheetByDates:user_id beginDate:beginDate endDate:endDate success:^(NSMutableArray *arrSheets) {
        
        HIDE_PROGRESS;
        
        // remove previous timesheets
        [userContext removeTimesheets:beginDate endDate:endDate];
        
        // add timesheets
        [userContext addTimesheets:arrSheets];
        
        // refresh Calendar
        [self.calendar reloadData];
        
        if (!isMapviewMode) {
            // refresh calendar event view
            [self displayTimesheets:selDate eventPageIndex:prevPageIndex];
        }
        
    } failure:^(NSString *failure) {
        HIDE_PROGRESS_WITH_FAILURE(failure);
    }];
}

// download labour types from server
- (void)getLabourTypesFromServer {
    [[ServerManager sharedManager] getLabourType:^(NSMutableArray *arrLabourList) {
        
        HIDE_PROGRESS;
        [userContext initLabourTypeArray:arrLabourList];
        
    } failure:^(NSString *failure) {
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
    
    NSInteger dateOffsetDays = 0;
    
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
    [self displayTimesheets:nextDate eventPageIndex:index];
    
    
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
    
    vc.isTestMode = isTestMode;
    vc.nConnections = (int)[userContext getTimesheetsConnections:startTime];
    
    
    [vc createNewEvent:startTime eventEndTime:endTime labourTypeID:initLabourTypeId];
    [self.navigationController pushViewController:vc animated:YES];
}


//================================================
//          PinMapDelegate functions
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

- (void)gotoEditEventWindow:(TimeSheet *)sheet
{
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    AddWorkViewController *vc = [stb instantiateViewControllerWithIdentifier:@"addWorkViewController"];
    
    
    vc.isTestMode = isTestMode;
    vc.nConnections = (int)[userContext getTimesheetsConnections:sheet.startTime];
    
    [vc editSelectEvent:sheet];
    
    [self.navigationController pushViewController:vc animated:YES];

}

//================================================
//          HomeViewDelegate functions
//================================================
- (void)reserveAlert:(int)alertType title:(NSString*)title msg:(NSString*)msg {
    resAlertType = alertType;
    resAlertTitle = [NSString stringWithString:title];
    resAlertMsg = [NSString stringWithString:msg];
}

- (void)releaseAlert {
    
}

- (void)displayAlert {
    
    UIAlertView *alertView = [ [UIAlertView alloc] initWithTitle:resAlertTitle message:resAlertMsg delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"YES", nil ];
    
    [alertView show];
    
}

//================================================
//          AlertView functions
//================================================

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    double lat = [appContext loadUserLocationLat];
    double lon = [appContext loadUserLocationLng];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSDate *startTime = [NSDate date];
    
    userContext.isAlertDisplay = NO;
    userContext.isAlertReserved = NO;
    
    if (buttonIndex == 1) {
        
        if ((resAlertType == ALERT_AWAY_LOCATION)
            || (resAlertType == ALERT_TODAY_WORKING)
            || (resAlertType == ALERT_NO_TIMESHEET)) {
            
            
            
            [[ServerManager sharedManager] insertUserPin:[appContext loadUserID]
                                                     lat:lat
                                                     lon:lon
                                        creationDateTime:startTime success:^(BOOL result)
             {
                 
             } failure:^(NSString *failure)
             {
                 NSLog(@"location recording failed, %@ on %@\n", failure, [dateFormat stringFromDate:startTime]);
             }];
            
            
            if (resAlertType == ALERT_NO_TIMESHEET) {
                
                NSDate *endTime = [[NSDate alloc] initWithTimeInterval:3600 sinceDate:startTime];
                [self gotoAddNewEvent:startTime endTime:endTime initLabourTypeId:kLabourTypeId_Labour];
            }
        }
    }
    else {
        if (resAlertType == ALERT_TODAY_WORKING) {
            
            NSString *startDateTime = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:00",
                                       (int)startTime.year, (int)startTime.month, (int)startTime.day, kDayWorkTime_BeginHour, kDayWorkTime_BeginMin];
            NSString *endDateTime = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:00",
                                     (int)startTime.year, (int)startTime.month, (int)startTime.day, kDayWorkTime_EndHour, kDayWorkTime_EndMin];
            
            NSDate *allStartTime = [[NSDate alloc] init];
            allStartTime = [dateFormat dateFromString:startDateTime];
            
            NSDate *allEndTime = [[NSDate alloc] init];
            allEndTime = [dateFormat dateFromString:endDateTime];
            
            [self gotoNewEventWindow:allStartTime endTime:allEndTime initLabourTypeId:kLabourTypeId_Sick];
        }
    }
}


@end
