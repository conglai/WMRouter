//
//  Alert.m
//  WMRouterDemo
//
//  Created by lorabit on 5/6/16.
//  Copyright © 2016 lorabit.com. All rights reserved.
//

#import "Alert.h"
#import "WMRouter.h"

@implementation Alert

+(void)load{
  [[WMRouter sharedRouter] addRuleWithSchema:@"alert/:title/:message" block:^(NSDictionary *paras) {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:paras[@"title"] message:paras[@"message"] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    [alertView show];
  }];
}

@end
