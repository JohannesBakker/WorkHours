//
//  SVProgressHUD+WorkHours.h
//  WorkHours
//


#ifndef SVProgressHUD_WorkHours_h
#define SVProgressHUD_WorkHours_h

#import "SVProgressHUD.h"

#define kSVProgressMsgDelay    2.0

#define SHOW_PROGRESS(msg)  [SVProgressHUD showWithStatus:msg maskType:SVProgressHUDMaskTypeGradient];

#define HIDE_PROGRESS       [SVProgressHUD dismiss];

#define HIDE_PROGRESS_WITH_SUCCESS(msg) [SVProgressHUD dismissWithSuccess:(msg) afterDelay:kSVProgressMsgDelay];

#define HIDE_PROGRESS_WITH_FAILURE(msg) [SVProgressHUD dismissWithError:(msg) afterDelay:kSVProgressMsgDelay];

#endif
