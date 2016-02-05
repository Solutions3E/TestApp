//
//  LaunchViewController.m
//  Test
//
//  Created by Admin on 05/02/16.
//  Copyright © 2016 3E. All rights reserved.
//

#import "LaunchViewController.h"

@interface LaunchViewController ()

- (IBAction)btnAction_signUp:(id)sender;
- (IBAction)btnAction_signIn:(id)sender;

@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    if ([[appDelegate().defaults objectForKey:k_Auth]isEqualToString:@"1"])
    {
        [self performSegueWithIdentifier:@"product" sender:nil];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)btnAction_signUp:(id)sender {
    [self performSegueWithIdentifier:@"SignUp" sender:nil];
}

- (IBAction)btnAction_signIn:(id)sender {
    [self performSegueWithIdentifier:@"SignIn" sender:nil];
}

@end
