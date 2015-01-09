//
 //  LoginViewController.m
//  WhereNow
//
//  Created by Xiaoxue Han on 30/07/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "LoginViewController.h"
#import "UserContext.h"
#import "NSString+WhereNow.h"
#import "SVProgressHUD+WhereNow.h"
#import "ServerManager.h"
#import "ModelManager.h"
#import "BackgroundTaskManager.h"
#import "AdvertisingManager.h"
#import "AppContext.h"

#define verticalGap 3.0
#define ktDefaultLoginTimeInterval 20.0

typedef enum
{
    LoginStateLoggingIn,
    LoginStateForgotUsername,
    LoginStateForgotPassword
} LoginState;

enum  {
    INPUT_NAME = 0,
    INPUT_NAME_EXISTS,
    INPUT_PASSWORD,
    INPUT_PASSWORD_TOO_SHORT,
    INPUT_EMAIL,
    INPUT_EMAIL_INVALID,
    INPUT_CONNECTION_PROBLEM,
    INPUT_OK
};

@interface LoginViewController () {
    LoginState loginState;
    UIResponder *currentResponder;
    
    NSString *_inputUserName;
    NSString *_inputUserPassword;
    NSString *_inputUserEmail;
}
@property (weak, nonatomic) IBOutlet UIImageView *imgLogo;
@property (weak, nonatomic) IBOutlet UIView *viewUserName;
@property (weak, nonatomic) IBOutlet UITextField *txtUserName;
@property (weak, nonatomic) IBOutlet UIView *viewEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UIView *viewPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIView *viewForgot;
@property (weak, nonatomic) IBOutlet UIButton *btnForgotUserName;
@property (weak, nonatomic) IBOutlet UIButton *btnForgotPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnForgotBack;
@property (weak, nonatomic) IBOutlet UIImageView *imgForgotDivider;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailTopConstraint;

- (IBAction)onLogin:(id)sender;
- (IBAction)onForgotUserName:(id)sender;
- (IBAction)onForgotPassword:(id)sender;
- (IBAction)onBack:(id)sender;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.viewUserName.backgroundColor = [UIColor whiteColor];
    self.viewUserName.layer.cornerRadius = 5.0;
    self.viewUserName.layer.borderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor;
    self.viewUserName.layer.borderWidth = 1.0f;
    self.viewPassword.backgroundColor = [UIColor whiteColor];
    self.viewPassword.layer.cornerRadius = 5.0;
    self.viewPassword.layer.borderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor;
    self.viewPassword.layer.borderWidth = 1.0f;
    self.viewEmail.backgroundColor = [UIColor whiteColor];
    self.viewEmail.layer.cornerRadius = 5.0;
    self.viewEmail.layer.borderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor;
    self.viewEmail.layer.borderWidth = 1.0f;
    self.btnLogin.backgroundColor = [UIColor colorWithRed:0.21 green:0.68 blue:0.9 alpha:1.0];
    self.btnLogin.layer.cornerRadius = 5.0;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap:)];
    [self.view addGestureRecognizer:tap];
    
    // login when last user logged in already
    if ([UserContext sharedUserContext].isLastLoggedin)
    {
        // set user name
        if (![[UserContext sharedUserContext].userName isEqualToString:@""])
            self.txtUserName.text = [UserContext sharedUserContext].userName;
        
        // login
        SHOW_PROGRESS(@"Please Wait");
        NSString *deviceName = [self getDeviceName];
        [[ServerManager sharedManager] loginUserV2WithUserName:[UserContext sharedUserContext].userName pwd:[UserContext sharedUserContext].password success:^(NSString *sessionId, NSString *userId, NSString *fullname)
         {
             [SVProgressHUD dismiss];
             
             // save status
             //[UserContext sharedUserContext].userName = self.usernameTextField.text;
             //[UserContext sharedUserContext].password = self.passwordTextField.text;
             [UserContext sharedUserContext].isLastLoggedin = YES;
             [UserContext sharedUserContext].sessionId = sessionId;
             [UserContext sharedUserContext].userId = userId;
             [UserContext sharedUserContext].isLoggedIn = YES;
             [UserContext sharedUserContext].fullName = fullname;
             
             // start scanning
             [[BackgroundTaskManager sharedManager] startScanning];
             
             // start advertising
             [[AdvertisingManager sharedInstance] start];
             
             [self performSegueWithIdentifier:@"goMain" sender:self];
             
             // update token
             if ([AppContext sharedAppContext].cleanDeviceToken != nil && [[AppContext sharedAppContext].cleanDeviceToken length] > 0)
             {
                 [[ServerManager sharedManager] updateDeviceToken:[AppContext sharedAppContext].cleanDeviceToken sessionId:sessionId userId:userId deviceName:deviceName success:^(NSString *tokenId, NSString *locname, NSString *locid) {
                     NSLog(@"Register device token success! token id = %@", tokenId);
                     [UserContext sharedUserContext].tokenId = tokenId;
                     [UserContext sharedUserContext].currentLocation = locname;
                     [UserContext sharedUserContext].currentLocationId = locid;
                     
                     /****************/
                     [[ModelManager sharedManager] retrieveEquipmentsWithHasBeacon:YES];
                     /****************/
                     
                 } failure:^(NSString * msg) {
                     NSLog(@"Register device token failed : %@", msg);
                 }];
             }
             
             // update Current Location Name, ID
             if ([UserContext sharedUserContext].tokenId != nil)
             {
             }
             
         } failure:^(NSString *msg) {
             HIDE_PROGRESS_WITH_FAILURE(([NSString stringWithFormat:@"Failure : %@", msg]));
         }];
        
    }
    else
    {
        // set user name
        if (![[UserContext sharedUserContext].userName isEqualToString:@""])
            self.txtUserName.text = [UserContext sharedUserContext].userName;
    }
    
