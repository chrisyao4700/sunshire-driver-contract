//
//  CalendarHistoryViewController.m
//  FortuneLinkAdmin
//
//  Created by 姚远 on 5/5/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "CalendarHistoryViewController.h"
#import "CYFunctionSet.h"
#import "CYColorSet.h"
#import "CurrentUserManager.h"
#import "TripDetailViewController.h"
@interface CalendarHistoryViewController (){
    void * _KVOContext;
}

@end

@implementation CalendarHistoryViewController{
    NSArray * trip_list;
    
    UIAlertController * alert;
    UIActivityIndicatorView * loadingView;
    
    NSDictionary * trip_pool;
    SunshireContractConnector * connector;
    
    NSArray * tripCountArray;
    NSDictionary * trip_count_dict;
    
    
    NSMutableDictionary * week_content;
    
    NSInteger request_count;
    
    SS_CONTRACT_USER * currentDriver;
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    
    if ([[UIDevice currentDevice].model hasPrefix:@"iPad"]) {
        self.calendarViewHeightConstraint.constant = 400;
    }
    
    [self.calendarView selectDate:[NSDate date] scrollToDate:YES];
    /*
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.calendarView action:@selector(handleScopeGesture:)];
    panGesture.delegate = self;
    panGesture.minimumNumberOfTouches = 1;
    panGesture.maximumNumberOfTouches = 2;
    [self.view addGestureRecognizer:panGesture];
    self.verticalGesture = panGesture;
    [self.tripView.panGestureRecognizer requireGestureRecognizerToFail:panGesture];

    */
    
    // While the scope gesture begin, the pan gesture of tableView should cancel.
    
    [self.calendarView addObserver:self forKeyPath:@"scope" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:_KVOContext];
    
    
    self.calendarView.scope = FSCalendarScopeMonth;
    
    // For UITest
    self.calendarView.accessibilityIdentifier = @"calendar";
    self.calendarView.backgroundColor = [CYColorSet getEightyBackgroundColor];
    //[self requestCountFromDate:self.calendarView.currentPage];
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"yyyy/MM/dd";
    }
    return self;
}

- (void)dealloc
{
    [self.calendarView removeObserver:self forKeyPath:@"scope" context:_KVOContext];
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - KVO
//I really don't know what it is doing. What is void * context? Is this even a right syntax??

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (context == _KVOContext) {
        FSCalendarScope oldScope = [change[NSKeyValueChangeOldKey] unsignedIntegerValue];
        FSCalendarScope newScope = [change[NSKeyValueChangeNewKey] unsignedIntegerValue];
        NSLog(@"From %@ to %@ Current Page:%@",(oldScope==FSCalendarScopeWeek?@"week":@"month"),(newScope==FSCalendarScopeWeek?@"week":@"month"),self.calendarView.currentPage.description);
      
        
        
        if (oldScope == FSCalendarScopeWeek) {
            if (self.calendarView.selectedDate) {
                [self.calendarView setCurrentPage:[CYFunctionSet getFirstDayOfTheMonthFromDate:[self.calendarView.selectedDates lastObject]]];
                
                week_content = nil;
                [self reloadTableView];
                
            
            }else{
                [self.calendarView setCurrentPage:[CYFunctionSet getFirstDayOfTheMonthFromDate:[NSDate date]]];
            }
            [self requestCountFromDate:self.calendarView.currentPage];
            
        }
        if (oldScope == FSCalendarScopeMonth) {
            NSDate * selected = [self.calendarView selectedDate];
            if (selected) {
                
                NSDate * first_day_week = [CYFunctionSet getFirstDayOfTheWeekFromDate:selected];
                [self.calendarView setCurrentPage:first_day_week];
                
            }else{
                [self.calendarView setCurrentPage:[CYFunctionSet getFirstDayOfTheWeekFromDate:[NSDate date]]];
            }
            [self requestCountFromDate:self.calendarView.currentPage];
           
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}
-(void)calendarCurrentPageDidChange:(FSCalendar *)calendar{
    [self requestCountFromDate:self.calendarView.currentPage];
    if (self.calendarView.scope == FSCalendarScopeMonth) {
        week_content = [[NSMutableDictionary alloc] init];
        [self reloadTableView];
    }

}
#pragma mark - <UIGestureRecognizerDelegate>

// Whether scope gesture should begin
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    BOOL shouldBegin = self.tripView.contentOffset.y <= -self.tripView.contentInset.top;
    if (shouldBegin) {
        CGPoint velocity = [self.verticalGesture velocityInView:self.view];
        switch (self.calendarView.scope) {
            case FSCalendarScopeMonth:
                return velocity.y < 0;
            case FSCalendarScopeWeek:
                return velocity.y > 0;
        }
    }
    return shouldBegin;
}

#pragma mark - <FSCalendarDelegate>

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    self.calendarViewHeightConstraint.constant = CGRectGetHeight(bounds);
    [self.view layoutIfNeeded];
}
-(void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition{
    
    [self requestEearningDataWithDate:date];
}

-(NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date{
    NSInteger temp = 0;
    if (trip_count_dict) {
        NSString * key = [CYFunctionSet convertDateToConstantString:date];
        
        if ([trip_count_dict.allKeys containsObject:key]) {
            NSString * count_str = [trip_count_dict objectForKey:key];
            NSNumber * count_num = [CYFunctionSet convertStringToNumber:count_str];
            /*
             *
            if (count_num.integerValue >0 && count_num.integerValue <5) {
                temp = 1;
            }
            if (count_num.integerValue>= 5 && count_num.integerValue < 10) {
                temp = 2;
            }
            if (count_num.integerValue >= 10) {
                temp = 3;
            }
             *
             */
            temp = count_num.integerValue;
        }
    }
    return temp;
    
}



-(void) reloadCanlendar{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.calendarView reloadData];
    });
}



