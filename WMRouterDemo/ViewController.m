//
//  ViewController.m
//  WMRouterDemo
//
//  Created by lorabit on 5/5/16.
//  Copyright © 2016 lorabit.com. All rights reserved.
//

#import "ViewController.h"
#import "WMRouter.h"

@interface ViewController ()

@end

@implementation ViewController

float top = 0;
float width;

UIButton* block(NSString* title, SEL selector, UIViewController* target){
  UIButton* btn = [UIButton new];
    btn.frame = CGRectMake(10, 80 + top, width, 50);
    top = top + 60;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor redColor];
    [target.view addSubview:btn];
    return btn;
};

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [WMRouter sharedRouter].topViewController = self;
  // Do any additional setup after loading the view, typically from a nib.
  
  width = [UIScreen mainScreen].bounds.size.width - 20;
  
  block(@"Present VC", @selector(presentVC), self);
  block(@"Push VC", @selector(pushVC), self);
  block(@"Push VC w/ navigation", @selector(presentVCWNav), self);
  block(@"Call block", @selector(callBlock), self);
  block(@"Call w/ objc params", @selector(callBlockWP), self);
  block(@"Push VC w/ objc params", @selector(pushVCWP), self);
}

-(void)presentVC{
  NSString* URLString = [NSString stringWithFormat:@"app://router/demo?%@=%@",WMRouterOptionTransitionTypeKey,WMRouterOptionTransitionTypePresent];
  [[WMRouter sharedRouter] openURL:[NSURL URLWithString:URLString]];
}

-(void)presentVCWNav{
  NSString* URLString = [NSString stringWithFormat:@"app://router/demo?%@=%@",WMRouterOptionTransitionTypeKey,WMRouterOptionTransitionTypePresentWithNavigation];
  [[WMRouter sharedRouter] openURL:[NSURL URLWithString:URLString]];
}

-(void)pushVC{
  [[WMRouter sharedRouter] openURL:[NSURL URLWithString:@"app://router/demo"]];
}

-(void)callBlock{
  NSString* URLString = [NSString stringWithFormat:@"app://router/alert/%@/%@",URLEncode(@"Title parameter"),URLEncode(@"Message parameter")];
  [[WMRouter sharedRouter] openURL:[NSURL URLWithString:URLString]];
}

-(void)callBlockWP{
  NSString* title = @"Message Title";
  NSString* message = @"Message Content";
  NSString* URLString = [NSString stringWithFormat:@"app://router/alert/%p/%p",title,message];
  [[WMRouter sharedRouter] openURL:[NSURL URLWithString:URLString]];
}

-(void)pushVCWP{
  NSString* title = @"Label Title";
  UIColor* color = [UIColor redColor];
  NSString* URLString = [NSString stringWithFormat:@"app://router/demo/%p/%p",title,color];
  [[WMRouter sharedRouter] openURL:[NSURL URLWithString:URLString]];
}


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
