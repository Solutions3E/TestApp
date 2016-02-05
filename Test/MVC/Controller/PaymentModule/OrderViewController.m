//
//  OrderViewController.m
//  Test
//
//  Created by Admin on 05/02/16.
//  Copyright © 2016 3E. All rights reserved.
//

#import "OrderViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface OrderViewController () {
    UIDatePicker *myPickerView;
}

@property (weak, nonatomic) IBOutlet UITextField *txtfield_name;
@property (weak, nonatomic) IBOutlet UITextField *txtfield_cardNumber;
@property (weak, nonatomic) IBOutlet UITextField *txtfield_expiryDate;
@property (weak, nonatomic) IBOutlet UITextField *txtfield_cvv;
@property (weak, nonatomic) IBOutlet UITextField *txtfield_address1;
@property (weak, nonatomic) IBOutlet UITextField *txtfield_address2;
@property (nonatomic, strong) NSString *str_creditCardBuffer;
@property (weak, nonatomic) IBOutlet UIButton *btn_paymentSuccess;
@property (weak, nonatomic) IBOutlet UITextField *txtfield_lastName;

- (IBAction)btnAction_back:(id)sender;
- (IBAction)btnAction_logOut:(id)sender;
- (IBAction)submit:(id)sender;
- (IBAction)btnAction_paymentSuccess:(id)sender;

@end

@implementation OrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.btn_paymentSuccess.hidden = YES;
    self.str_creditCardBuffer = @"";
    [self addPickerView];
    
    UIImageView *imgview_arrow;
    imgview_arrow.frame = CGRectMake(0, 0, 20 , 20);
    imgview_arrow.image = [UIImage imageNamed:@""];
    
    self.txtfield_expiryDate.rightView = imgview_arrow;
    self.txtfield_expiryDate.rightViewMode = UITextFieldViewModeAlways;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    NSString *email =  [appDelegate().defaults objectForKey:k_Email];
    NSDictionary *dictData = [self GetPaymentDetailsforUser:email];
    
    self.txtfield_name.text = dictData[@"FName"];
    self.txtfield_lastName = dictData[@"LName"];
    self.txtfield_cardNumber = dictData[@"CardNum"];
    self.txtfield_expiryDate = dictData[@"EXPDate"];
    self.txtfield_address1 = dictData[@"Address1"];
    self.txtfield_address2 = dictData[@"Address2"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)btnAction_logOut:(id)sender {
    [self logOutFromFB];
        [appDelegate().defaults setObject:@"0" forKey:k_Auth];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)btnAction_back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)logOutFromFB {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logOut];
}

-(void)addPickerView{
    myPickerView = [[UIDatePicker alloc]init];
    myPickerView.datePickerMode = UIDatePickerModeDate;
    [myPickerView addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    NSDate *today = [[NSDate alloc] init];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setYear:10];
    NSDate *maxDate = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
    [myPickerView setMinimumDate:[NSDate date]];
    [myPickerView setMaximumDate:maxDate];
    self.txtfield_expiryDate.inputView = myPickerView;
}

-(void)datePickerValueChanged:(id)sender{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MMM-yyyy"];
    NSString *formatedDate = [dateFormatter stringFromDate:myPickerView.date];
    self.txtfield_expiryDate.text =formatedDate;
}

-(void)viewDidLayoutSubviews{
    // Add bottom border to textfield
    [Util addBottomLine:self.txtfield_name withPlaceholder:@"FIRST NAME"];
    [Util addBottomLine:self.txtfield_lastName withPlaceholder:@"LAST NAME"];
    [Util addBottomLine:self.txtfield_cardNumber withPlaceholder:@"CARD NUMBER"];
    [Util addBottomLine:self.txtfield_cvv withPlaceholder:@"CVV"];
    [Util addBottomLine:self.txtfield_expiryDate withPlaceholder:@"EXPIRY DATE"];
    [Util addBottomLine:self.txtfield_address1 withPlaceholder:@"ADDRESS LINE 1"];
    [Util addBottomLine:self.txtfield_address2 withPlaceholder:@"ADDRESS LINE 2"];
}