#pragma mark - datasocket delegate
-(void)viewWillAppear:(BOOL)animated {
    [self requestEearningDataWithDate:self.calendarView.selectedDate];
}
-(void) requestCountFromDate:(NSDate *) aDate{
    dispatch_async(dispatch_get_main_queue(), ^{
        trip_count_dict = nil;
        NSDate * start_date = aDate;
        NSDate * end_date;
        if (self.calendarView.scope == FSCalendarScopeWeek) {
            end_date = [NSDate dateWithTimeInterval:60*60*24*7 sinceDate:start_date];
        }
        if (self.calendarView.scope == FSCalendarScopeMonth) {
            end_date = [NSDate dateWithTimeInterval:60*60*24*31 sinceDate:start_date];
        }
        
        NSString * start_date_str = [CYFunctionSet convertDateToYearString:start_date];
        NSString * end_date_str = [CYFunctionSet convertDateToYearString:end_date];
        tripCountArray = nil;
        if (!currentDriver) {
            currentDriver = [CurrentUserManager getCurrentContractUser];
        }
        NSString * query = [NSString stringWithFormat: @"SELECT COUNT(*) AS `trip_count`, DATE(`start_time`) AS `trip_date` FROM `trip_history`  WHERE `driver_id` = '%@' AND DATE(`start_time`) >= '%@' AND DATE(`start_time`) <= '%@' GROUP BY DATE(`start_time`) ",currentDriver.data_id, start_date_str,end_date_str];
        
        if (!connector) {
            connector = [[SunshireContractConnector alloc] initWithDelegate:self];
        }
        NSDictionary * uploadpack = @{
                                      @"query": query
                                      };
        [connector sendNormalRequestWithPack:uploadpack andServiceCode:@"special_array" andCustomerTag:1];
    });

}



-(void) dataSocketWillStartRequestWithTag:(NSInteger) tag
                           andCustomerTag:(NSInteger) c_tag{
    [self loadingStart];
    
}
-(void) dataSocketDidGetResponseWithTag:(NSInteger)tag
                         andCustomerTag:(NSInteger) c_tag{
    [self loadingStop];
    
}
-(void) dataSocketErrorWithTag:(NSInteger)tag andMessage: (NSString *) message
                andCustomerTag:(NSInteger) c_tag{
    if (![message isEqualToString:@"NO RESULT FOUND"]) {
        //trip_list = nil;
        [self showAlertWithTittle:@"ERROR" forMessage:message];
    }

    [self reloadTableView];
    
}

-(void) datasocketDidReceiveNormalResponseWithDict:(NSDictionary *) resultDic
                                    andCustomerTag:(NSInteger) c_tag{
    
    if (c_tag == 0) {
        //Handle received trip list
        trip_list = [resultDic objectForKey:@"records"];
        [self reloadTableView];
    }
    if (c_tag == 1) {
        tripCountArray = [resultDic objectForKey:@"records"];
        [self prepareForTripCountDict];
        //[self reloadCanlendar];
        if (self.calendarView.scope == FSCalendarScopeMonth) {
            [self reloadCanlendar];
        }
        if(self.calendarView.scope == FSCalendarScopeWeek){
            //[self prepareForTripCountDict];
            request_count = 0;
            week_content = [[NSMutableDictionary alloc] init];
            for (NSString * key in trip_count_dict.allKeys) {
                [self requestEearningDataWithDateString:key];
            }
        }

    }
    if (c_tag == 2) {
        request_count ++;
        NSArray * daylist = [resultDic objectForKey:@"records"];
        NSDictionary * last_trip = [CYFunctionSet stripNulls:[daylist lastObject]];
        [week_content setValue:daylist forKey:[last_trip objectForKey:@"trip_date"]];
        
        if (request_count == trip_count_dict.count) {
            [self reloadTableView];
        }
    }
    if (c_tag == 3) {
        trip_list = [resultDic objectForKey:@"records"];
        [self reloadTableView];
    }
}

-(void) prepareForTripCountDict{
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
    for (NSDictionary * dict in tripCountArray) {
        NSDictionary * trip_count_data = [CYFunctionSet stripNulls:dict];
        [temp setValue:[trip_count_data objectForKey:@"trip_count"] forKey:[trip_count_data objectForKey:@"trip_date"]];
    }
    trip_count_dict = (NSDictionary *) temp;
}

