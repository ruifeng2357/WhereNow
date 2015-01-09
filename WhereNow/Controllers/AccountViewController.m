//
//  AccountViewController.m
//  WhereNow
//
//  Created by Xiaoxue Han on 31/07/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "AccountViewController.h"
#import "UserContext.h"
#import "UIManager.h"
#import "BackgroundTaskManager.h"
#import "ServerManager.h"
#import "DeviceCell.h"
#import "AppContext.h"
#import "AppDelegate.h"
#import "EditReceiverIDViewController.h"
#import "ModelManager.h"
#import "ScanManager.h"

#define kPeriodOfBeaconMode        15

@interface AccountViewController () <DeviceCellDelegate, EditReceiverIDDelegate, UIAlertViewDelegate>
{
    bool bIsReceiveMode;
}

@property (nonatomic, retain) NSMutableArray *arrayDevices;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) UILabel *labelReceiverId;
@property (weak, nonatomic) UIButton *buttonStart;

@property (nonatomic, strong) NSMutableArray *arrayBeacons;
@property (nonatomic, retain) NSTimer *timerReceiveSearch;

@property (nonatomic, retain) ScanManager *scanManager;

@end

@implementation AccountViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadData
{
    [self.indicator startAnimating];
    self.tableView.tableFooterView.hidden = NO;
    
    [[ServerManager sharedManager] getRegisteredDeviceList:[UserContext sharedUserContext].sessionId userId:[UserContext sharedUserContext].userId success:^(NSArray *arrayDevices) {
        
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.arrayDevices removeAllObjects];
            for (NSDictionary *info in arrayDevices) {
                NSString *device_token = [info objectForKey:kDeviceListDeviceTokenKey];
                if (device_token == nil)
                    continue;
                if ([device_token isEqual:[AppContext sharedAppContext].cleanDeviceToken])
                    continue;
                [self.arrayDevices addObject:info];
            }
            
            [self.tableView reloadData];
            
            [self.indicator stopAnimating];
            self.tableView.tableFooterView.hidden = YES;
        });
        
    } failure:^(NSString * msg) {
        [self.indicator stopAnimating];
        self.tableView.tableFooterView.hidden = YES;
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.navigationController.tabBarItem setSelectedImage:[UIImage imageNamed:@"accounticon_selected"]];
    
    self.arrayDevices = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCurrentLocationChanged:) name:kCurrentLocationChanged object:nil];
    
    bIsReceiveMode = false;
    self.arrayBeacons = [[NSMutableArray alloc] init];
    
    self.scanManager = [ScanManager sharedScanManager];
    self.scanManager.delegateReceive = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //self.navigationController.navigationBar.barStyle = [UIManager navbarStyle];
    //self.navigationController.navigationBar.tintColor = [UIManager navbarTintColor];
    self.navigationController.navigationBar.titleTextAttributes = [UIManager navbarTitleTextAttributes];
    //self.navigationController.navigationBar.barTintColor = [UIManager navbarBarTintColor];
    
    [self loadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (bIsReceiveMode)
    {
        [self.buttonStart setTitle:@"Start" forState:UIControlStateNormal];
        bIsReceiveMode = NO;
        
        [self.scanManager stopReceiveMode];
    }
}

