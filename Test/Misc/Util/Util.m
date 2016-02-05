//
//  Util.m
//  Test
//
//  Created by Mac7 on 29/12/15.
//  Copyright © 2015 3E IT Solutions. All rights reserved.
//

#import "Util.h"

@implementation Util

+ (UIAlertController *) alertControllerWithTitle: (NSString *)title message: (NSString *)message actionTitle: (NSString *)actionTitle {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle: title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle: actionTitle style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction: okAction];
    return alertController;
}

+ (NSString *) trim: (NSString *) stringToTrim {
    return [stringToTrim stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (BOOL)isValidEmail:(NSString *)strEmail {
    BOOL stricterFilter             = YES;
    NSString *stricterFilterString  = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString             = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex            = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest          = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:strEmail];
}

+ (void)addBottomLine:(UITextField *)textField withPlaceholder:(NSString *)placeholderString {
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 2;
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholderString attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    border.borderColor = [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0  alpha:1.0].CGColor;
    border.frame = CGRectMake(0, textField.frame.size.height - borderWidth, textField.frame.size.width, textField.frame.size.height);
    border.borderWidth = borderWidth;
    [textField.layer addSublayer:border];
    textField.layer.masksToBounds = YES;
}

@end