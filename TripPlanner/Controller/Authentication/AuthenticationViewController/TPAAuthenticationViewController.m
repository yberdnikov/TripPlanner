//
//  TPAAuthenticationViewController.m
//  TripPlanner
//
//  Created by Yuriy Berdnikov on 3/9/15.
//  Copyright (c) 2015 Yuriy Berdnikov. All rights reserved.
//

#import "TPAAuthenticationViewController.h"

@interface TPAAuthenticationViewController ()

@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation TPAAuthenticationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.signupButton.layer.cornerRadius = 20.0f;
    self.signupButton.layer.borderWidth = 1.0f;
    self.signupButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.loginButton.layer.cornerRadius = 20.0f;
    self.loginButton.layer.borderWidth = 1.0f;
    self.loginButton.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

@end