- (void) didReceiveBeaconFound:(NSMutableArray *)arrBeacons
{
    for (ReceivedBeacon *item in arrBeacons)
    {
        NSLog(@"%d-----------%d------------%d", [item.beacon.minor intValue], [self.labelReceiverId.text intValue], item.isVisible);
        
        [[ServerManager sharedManager] sendReceivedDevices:[NSString stringWithFormat:@"%d", [item.beacon.minor intValue]] receiver: self.labelReceiverId.text isvisible:item.isVisible
        success:^(BOOL bRet) {
        }
        failure:^(NSString * msg) {
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
        return 2;
    else if (section == 1)
        return 1;
    else if (section == 2)
        return 1;
    else if (section == 3)
        return 1;
    else
        return self.arrayDevices.count;
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"INFORMATION";
    else if (section == 1)
        return @"LOGIN";
    else if (section == 3)
        return @"CURRENT LOCATION";
    else if (section == 4)
        return @"REGISTERED DEVICE";
    return @"";
}
*/

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat floatHeight = 44.0f;
    return floatHeight;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"CustomSectionHeader"];
    UILabel* label = (UILabel*) [cell viewWithTag:100];
    UIButton* button = (UIButton*) [cell viewWithTag:101];
    
    switch (section)
    {
        case 0:
            label.text = @"INFORMATION";
            [button setHidden:TRUE];
            break;
        case 1:
            label.text = @"LOGIN";
            [button setHidden:TRUE];
            break;
        case 2:
            label.text = @"ADVANCED-RECEIVER";
            self.buttonStart = (UIButton*) [cell viewWithTag:101];
            [self.buttonStart setHidden:FALSE];
            [self.buttonStart setTitle:@"Start" forState:UIControlStateNormal];
            [self.buttonStart removeTarget:self action:@selector(onStartClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.buttonStart addTarget:self action:@selector(onStartClicked:) forControlEvents:UIControlEventTouchUpInside];
            break;
        case 3:
            label.text = @"CURRENT LOCATION";
            [button setHidden:FALSE];
            [button setTitle:@"Assign Tag" forState:UIControlStateNormal];
            [button removeTarget:self action:@selector(onAssignTag:) forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self action:@selector(onAssignTag:) forControlEvents:UIControlEventTouchUpInside];
            break;
        case 4:
            label.text = @"REGISTERED DEVICE";
            [button setHidden:TRUE];
            break;
        default:
            cell = nil;
    }
    
    return cell;
}

- (void)onStartClicked:(id)sender
{
    if (bIsReceiveMode)
    {
        [self.buttonStart setTitle:@"Start" forState:UIControlStateNormal];
        bIsReceiveMode = NO;
        
        [self.scanManager stopReceiveMode];
    }
    else
    {
        [self.buttonStart setTitle:@"Stop" forState:UIControlStateNormal];
        bIsReceiveMode = YES;
        
        [self.scanManager startReceiveMode];
    }
}

- (void) onTimer:(id)sender
{
}

- (void) onAssignTag:(id)sender
{
    NSString *assignID = [UserContext sharedUserContext].currentLocationId;
    if (assignID.length == 0)
    {
        [self performSegueWithIdentifier:@"toAssignTag" sender:self];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attension"
                                                        message:[NSString stringWithFormat:@"A tag(%d) has already been assigned to this device. \n Do you want to assign another tag?", [[UserContext sharedUserContext].currTagMinor intValue]]
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
    }
    else
    {
        [self performSegueWithIdentifier:@"toAssignTag" sender:self];
    }
}

static UITableViewCell *userCell;
static UITableViewCell *logoutCell;
static UITableViewCell *receiveCell;
static UITableViewCell *locationCell;
static DeviceCell *deviceCell;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            userCell = [tableView dequeueReusableCellWithIdentifier:@"usernamecell"];
            UILabel *labelUserName = (UILabel *)[userCell viewWithTag:101];
            labelUserName.text = [UserContext sharedUserContext].fullName;
        }
        else
        {
            userCell = [tableView dequeueReusableCellWithIdentifier:@"passwordcell"];
        }
        
        return userCell;
    }
    else if (indexPath.section == 1)
    {
        logoutCell = [tableView dequeueReusableCellWithIdentifier:@"logoutcell"];
        UIButton *btnLogout = (UIButton *)[logoutCell viewWithTag:100];
        [btnLogout removeTarget:self action:@selector(onLogout:) forControlEvents:UIControlEventTouchUpInside];
        [btnLogout addTarget:self action:@selector(onLogout:) forControlEvents:UIControlEventTouchUpInside];
        
        return logoutCell;
    }
    else if (indexPath.section == 2 )
    {
        receiveCell = [tableView dequeueReusableCellWithIdentifier:@"receivercell"];
        self.labelReceiverId = (UILabel *)[receiveCell viewWithTag:100];
        [self.labelReceiverId setText:[AppContext sharedAppContext].receiverId];
        
        return receiveCell;
    }
    else if (indexPath.section == 3)
    {
        locationCell = [tableView dequeueReusableCellWithIdentifier:@"locationcell"];
        UILabel *labelLocation = (UILabel *)[locationCell viewWithTag:100];
        labelLocation.text = [UserContext sharedUserContext].currentLocation;
        
        return locationCell;
    }
    else if (indexPath.section == 4)
    {
        deviceCell = [tableView dequeueReusableCellWithIdentifier:@"devicecell"];
        NSDictionary *info = [self.arrayDevices objectAtIndex:indexPath.row];
        deviceCell.delegate = self;
        deviceCell.deviceInfo = info;
        
        return deviceCell;
    }
        
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat floatHeight = 44.0f;
    
    if (indexPath.section == 0)
        floatHeight = userCell.bounds.size.height;
    else if (indexPath.section == 1)
        floatHeight = logoutCell.bounds.size.height;
    else if (indexPath.section == 2)
        floatHeight = receiveCell.bounds.size.height;
    else if (indexPath.section == 3)
        floatHeight = locationCell.bounds.size.height;
    else if (indexPath.section == 4)
        floatHeight = deviceCell.bounds.size.height;
    
    return floatHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            [self performSegueWithIdentifier:@"toReceiverIdEdit" sender:self];
        }
    }
    
    return;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"toReceiverIdEdit"]) {
        EditReceiverIDViewController *controller = [segue destinationViewController];
        controller.delegate = self;
        controller.receiverID = self.labelReceiverId.text;
    }
}

#pragma mark - EditReceiverIDDelegate
- (void) didGetReceiverID:(NSString *) receiverID
{
    [[AppContext sharedAppContext] setReceiverId:receiverID];
    [self.labelReceiverId setText:receiverID];
}


#pragma mark - Actions
- (IBAction)onLogout:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate logout];
}

#pragma mark - DeviceCellDelegate
- (void)didCellRemoved:(DeviceCell *)cell
{
    NSDictionary *info = cell.deviceInfo;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView beginUpdates];
    [self.arrayDevices removeObject:cell.deviceInfo];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    
    
    
    [[ServerManager sharedManager] userLogout:[UserContext sharedUserContext].sessionId userId:[UserContext sharedUserContext].userId tokenId:info[kDeviceListUserDeviceIdKey] isRemote:YES success:^(NSString *tokenId) {
        //
    } failure:^(NSString * msg) {
        //
    }];
}

#pragma mark - notification
- (void)onCurrentLocationChanged:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
    });
}


@end