#ifdef DEBUG
    self.txtUserName.text = @"testuser50";
    self.txtPassword.text = @"testuser1!";
#endif

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
 
}

- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardShowing:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardHiding:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    self.txtPassword.text = @"";
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

# pragma mark Gesture selector
- (void)backgroundTap:(UITapGestureRecognizer *)backgroundTap {
    if(currentResponder){
        [currentResponder resignFirstResponder];
    }
}

#pragma mark Navigation methods between states of the Login screen

- (void)goInto
{
    //[self goBackToLogin:nil];
    [self performSegueWithIdentifier:@"tomain" sender:self];
}

#pragma mark -check validation
- (void) updateAndCleanInput {
    _inputUserName = [self.txtUserName.text trimmed];
    self.txtUserName.text = _inputUserName;
    
    _inputUserEmail = [[self.txtEmail.text trimmed] lowercaseStringWithLocale:[NSLocale currentLocale]];
    self.txtEmail.text = _inputUserEmail;
    
    _inputUserPassword = self.txtPassword.text;
}


- (int) getInputType {
    int nRet;
    
    [self updateAndCleanInput];
    
    switch (loginState) {
        case LoginStateForgotPassword:
            nRet = [self validateForgotPassword];
            break;
        case LoginStateForgotUsername:
            nRet = [self validateForgotUsername];
            break;
        case LoginStateLoggingIn:
            nRet = [self validateLoggingIn];
            break;
    }
    return nRet;
}

- (int) validateForgotPassword {
    if (_inputUserEmail.length == 0) {
        return INPUT_EMAIL;
    }
    else if (![_inputUserEmail isValidEmail]) {
        return INPUT_EMAIL_INVALID;
    }
    return INPUT_OK;
}

- (int) validateForgotUsername {
    if (_inputUserEmail.length == 0) {
        return INPUT_EMAIL;
    }
    else if (![_inputUserEmail isValidEmail]) {
        return INPUT_EMAIL_INVALID;
    }
    return INPUT_OK;
}

