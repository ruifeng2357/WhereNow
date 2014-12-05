//
//  SVProgressHUD+WhereNow.h
//  WalkItOff
//
//  Created by Xiaoxue Han on 7/2/14.
//  Copyright (c) 2014 daniel. All rights reserved.
//

#ifndef WhereNow_SVProgressHUD_WhereNow_h
#define WhereNow_SVProgressHUD_WhereNow_h

#import "SVProgressHUD.h"

#define kSVProgressMsgDelay    2.0

#define SHOW_PROGRESS(msg)  [SVProgressHUD showWithStatus:msg maskType:SVProgressHUDMaskTypeGradient];

#define HIDE_PROGRESS_WITH_SUCCESS(msg) [SVProgressHUD dismissWithSuccess:(msg) afterDelay:kSVProgressMsgDelay];

#define HIDE_PROGRESS_WITH_FAILURE(msg) [SVProgressHUD dismissWithError:(msg) afterDelay:kSVProgressMsgDelay];


#endif
