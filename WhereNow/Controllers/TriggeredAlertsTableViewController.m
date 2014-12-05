//
//  TriggeredAlertsTableViewController.m
//  WhereNow
//
//  Created by Xiaoxue Han on 21/09/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "TriggeredAlertsTableViewController.h"
#import "ModelManager.h"
#import "ServerManager.h"
#import "Common.h"

@interface TriggeredAlertsTableViewController ()

@property (nonatomic, retain) NSMutableArray *arrayTriggeredAlerts;

@end

@implementation TriggeredAlertsTableViewController

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
    self.arrayTriggeredAlerts = [[NSMutableArray alloc] init];
    NSMutableArray *triggeredAlerts = [[ModelManager sharedManager] retrieveTriggeredAlerts];
    for (TriggeredAlert *triggeredAlert in triggeredAlerts) {
        TriggeredAlertObject *obj = [[TriggeredAlertObject alloc] init];
        obj.triggered_alert = triggeredAlert;
        Alert *alert = [[ModelManager sharedManager] alertById:[triggeredAlert.alert_id intValue]];
        if (alert != nil)
        {
            Equipment *equipment = [[ModelManager sharedManager] equipmentById:[alert.equipment_id intValue]];
            if (equipment != nil)
            {
                obj.alert = alert;
                obj.equipment = equipment;
                
                [self.arrayTriggeredAlerts addObject:obj];
            }
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // back button
  
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(onDone:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChanged:) name:kTriggeredAlertChanged object:nil];
    
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.arrayTriggeredAlerts.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"alertcell" forIndexPath:indexPath];
    
    // Configure the cell...
    UILabel *labelType = (UILabel *)[cell viewWithTag:100];
    UIImageView *ivEquipment = (UIImageView *)[cell viewWithTag:101];
    UILabel *lblModelNo = (UILabel *)[cell viewWithTag:102];
    UILabel *lblSerialNo = (UILabel *)[cell viewWithTag:103];
    UILabel *lblLevel = (UILabel *)[cell viewWithTag:104];
    UILabel *lblLocation = (UILabel *)[cell viewWithTag:105];
    UILabel *lblNote1 = (UILabel *)[cell viewWithTag:106];
    UILabel *lblNote2 = (UILabel *)[cell viewWithTag:107];
    
    TriggeredAlertObject *obj = [self.arrayTriggeredAlerts objectAtIndex:indexPath.row];
    
    // equipment
    [[ServerManager sharedManager] setImageContent:ivEquipment urlString:obj.equipment.equipment_file_location success:^(UIImage *image) {
        [self.view layoutIfNeeded];
    }];
    lblModelNo.text = obj.equipment.model_name_no;
    lblSerialNo.text = [NSString stringWithFormat:@"SN %@", obj.equipment.serial_no];
    
    // alert type
    labelType.text = obj.alert.alert_type;
    
    // alert
    if ([obj.alert.alert_type isEqualToString:@"Current Alerts"])
    {
        if (obj.alert.current_location_parent_name != nil && ![obj.alert.current_location_parent_name isEqualToString:@""])
            lblLevel.text = obj.alert.current_location_parent_name;
        else
            lblLevel.text = @"";
        lblLocation.text = obj.alert.current_location_name;
        lblNote1.text = @"exceeds time limit";
        lblNote2.text = [NSString stringWithFormat:@"return to %@", obj.alert.location_name];
    }
    else if ([obj.alert.alert_type isEqualToString:@"Time Alerts"])
    {
        if (obj.alert.location_parent_name != nil && ![obj.alert.location_parent_name isEqualToString:@""])
            lblLevel.text = obj.alert.location_parent_name;
        else
            lblLevel.text = @"";
        lblLocation.text = obj.alert.location_name;
        lblNote1.text = [NSString stringWithFormat:@"alerts after %@", obj.alert.trigger_string];
        lblNote2.text = [NSString stringWithFormat:@"alerts %d user", [obj.alert.user_count intValue]];
    }
    else
    {
        if (obj.alert.location_parent_name != nil && ![obj.alert.location_parent_name isEqualToString:@""])
            lblLevel.text = obj.alert.location_parent_name;
        else
            lblLevel.text = @"";
        lblLocation.text = obj.alert.location_name;
        lblNote1.text = [NSString stringWithFormat:@"alerts %d user", [obj.alert.user_count intValue]];
        lblNote2.text = @"";
    }
    

    
    return cell;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)onDone:(id)sender
{
    for (TriggeredAlertObject *obj in self.arrayTriggeredAlerts) {
        obj.triggered_alert.opened = @(YES);
        obj.triggered_alert.opened_date = [Common date2str:[NSDate date] withFormat:DATE_FORMAT];
    }
    [[ModelManager sharedManager] saveContext];
    
    if (self.delegate)
        [self.delegate didTriggeredAlertsDone:self];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onChanged:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^() {

        [self loadData];
        [self.tableView reloadData];
    });
}

@end

@implementation TriggeredAlertObject

//

@end