- (IBAction)submit:(id)sender {
    NSString *alertMsg = nil;
    if(self.txtfield_cardNumber.text.length < 1) {
        alertMsg = @"Please enter card number";
    } else if (self.txtfield_expiryDate.text.length < 1) {
        alertMsg = @"Please select expiry Date";
    } else if (self.txtfield_cvv.text.length < 1){
        alertMsg = @"Please enter CVV";
    }
    
    if(alertMsg != nil) {
        [self presentViewController: [Util alertControllerWithTitle: k_APPName message: alertMsg actionTitle: @"OK"] animated:YES completion:nil];
    }
    else
    {
        NSString *email =  [appDelegate().defaults objectForKey:k_Email];
        NSString *uID = [self GetUserIDfromEmail:email];
        [self savePaymentInfoWithFirstName:self.txtfield_name.text LastName:self.txtfield_lastName.text UserID:uID CardNumber:self.txtfield_cardNumber.text ExpDate:self.txtfield_expiryDate.text Address1:self.txtfield_address1.text Address2:self.txtfield_address2.text];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd-MMM-yyyy"];
        NSDate *date = [dateFormatter dateFromString:self.txtfield_expiryDate.text];
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date]; // Get necessary date components

        
        STPCardParams *cardParams = [[STPCardParams alloc] init];
        [cardParams setNumber:self.txtfield_cardNumber.text];
        [cardParams setExpMonth:[components month]];
        [cardParams setExpYear:[components year]];
        [cardParams setCvc:self.txtfield_cvv.text];
        
        
        [[STPAPIClient sharedClient]
         createTokenWithCard:cardParams
         completion:^(STPToken *token, NSError *error) {
             if (error) {
                 //[self handleError:error];
             } else {
                 [self createBackendChargeWithToken:token completion:^(PKPaymentAuthorizationStatus status) {
                     
                 }];
             }
         }];
    }
    
}

- (IBAction)btnAction_paymentSuccess:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
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

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField == self.txtfield_cardNumber){
        self.str_creditCardBuffer = [NSString string];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.txtfield_cvv) {
        if ([string length] > 0) {
            
            if ([self isMaxLength:textField])
                return NO;
            self.txtfield_cvv.text = [NSString stringWithFormat:@"%@%@", self.txtfield_cvv.text, string];
        } else {
            
            //Back Space do manual backspace
            if ([self.txtfield_cvv.text length] > 1) {
                self.txtfield_cvv.text = [self.txtfield_cvv.text substringWithRange:NSMakeRange(0, [self.txtfield_cvv.text length] - 1)];
            } else {
                self.txtfield_cvv.text = @"";
            }
        }
    }
    else  if (textField == self.txtfield_cardNumber) {
        if ([string length] > 0) { //NOT A BACK SPACE Add it
            
            if ([self isMaxLength:textField])
                return NO;
            
            self.str_creditCardBuffer  = [NSString stringWithFormat:@"%@%@", self.str_creditCardBuffer, string];
        } else {
            
            //Back Space do manual backspace
            if ([self.str_creditCardBuffer length] > 1) {
                self.str_creditCardBuffer = [self.str_creditCardBuffer substringWithRange:NSMakeRange(0, [self.str_creditCardBuffer length] - 1)];
            } else {
                self.str_creditCardBuffer = @"";
            }
        }
        [self formatValue:textField];
    } else {
        return YES;
    }
    return NO;
}

- (void) formatValue:(UITextField *)textField {
    NSMutableString *value = [NSMutableString string];
    if (textField == self.txtfield_cardNumber ) {
        NSInteger length = [self.str_creditCardBuffer length];
        
        for (int i = 0; i < length; i++) {
            
            // Reveal only the last character.
            if (length <= kCreditCardObscureLength) {
                [value appendString:[self.str_creditCardBuffer substringWithRange:NSMakeRange(i,1)]];
            }
            // Reveal the last 4 characters
            else {
                [value appendString:[self.str_creditCardBuffer substringWithRange:NSMakeRange(i,1)]];
            }
            
            //After 4 characters add a space
            if ((i +1) % 4 == 0 &&
                ([value length] < kCreditCardLengthPlusSpaces)) {
                [value appendString:kSpace];
            }
        }
        textField.text = value;
    }
}

