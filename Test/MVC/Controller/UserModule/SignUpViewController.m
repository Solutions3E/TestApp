//
//  SignUpViewController.m
//  Test
//
//  Created by Admin on 05/02/16.
//  Copyright © 2016 3E. All rights reserved.
//

#import "SignUpViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface SignUpViewController ()

@property (weak, nonatomic) IBOutlet UITextField *txtfield_name;
@property (weak, nonatomic) IBOutlet UITextField *txtfield_email;
@property (weak, nonatomic) IBOutlet UITextField *txtfield_password;

- (IBAction)btnActionBack:(id)sender;
- (IBAction)btnAction_facebookSignUp:(id)sender;
- (IBAction)btnAction_signUp:(id)sender;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraints;
@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.heightConstraints.constant = 30;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidLayoutSubviews{
    
    // Add bottom border to textfield
    [Util addBottomLine:self.txtfield_name withPlaceholder:@"NAME"];
    [Util addBottomLine:self.txtfield_email withPlaceholder:@"EMAIL"];
    [Util addBottomLine:self.txtfield_password withPlaceholder:@"PASSWORD"];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return  YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)btnActionBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnAction_facebookSignUp:(id)sender {
    [self facebookSignUp];
    
    appDelegate().hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    appDelegate().hud.removeFromSuperViewOnHide = YES;
}

#pragma mark - Facebook Methods
- (void)facebookSignUp {
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else {
            NSLog(@"Logged in");
              [self fetchUserDetailsFromFB];
         }
     }];
}

-(void)fetchUserDetailsFromFB {
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"picture, email,first_name,last_name,locale,gender,birthday,link"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSLog(@"fetched user:%@", result);
                 NSString *name = [NSString stringWithFormat:@"%@ %@", result[@"first_name"], result[@"last_name"]];
                 [self LoginWithFBName: [Util trim: name] Email: result[@"email"]];
             } else {
                 NSLog(@"Process error");
             }
         }];
    }
}

- (IBAction)btnAction_signUp:(id)sender {
    
    [self trimAllFields];
    if ([self isSignUpDetailsValid]) {
        [self RegisterWithName: self.txtfield_name.text Password: self.txtfield_password.text Email: self.txtfield_email.text];
    }
}

- (void) trimAllFields {
    
    [Util trim:self.txtfield_name.text];
    [Util trim:self.txtfield_email.text];
    [Util trim:self.txtfield_password.text];
}

- (BOOL)isSignUpDetailsValid {
    
    if ([self.txtfield_name.text isEqualToString:@""]) {
        [self presentViewController: [Util alertControllerWithTitle: k_APPName message:@"Name should not be blank" actionTitle: @"OK"] animated:YES completion:nil];
        return NO;
    } else if ([self.txtfield_email.text isEqualToString:@""]) {
        [self presentViewController: [Util alertControllerWithTitle: k_APPName message:@"Email should not be blank" actionTitle: @"OK"] animated:YES completion:nil];
        return NO;
    } else if (![Util isValidEmail: self.txtfield_email.text]) {
        [self presentViewController: [Util alertControllerWithTitle: k_APPName message:@"Invalid email address" actionTitle: @"OK"] animated:YES completion:nil];
        return NO;
    } else if ([self.txtfield_password.text isEqualToString:@""]) {
        [self presentViewController: [Util alertControllerWithTitle: k_APPName message:@"Password should not be blank" actionTitle: @"OK"] animated:YES completion:nil];
        return NO;
    } else if (self.txtfield_password.text.length < 6) {
        [self presentViewController: [Util alertControllerWithTitle: k_APPName message:@"Password should contain minimum 6 characters" actionTitle: @"OK"] animated:YES completion:nil];
        return NO;
    }
    return YES;
}

- (void)RegisterWithName:(NSString *)name Password:(NSString *)password Email:(NSString *)email{
    
    NSString *queryUserCheck = [NSString stringWithFormat:@"SELECT * FROM tblUser WHERE Email='%@';",email];
    NSMutableArray *arrUser = [appDelegate().SQLConnect GetFromDatabase:queryUserCheck];
    if (arrUser.count > 0)
    {
        NSLog(@"User Exist");
        [self presentViewController: [Util alertControllerWithTitle: k_APPName message:@"Email ID already exists, please try with another email." actionTitle: @"OK"] animated:YES completion:nil];
    }
    else
    {
        NSString *queryInsert = [NSString stringWithFormat:@"INSERT INTO tblUser (Name,Password,Email) VALUES ('%@','%@','%@');",name,password,email];
        [appDelegate().SQLConnect insertToDatabase:queryInsert];
        
        [self performSegueWithIdentifier:@"product" sender:nil];
        [appDelegate().defaults setObject:email forKey:k_Email];
        [appDelegate().defaults setObject:@"1" forKey:k_Auth];
    }
    
}

- (void)LoginWithFBName:(NSString *)name Email:(NSString *)email{
    
    NSString *queryLogin = [NSString stringWithFormat:@"SELECT * FROM tblUser WHERE Email='%@';",email];
    NSMutableArray *arrUser = [appDelegate().SQLConnect GetFromDatabase:queryLogin];
    if (arrUser.count <= 0)
    {
        NSString *queryInsert = [NSString stringWithFormat:@"INSERT INTO tblUser (Name,Email) VALUES ('%@','%@');",name,email];
        [appDelegate().SQLConnect insertToDatabase:queryInsert];
    }
    
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    [self performSegueWithIdentifier:@"product" sender:nil];
    [appDelegate().defaults setObject:email forKey:k_Email];
    [appDelegate().defaults setObject:@"1" forKey:k_Auth];
    
}

@end
