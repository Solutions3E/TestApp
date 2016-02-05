//
//  SignInViewController.m
//  Test
//
//  Created by Admin on 05/02/16.
//  Copyright © 2016 3E. All rights reserved.
//

#import "SignInViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface SignInViewController ()

@property (weak, nonatomic) IBOutlet UITextField *txtfield_email;
@property (weak, nonatomic) IBOutlet UITextField *txtfield_password;

- (IBAction)btnAction_back:(id)sender;
- (IBAction)btnAction_facebookSignUp:(id)sender;
- (IBAction)btnAction_signIn:(id)sender;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addRightHintView];
}

- (void) addRightHintView {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 20 , 20);
    [button setBackgroundImage:[UIImage imageNamed:@"PasswordHint.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showHint:) forControlEvents:UIControlEventTouchUpInside];
    
    self.txtfield_password.rightView = button;
    self.txtfield_password.rightViewMode = UITextFieldViewModeAlways;
}

-(void)showHint : (id)sender {
    
    [self presentViewController: [Util alertControllerWithTitle: k_APPName message:@"Password should contain minimum 6 characters" actionTitle: @"OK"] animated:YES completion:nil];
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

- (IBAction)btnAction_back:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnAction_facebookSignUp:(id)sender {
    
    [self facebookSignUp];
    
    appDelegate().hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    appDelegate().hud.dimBackground = YES;
    appDelegate().hud.removeFromSuperViewOnHide = YES;
    
}

#pragma mark - Facebook Methods
- (void)facebookSignUp {
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile", @"email"]
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

- (IBAction)btnAction_signIn:(id)sender {
    
    [self trimAllFields];
    if ([self isSignInDetailsValid]) {
        [self LoginWithEmail:self.txtfield_email.text Password:self.txtfield_password.text];

    }
}

- (void)trimAllFields {
    
    [Util trim:self.txtfield_email.text];
    [Util trim:self.txtfield_password.text];
}

- (BOOL)isSignInDetailsValid {
    if ([self.txtfield_email.text isEqualToString:@""]) {
        
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

- (void)LoginWithEmail:(NSString *)email Password:(NSString *)password {
    
    NSString *queryLogin = [NSString stringWithFormat:@"SELECT * FROM tblUser WHERE Email='%@' AND Password='%@';",email,password];
    NSMutableArray *arrUser = [appDelegate().SQLConnect GetFromDatabase:queryLogin];
    if (arrUser.count > 0) {
        NSLog(@"Success");
        [self performSegueWithIdentifier:@"product" sender:nil];
        [appDelegate().defaults setObject:email forKey:k_Email];
        [appDelegate().defaults setObject:@"1" forKey:k_Auth];
        
    }
    else
    {
        NSLog(@"Failed");
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