- (BOOL) isMaxLength:(UITextField *)textField {
    if (textField == self.txtfield_cvv && [textField.text length] >= 4) {
        return YES;
    }
    if (textField == self.txtfield_cardNumber && [textField.text length] >= 19) {
        return YES;
    }
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)savePaymentInfoWithFirstName:(NSString *)fName LastName:(NSString *)lName UserID:(NSString *)uid CardNumber:(NSString *)cardNum ExpDate:(NSString *)expdate Address1:(NSString *)add1 Address2:(NSString *)add2
{
    NSString *queryUserCheck = [NSString stringWithFormat:@"SELECT * FROM tblPaymentSettings WHERE UserID='%@';",uid];
    NSMutableArray *arrUser = [appDelegate().SQLConnect GetFromDatabase:queryUserCheck];
    if (arrUser.count > 0)
    {
        NSLog(@"User Exist");
        
        NSString *queryUpdate = [NSString stringWithFormat:@"UPDATE tblPaymentSettings SET FName='%@',LName='%@',CardNum='%@',EXPDate='%@',Address1='%@',Address2='%@' WHERE UserID = '%@';",fName,lName,cardNum,expdate,add1,add2,uid];
        [appDelegate().SQLConnect updateDatabase:queryUpdate];
        
    }
    else
    {
        
        NSString *queryInsert = [NSString stringWithFormat:@"INSERT INTO tblPaymentSettings (FName,LName,UserID,CardNum,EXPDate,Address1,Address2) VALUES ('%@','%@','%@','%@','%@','%@','%@',);",fName,lName,uid,cardNum,expdate,add1,add2];
        [appDelegate().SQLConnect insertToDatabase:queryInsert];
    }
}

- (NSString*)GetUserIDfromEmail:(NSString*)email
{
    NSString *queryUser = [NSString stringWithFormat:@"SELECT * FROM tblUser WHERE Email='%@';",email];
    NSMutableArray *arrUser = [appDelegate().SQLConnect GetFromDatabase:queryUser];
    if (arrUser.count > 0)
    {
        return arrUser[0][@"ID"];
    }
    return @"0";
}

- (NSMutableDictionary*)GetPaymentDetailsforUser:(NSString*)email
{
    
    NSString *uID = [self GetUserIDfromEmail:email];
    
        NSLog(@"Success");
        
        NSString *queryPayment = [NSString stringWithFormat:@"SELECT * FROM tblPaymentSettings WHERE UserID='%@';",uID];
        NSMutableArray *arrDetails = [appDelegate().SQLConnect GetFromDatabase:queryPayment];
        if (arrDetails.count > 0)
        {
            return arrDetails[0];
        }

    
    
    return [NSMutableDictionary dictionary];
}

- (void)createBackendChargeWithToken:(STPToken *)token
                          completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    NSURL *url = [NSURL URLWithString:@"https://example.com/token"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *body     = [NSString stringWithFormat:@"stripeToken=%@", token.tokenId];
    request.HTTPBody   = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDataTask *task =
    [session dataTaskWithRequest:request
               completionHandler:^(NSData *data,
                                   NSURLResponse *response,
                                   NSError *error) {
                   if (error) {
                            [self presentViewController: [Util alertControllerWithTitle: k_APPName message:error.description actionTitle: @"OK"] animated:YES completion:nil];
                       completion(PKPaymentAuthorizationStatusFailure);
                   } else {
                       self.btn_paymentSuccess.hidden = NO;
                       completion(PKPaymentAuthorizationStatusSuccess);
                   }
               }];
    [task resume];
}

@end
