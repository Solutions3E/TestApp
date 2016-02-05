//
//  AppDelegate.h
//  Test
//
//  Created by Admin on 05/02/16.
//  Copyright © 2016 3E. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SQLConnection.h"

@class MBProgressHUD;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SQLConnection *SQLConnect;
@property (strong, nonatomic) NSUserDefaults *defaults;
@property (strong, nonatomic) MBProgressHUD *hud;

@end

AppDelegate *appDelegate(void);

