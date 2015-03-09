//
//  TPALoginViewController.m
//  TripPlanner
//
//  Created by Yuriy Berdnikov on 3/9/15.
//  Copyright (c) 2015 Yuriy Berdnikov. All rights reserved.
//

#import "TPALoginViewController.h"
#import "NSString+Utilities.h"
#import "UIAlertView+Blocks.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <Parse/Parse.h>

@interface TPALoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation TPALoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Sign In", nil);
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self decorateUIElements];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - UI relater

- (void)decorateUIElements
{
    self.loginButton.layer.cornerRadius = 20.0f;
    self.loginButton.layer.borderWidth = 1.0f;
    self.loginButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.emailTextField.layer.cornerRadius = 5.0f;
    self.emailTextField.layer.borderWidth = 1.0f;
    self.emailTextField.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.passwordTextField.layer.cornerRadius = 5.0f;
    self.passwordTextField.layer.borderWidth = 1.0f;
    self.passwordTextField.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.emailTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, CGRectGetHeight(self.emailTextField.bounds))];
    self.passwordTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, CGRectGetHeight(self.emailTextField.bounds))];
    self.emailTextField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.emailTextField)
        [self.passwordTextField becomeFirstResponder];
    else
        [self.view endEditing:YES];
    
    return YES;
}

#pragma mark - UIButton selectors

- (IBAction)loginButtonPressed:(UIButton *)sender
{
    if (![self.emailTextField.text isValidEmailFormat])
    {
        [UIAlertView showErrorWithMessage:NSLocalizedString(@"Please enter valid email address", nil) handler:nil];
        return;
    }
    
    if (![self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length)
    {
        [UIAlertView showErrorWithMessage:NSLocalizedString(@"Please enter valid password", nil) handler:nil];
        return;
    }
    
    [self.view endEditing:YES];
    
    [self loginUser];
}

#pragma mark - Server API communication

- (void)loginUser
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    __weak __typeof__(self) weakSelf = self;
    [PFUser logInWithUsernameInBackground:self.emailTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error) {
        
        [SVProgressHUD dismiss];
        
        if (error)
        {
            NSString *errorString = error.userInfo ? [error.userInfo objectForKey:@"error"] : error.localizedDescription;
            [UIAlertView showErrorWithMessage:errorString.length ? errorString : error.localizedDescription handler:nil];
            return;
        }
        
        [weakSelf.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}

@end
