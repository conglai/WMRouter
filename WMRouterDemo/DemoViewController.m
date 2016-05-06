//
//  DemoViewController.m
//  WMRouterDemo
//
//  Created by lorabit on 5/5/16.
//  Copyright © 2016 lorabit.com. All rights reserved.
//

#import "DemoViewController.h"
#import "WMRouter.h"

@implementation DemoViewController

+(void)load{
  [[WMRouter sharedRouter] addMap:[WMRouterMap mapWithSchema:@"demo" class:self options:@{
                                                                                                                        WMRouterOptionTransitionTypeKey:WMRouterOptionTransitionTypePush
                                                                                                                        }]];
  
  [[WMRouter sharedRouter] addMap:[WMRouterMap mapWithSchema:@"demo/:titleString/:backgroundColor" class:self options:@{
                                                                                                                        WMRouterOptionTransitionTypeKey:WMRouterOptionTransitionTypePush
                                                                                                                        }]];
}

-(void)viewDidLoad{
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor blueColor];
  UILabel* label = [UILabel new];
  label.frame = CGRectMake(10, 100, 200, 50);
  label.text = self.titleString;
  [self.view addSubview:label];
  label.backgroundColor = self.backgroundColor;
  
  UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
  [self.view addGestureRecognizer:tapGesture];
}

-(void)tap{
  if(self.navigationController){
    if(self.navigationController.viewControllers.count>1){
      [self.navigationController popViewControllerAnimated:YES];
      return;
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    return;
  }
  [self dismissViewControllerAnimated:YES completion:NULL];
}




@end