#pragma mark - loadings
-(void) reloadTableView{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tripView reloadData];
    });
}
-(void) loadingStart{
    dispatch_async(dispatch_get_main_queue(), ^{
        [loadingView startAnimating];
    });
    
}
-(void) loadingStop{
    dispatch_async(dispatch_get_main_queue(), ^{
        [loadingView stopAnimating];
    });
}
-(void) configLoadingView{
    dispatch_async(dispatch_get_main_queue(), ^{
        loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [loadingView setHidesWhenStopped:YES];
        loadingView.frame = CGRectMake(round((self.view.frame.size.width - 25) / 2), round((self.view.frame.size.height - 25) / 2), 25, 25);
        [self.view addSubview:loadingView];
    });
    
}
-(void) showAlertWithTittle:(NSString *) tittle
                 forMessage:(NSString *) message{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // code here
        alert = [UIAlertController
                 alertControllerWithTitle:tittle
                 message:message
                 preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             // Handle further action
                                                             
                                                         }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    });
}

#pragma mark - tableview

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger temp = 0;
    if (self.calendarView.scope == FSCalendarScopeMonth) {
        temp = 1;
    }
    
    if (self.calendarView.scope == FSCalendarScopeWeek) {
        temp = week_content.allKeys.count;
    }
    return temp;
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger temp = 0;
    if (self.calendarView.scope == FSCalendarScopeMonth) {
        temp = trip_list.count;
    }
    
    if (self.calendarView.scope == FSCalendarScopeWeek) {
        NSArray * temp_arr = [week_content objectForKey:[week_content.allKeys objectAtIndex:section]];
        temp = temp_arr.count;
    }
    return temp;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * temp = @"";
    if (self.calendarView.scope == FSCalendarScopeMonth) {
        //temp = trip_list.count;
    }
    
    if (self.calendarView.scope == FSCalendarScopeWeek) {
        temp = [week_content.allKeys objectAtIndex:section];
    }
    return temp;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    trip_pool = [CYFunctionSet stripNulls:[trip_list objectAtIndex:indexPath.row]];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ --- %@",[CYFunctionSet convertDateToShortStr:[CYFunctionSet convertStringToDate:[trip_pool objectForKey:@"start_time"]]],[CYFunctionSet convertDateToShortStr:[CYFunctionSet convertStringToDate:[trip_pool objectForKey:@"end_time"]]]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[trip_pool objectForKey:@"status_str"]];
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    trip_pool = [trip_list objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"calendarToTripDetail" sender:self];
}

-(void) requestEearningDataWithDate:(NSDate *) aDate{
    dispatch_async(dispatch_get_main_queue(), ^{
        currentDriver = [CurrentUserManager getCurrentContractUser];
        trip_list = nil;
        NSString * query = [NSString stringWithFormat:@"SELECT `trip_history`.`idtrip_history`, `trip_history`.`start_time`,`trip_history`.`end_time`,`trip_history`.`mile_age`, `trip_history`.`time_consumed`, `trip_history_status`.`status` AS `status_str` FROM `trip_history` LEFT JOIN `trip_history_status` ON `trip_history`.`status` = `trip_history_status`.`id` WHERE `trip_history`.`driver_id` = '%@' AND `trip_history`.`status` != 0 AND (DATE(`trip_history`.`start_time`) = '%@' OR DATE(`trip_history`.`end_time`) = '%@') ",currentDriver.data_id, [CYFunctionSet convertDateToYearString:aDate],[CYFunctionSet convertDateToYearString:aDate]];
        
        NSDictionary * dict = @{
                                @"query" : query
                                };
        
        if (!connector) {
            connector = [[SunshireContractConnector alloc] initWithDelegate:self];
        }
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_array" andCustomerTag:3];
    });
}
-(void) requestEearningDataWithDateString:(NSString *) dateStr{
    dispatch_async(dispatch_get_main_queue(), ^{
        currentDriver = [CurrentUserManager getCurrentContractUser];
        trip_list = nil;
        NSString * query = [NSString stringWithFormat:@"SELECT `trip_history`.`idtrip_history`, `trip_history`.`start_time`,`trip_history`.`end_time`,`trip_history`.`mile_age`, `trip_history`.`time_consumed`, `trip_history_status`.`status` AS `status_str` FROM `trip_history` LEFT JOIN `trip_history_status` ON `trip_history`.`status` = `trip_history_status`.`id` WHERE `trip_history`.`driver_id` = '%@' AND `trip_history`.`status` != 0 AND (DATE(`trip_history`.`start_time`) = '%@' OR DATE(`trip_history`.`end_time`) = '%@') ",currentDriver.data_id, dateStr,dateStr];
        
        NSDictionary * dict = @{
                                @"query" : query
                                };
        
        if (!connector) {
            connector = [[SunshireContractConnector alloc] initWithDelegate:self];
        }
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_array" andCustomerTag:3];
    });
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"calendarToTripDetail"]) {
        TripDetailViewController * tdvc = [segue destinationViewController];
        tdvc.trip_history_id = [trip_pool objectForKey:@"idtrip_history"];
    }
    
}


@end
