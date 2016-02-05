//
//  Util.h
//  Test
//
//  Created by Mac7 on 29/12/15.
//  Copyright © 2015 3E IT Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Util : NSObject

+ (NSString *) trim: (NSString *) stringToTrim;
+ (UIAlertController *) alertControllerWithTitle: (NSString *)title message: (NSString *)message actionTitle: (NSString *)actionTitle;
+ (BOOL)isValidEmail:(NSString *)strEmail;
+ (void)addBottomLine:(UITextField *)textField withPlaceholder:(NSString *)placeholderString;

@end
