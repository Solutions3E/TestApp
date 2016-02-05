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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)btnAction_logOut:(id)sender {
    [self logOutFromFB];
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
    [Util addBottomLine:self.txtfield_name withPlaceholder:@"NAME"];
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
    
    self.btn_paymentSuccess.hidden = NO;
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

@end
