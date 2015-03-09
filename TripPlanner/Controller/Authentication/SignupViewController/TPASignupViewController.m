//
//  TPASignupViewController.m
//  TripPlanner
//
//  Created by Yuriy Berdnikov on 3/9/15.
//  Copyright (c) 2015 Yuriy Berdnikov. All rights reserved.
//

#import "TPASignupViewController.h"
#import <TPKeyboardAvoidingScrollView.h>
#import "NSString+Utilities.h"
#import "UIAlertView+Blocks.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <Parse/Parse.h>

@interface TPASignupViewController ()

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;

@end

@implementation TPASignupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Sign Up", nil);
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self decorateUIElements];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - UI Setup

- (void)decorateUIElements
{
    self.signupButton.layer.cornerRadius = 20.0f;
    self.signupButton.layer.borderWidth = 1.0f;
    self.signupButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    [@[self.passwordTextField, self.emailTextField, self.usernameTextField] enumerateObjectsUsingBlock:^(UITextField *textField, NSUInteger idx, BOOL *stop) {
        
        textField.layer.cornerRadius = 5.0f;
        textField.layer.borderWidth = 1.0f;
        textField.layer.borderColor = [UIColor whiteColor].CGColor;
        
        textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, CGRectGetHeight(textField.bounds))];
        textField.leftViewMode = UITextFieldViewModeAlways;
    }];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.passwordTextField)
        [self.view endEditing:YES];
    else
        [self.contentScrollView focusNextTextField];
    
    return YES;
}

#pragma mark - UIButton selectors

- (IBAction)signupButtonPressed:(UIButton *)sender
{
    if (![self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length)
    {
        [UIAlertView showErrorWithMessage:NSLocalizedString(@"Please enter valid username", nil) handler:nil];
        return;
    }
    
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
    
    [self signupUser];
}

#pragma mark - Server API communication

- (void)signupUser
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    PFUser *user = [PFUser user];
    user[@"name"] = self.usernameTextField.text;
    user.username = self.emailTextField.text;
    user.email = self.emailTextField.text;
    user.password = self.passwordTextField.text;
    
    __weak __typeof__(self) weakSelf = self;
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
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
