//
//  CalendarHistoryViewController.h
//  FortuneLinkAdmin
//
//  Created by 姚远 on 5/5/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"
#import "SunshireContractConnector.h"

@interface CalendarHistoryViewController : UIViewController<FSCalendarDelegate,FSCalendarDataSource,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,SunshireContractDelegate,FSCalendarDelegateAppearance>
@property (strong, nonatomic) IBOutlet FSCalendar *calendarView;

@property (strong, nonatomic) IBOutlet UITableView *tripView;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *verticalGesture;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *calendarViewHeightConstraint;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@end