- (int)validateLoggingIn {
    int nRet;
    if (_inputUserName.length == 0) {
        nRet = INPUT_NAME;
    } else {
        nRet = INPUT_OK;
    }
    return nRet;
}

- (void) showAlertMessage:(int) type {
    NSString* strTitle;
    switch (type) {
        case INPUT_CONNECTION_PROBLEM:
            strTitle = @"We're sorry, there is a network issue. Please try again later";
            break;
        case INPUT_NAME:
            strTitle = loginState == LoginStateLoggingIn ? @"Please enter your user name" : @"Please enter a name";
            break;
        case INPUT_NAME_EXISTS:
            strTitle = @"That username is taken, please choose another";
            break;
        case INPUT_PASSWORD:
            strTitle = loginState == LoginStateLoggingIn ? @"Please enter your password" : @"Please enter a password";
            break;
        case INPUT_PASSWORD_TOO_SHORT:
            strTitle = @"That password is too short, it must be at least 6 characters";
            break;
        case INPUT_EMAIL:
            strTitle = @"Please enter your email address";
            break;
        case INPUT_EMAIL_INVALID:
            strTitle = @"That email address is not valid";
            break;
        default:
            strTitle = @"";
            break;
    }
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:strTitle message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


#pragma mark Login

- (IBAction)onForgotUserName:(id)sender {
    [self leaveLoginState];
    
    loginState = LoginStateForgotUsername;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.viewUserName.hidden = YES;
        self.viewPassword.hidden = YES;
        self.viewEmail.hidden = NO;
        self.viewForgot.hidden = YES;
        self.btnForgotBack.hidden = NO;
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        [UIView setAnimationsEnabled:NO];
        
        [self.btnLogin setTitle:@"FIND USERNAME" forState:UIControlStateNormal];
        
        [UIView setAnimationsEnabled:YES];
        
        [self.btnForgotBack addTarget:self action:@selector(exitForgotUsername:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnLogin addTarget:self action:@selector(getUsername) forControlEvents:UIControlEventTouchUpInside];
        
    }];
}

- (IBAction)onForgotPassword:(id)sender {
    [self leaveLoginState];
    
    loginState = LoginStateForgotUsername;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.viewUserName.hidden = YES;
        self.viewPassword.hidden = YES;
        self.viewEmail.hidden = NO;
        self.viewForgot.hidden = YES;
        self.btnForgotBack.hidden = NO;
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        [UIView setAnimationsEnabled:NO];
        
        [self.btnLogin setTitle:@"RESET PASSWORD" forState:UIControlStateNormal];
        
        [UIView setAnimationsEnabled:YES];
        
        [self.btnForgotBack addTarget:self action:@selector(exitForgotPassword:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnLogin addTarget:self action:@selector(resetPassword) forControlEvents:UIControlEventTouchUpInside];
        
    }];
}

- (IBAction)onBack:(id)sender {
}

