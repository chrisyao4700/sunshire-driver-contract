//
//  SunshireMessengerViewController.m
//  SunshireDriver
//
//  Created by 姚远 on 10/19/16.
//  Copyright © 2016 SunshireShuttle. All rights reserved.
//

#import "SunshireMessengerViewController.h"
#import "SunshireMessengerDispatchCell.h"
#import "SunshireMessengerCustomerCellTableViewCell.h"
#import "CYFunctionSet.h"
#import "CurrentUserManager.h"

@interface SunshireMessengerViewController ()

@end

@implementation SunshireMessengerViewController{
    NSTimer * topTitleTimer;
    UIAlertController * alert;
    UIActivityIndicatorView * loadingView;
    
    NSDictionary * dataPool;
    
    
    NSArray * message_list;
    
    SS_CONTRACT_USER * driver_token;
    
    SunshireContractConnector * connector;
    
    TextEditorViewController * tevc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshPropertyList:)];
    self.navigationItem.rightBarButtonItem = anotherButton;

    
     self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_image.png"]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self requestTripMessageHistory];
}
- (IBAction)didClickSend:(id)sender {
    [self performTextEditorWithKey:@"New message" andValue:@""];
}
-(IBAction)refreshPropertyList:(id)sender{
    [self requestTripMessageHistory];
}

-(void) requestTripMessageHistory{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!connector) {
            connector = [[SunshireContractConnector alloc] initWithDelegate:self];
        }
        
        NSDictionary * dict =@{
                               
                               @"product_id": self.contact_id
                               };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"find_trip_message" andCustomerTag:1];
    });
}

-(void) requestSendTripMessage:(NSString *) msg{
    dispatch_async(dispatch_get_main_queue(), ^{
    
        if (!connector) {
            connector = [[SunshireContractConnector alloc] initWithDelegate:self];
        }
        if (!driver_token) {
            driver_token = [CurrentUserManager getCurrentContractUser];
        }
        
        NSDictionary * dict =@{
                               
                               @"product_id": self.contact_id,
                               @"message":msg,
                               @"cby":driver_token.data_id
                               };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"send_trip_message" andCustomerTag:2];
    });
}
/*TableView */
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return message_list.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    dataPool = [CYFunctionSet stripNulls:[message_list objectAtIndex:indexPath.row]];
    NSString * direction = [dataPool objectForKey:@"direction"];
    if ((!direction) || [direction isEqualToString:@""]) {
        return nil;
    }
    if ([direction isEqualToString:@"in"]) {
        //Handle Customer
        SunshireMessengerCustomerCellTableViewCell * cCell =  (SunshireMessengerCustomerCellTableViewCell * )[tableView dequeueReusableCellWithIdentifier:@"customerCell"];
        cCell.userInteractionEnabled = YES;
        cCell.cellImageView.image = [UIImage imageNamed:@"icon_customer"];
        cCell.messageTextView.text = [dataPool objectForKey:@"message_content"];
        cCell.messageTextView.userInteractionEnabled = YES;
        cCell.messageTextView.editable = NO;
        cCell.dateLabel.text =[dataPool objectForKey:@"reg_date"];
        
        return cCell;
    }
    
    if ([direction isEqualToString:@"out"]) {
        //Handle Dispatch
        SunshireMessengerDispatchCell * dCell = (SunshireMessengerDispatchCell *)[tableView dequeueReusableCellWithIdentifier:@"dispatchCell"];
        dCell.userInteractionEnabled =YES;
        dCell.cellImageView.image = [UIImage imageNamed:@"icon_manager"];
        NSString * staff_type = [dataPool objectForKey:@"staff_type"];
        
        if ([staff_type isEqualToString:@"DRIVER"]) {
            dCell.cellImageView.image = [UIImage imageNamed:@"icon_driver"];
        }
        if ([staff_type isEqualToString:@"DISPATCH"]) {
            dCell.cellImageView.image = [UIImage imageNamed:@"icon_dispatch"];
        }
        
        dCell.messageTextView.text = [dataPool objectForKey:@"message_content"];
        dCell.messageTextView.userInteractionEnabled = YES;
        dCell.messageTextView.editable = NO;
        dCell.dateLabel.text =[dataPool objectForKey:@"reg_date"];
        return dCell;
    }
    
    return nil;
}

/* Order Handler */
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
        [self showAlertWithTittle:@"ERROR" forMessage:message];
    }
}
-(void)datasocketDidReceiveNormalResponseWithDict:(NSDictionary *)resultDic andCustomerTag:(NSInteger)c_tag{
    if (c_tag == 1) {
        //FIND
        message_list = [resultDic objectForKey:@"records"];
        [self reloadTableView];
    }
    if (c_tag == 2) {
        //SEND
        [self requestTripMessageHistory];
    }

}

/* Loading view & alerts */
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

-(void) reloadTableView{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messengerTableView reloadData];
    });
}
-(void) enableOrderInfoView{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.messengerTableView.userInteractionEnabled = YES;
        
    });
}
-(void) disableOrderInfoView{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.messengerTableView.userInteractionEnabled = NO;
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
-(void) configLoadingView{
    dispatch_async(dispatch_get_main_queue(), ^{
        loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [loadingView setHidesWhenStopped:YES];
        loadingView.frame = CGRectMake(round((self.view.frame.size.width - 25) / 2), round((self.view.frame.size.height - 25) / 2), 25, 25);
        [self.view addSubview:loadingView];
    });
    
}
/*Title views */

-(void) updateTitle{
    dispatch_async(dispatch_get_main_queue(), ^{
        topTitleTimer = [NSTimer scheduledTimerWithTimeInterval:2
                                                         target:self
                                                       selector:@selector(timerDidFire:)
                                                       userInfo:nil
                                                        repeats:NO];
    });
}
-(void) setDefaultTopBar{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setTopBarTitle:@"Messenger"];
    });
}
- (void) timerDidFire:(NSTimer *)timer{
    [self setDefaultTopBar];
}
-(void) setTopBarTitle:(NSString *) title{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationController.topViewController.title = title;
    });
}


/*Text Editor */
-(void) performTextEditorWithKey:(NSString *) key
                        andValue:(NSString *) value{
    if (!tevc) {
        tevc =[[TextEditorViewController alloc] init];
    }
    tevc.key = key;
    tevc.orgValue = value;
    tevc.delegate = self;
    [self showDetailViewController:tevc sender:self];
}
-(void)didCancelTextSelectingForKey:(NSString *)key{
    [self setTopBarTitle:@"Message canceled..."];
    [self updateTitle];
}
-(void)didSaveTextForKey:(NSString *)key andText:(NSString *)value{
    //[messengerHandler sendMessageWithTripID:self.contact_id forMessage:value];
    [self requestSendTripMessage:value];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
