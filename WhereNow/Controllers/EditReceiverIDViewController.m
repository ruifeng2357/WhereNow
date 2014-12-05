//
//  EditReceiverIDViewController.m
//  WhereNow
//
//  Created by Admin on 12/2/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "EditReceiverIDViewController.h"
#import "UIManager.h"

@interface EditReceiverIDViewController () <UITextFieldDelegate>
{
    UIBarButtonItem *_backButton;
}
@property (strong, nonatomic) IBOutlet UITextField *txtReceierID;

@end


@implementation EditReceiverIDViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _backButton = [UIManager defaultBackButton:self action:@selector(onBack:)];
    self.navigationItem.leftBarButtonItem = _backButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.txtReceierID setText:self.receiverID];
    [self.txtReceierID becomeFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)onBack:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:TRUE];
}

- (IBAction)onChangeID:(id)sender {
    
    if (self.delegate) {
        [self.delegate didGetReceiverID:self.txtReceierID.text];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark UITextFieldDelegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self onChangeID:nil];
    return YES;
}



@end