- (IBAction)onLogin:(id)sender {
    if (currentResponder) {
        [currentResponder resignFirstResponder];
    }
    
    int nInput = [self getInputType];
    
    if (nInput != INPUT_OK) {
        [self showAlertMessage:nInput];
    } else {
        SHOW_PROGRESS(@"Please Wait");
        NSString *deviceName = [self getDeviceName];
        [[ServerManager sharedManager] loginUserV2WithUserName:_inputUserName pwd:_inputUserPassword success:^(NSString *sessionId, NSString *userId, NSString *fullname)
         {
             [SVProgressHUD dismiss];
             
             NSString *oldUser = [UserContext sharedUserContext].userName;
             if ([oldUser isEqualToString:self.txtUserName.text])
             {
                 //
             }
             else
             {
                 if (![oldUser isEqualToString:@""])
                 {
                     // remove favorites/recents
                     NSMutableArray *arrayGenerics = [[ModelManager sharedManager] retrieveGenerics];
                     for (Generic *generic in arrayGenerics) {
                         generic.isfavorites = @(NO);
                         generic.isrecent = @(NO);
                     }
                     
                     NSMutableArray *arrayEquipments = [[ModelManager sharedManager] retrieveEquipmentsWithHasBeacon:YES];
                     for (Equipment *equipment in arrayEquipments) {
                         equipment.isfavorites = @(NO);
                         equipment.isrecent = @(NO);
                     }
                     
                     [[ModelManager sharedManager] saveContext];
                 }
             }
             
             // save status
             [UserContext sharedUserContext].userName = self.txtUserName.text;
             [UserContext sharedUserContext].password = self.txtPassword.text;
             [UserContext sharedUserContext].isLastLoggedin = YES;
             [UserContext sharedUserContext].sessionId = sessionId;
             [UserContext sharedUserContext].userId = userId;
             [UserContext sharedUserContext].isLoggedIn = YES;
             [UserContext sharedUserContext].fullName = fullname;
             
             // start scanning
             [[BackgroundTaskManager sharedManager] startScanning];
             
             // start advertising
             [[AdvertisingManager sharedInstance] start];
             
             [self performSegueWithIdentifier:@"goMain" sender:self];
             
             // update token
             if ([AppContext sharedAppContext].cleanDeviceToken != nil && [[AppContext sharedAppContext].cleanDeviceToken length] > 0)
             {
                 [[ServerManager sharedManager] updateDeviceToken:[AppContext sharedAppContext].cleanDeviceToken sessionId:sessionId userId:userId deviceName:deviceName success:^(NSString *tokenId, NSString *locname, NSString *locid) {
                     NSLog(@"Register device token success! token id = %@", tokenId);
                     [UserContext sharedUserContext].tokenId = tokenId;
                     [UserContext sharedUserContext].currentLocation = locname;
                     [UserContext sharedUserContext].currentLocationId = locid;
                 } failure:^(NSString * msg) {
                     NSLog(@"Register device token failed : %@", msg);
                 }];
             }
             
         } failure:^(NSString *msg) {
             HIDE_PROGRESS_WITH_FAILURE(([NSString stringWithFormat:@"%@", msg]));
         }];
    }
}

- (void)prepareForEnteringLoginState {
    loginState = LoginStateLoggingIn;
}

- (void)configureLoginState {
    int nOldState = loginState;
    loginState = LoginStateLoggingIn;
    
    [self reset];
    
    //Without these there is an unwanted fade animation
    [UIView setAnimationsEnabled:NO];
    
    [self.btnLogin setTitle:@"LOGIN" forState:UIControlStateNormal];
    [UIView setAnimationsEnabled:YES];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.viewUserName.hidden = NO;
        self.viewPassword.hidden = NO;
        self.viewEmail.hidden = YES;
        self.viewForgot.hidden = NO;
        self.btnForgotBack.hidden = YES;
    } completion:^(BOOL finished) {
    }];
    
    if (nOldState == LoginStateForgotUsername)
    {
        [self.btnForgotBack removeTarget:self action:@selector(exitForgotUsername:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnLogin removeTarget:self action:@selector(onForgotUserName:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if (nOldState == LoginStateForgotPassword)
    {
        [self.btnForgotBack removeTarget:self action:@selector(exitForgotPassword:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnLogin removeTarget:self action:@selector(onForgotPassword:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.btnForgotUserName addTarget:self action:@selector(onForgotUserName:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnForgotPassword addTarget:self action:@selector(onForgotPassword:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnLogin addTarget:self action:@selector(onLogin:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)leaveLoginState {
    [self.btnForgotUserName removeTarget:self action:@selector(onForgotUserName:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnForgotPassword removeTarget:self action:@selector(onForgotPassword:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnLogin removeTarget:self action:@selector(onLogin:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark Forgot Username

- (void)getUsername {
    if (currentResponder) {
        [currentResponder resignFirstResponder];
    }
    int nInput = [self getInputType];
    
    if (nInput != INPUT_OK) {
        [self showAlertMessage:nInput];
    } else {
        SHOW_PROGRESS(@"Please Wait");
        [[ServerManager sharedManager] forgotUsernameWithEmail:self.txtEmail.text success:^{
            HIDE_PROGRESS_WITH_SUCCESS(@"Sent a mail");
        } failure:^(NSString *msg) {
            HIDE_PROGRESS_WITH_FAILURE(([NSString stringWithFormat:@"Failure : %@", msg]));
        }];
    }
    
}

- (void)exitForgotUsername:(id)sender {
    [self prepareForEnteringLoginState];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.viewUserName.hidden = NO;
        self.viewPassword.hidden = NO;
        self.viewEmail.hidden = YES;
        self.viewForgot.hidden = YES;
        self.btnForgotBack.hidden = YES;
        
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        [self configureLoginState];
    }];
    
}

#pragma mark Forgot / Rest Password

- (void)resetPassword {
    if (currentResponder) {
        [currentResponder resignFirstResponder];
    }
    int nInput = [self getInputType];
    
    if (nInput != INPUT_OK) {
        [self showAlertMessage:nInput];
    } else {
        
        SHOW_PROGRESS(@"Please Wait");
        [[ServerManager sharedManager] forgotPasswordWithEmail:self.txtEmail.text success:^{
            HIDE_PROGRESS_WITH_SUCCESS(@"Sent a mail");
        } failure:^(NSString *msg) {
            HIDE_PROGRESS_WITH_FAILURE(([NSString stringWithFormat:@"Failure : %@", msg]));
        }];
        
    }
}

- (void)exitForgotPassword:(id)sender {
    [self prepareForEnteringLoginState];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.viewUserName.hidden = NO;
        self.viewPassword.hidden = NO;
        self.viewEmail.hidden = YES;
        self.viewForgot.hidden = YES;
        self.btnForgotBack.hidden = YES;
        
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        [self configureLoginState];
    }];
}

#pragma mark -
#pragma mark UITextFieldDelegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    currentResponder = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    currentResponder = nil;
}


- (void)reset
{
    if (loginState == LoginStateLoggingIn && ![[UserContext sharedUserContext].userName isEqualToString:@""])
    {
        self.txtUserName.text = [UserContext sharedUserContext].userName;
    }
    
    self.txtPassword.text = @"";
    self.txtEmail.text = @"";
}

#pragma mark Keyboard Methods

- (void)keyboardShowing:(NSNotification *)note
{
    NSNumber *duration = note.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    
    if ([self isPhoneDevice])
    {
        self.loginTopConstraint.constant = 60;
        self.emailTopConstraint.constant = 87;
    }
    else
    {
        self.loginTopConstraint.constant = 100;
        self.emailTopConstraint.constant = 132;
    }
    
    [UIView animateWithDuration:duration.floatValue animations:^{
        self.imgLogo.alpha = 0.0;
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardHiding:(NSNotification *)note
{
    NSNumber *duration = note.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    
    if ( [self isPhoneDevice] )
    {
        self.loginTopConstraint.constant = 215;
        self.emailTopConstraint.constant = 242;
    }
    else
    {
        self.loginTopConstraint.constant = 320;
        self.emailTopConstraint.constant = 352;
    }
    
    [UIView animateWithDuration:duration.floatValue animations:^{
        self.imgLogo.alpha = 1.0;
        [self.view layoutIfNeeded];
    }];
    
}

#pragma mark - device name utility

- (NSString *)getDeviceName
{
    NSString *deviceName = [[UIDevice currentDevice] name];
    return deviceName;
}

- (BOOL)isPhoneDevice
{
    if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone )
        return YES;
    else
        return NO;
    
    return YES;
}

@end
