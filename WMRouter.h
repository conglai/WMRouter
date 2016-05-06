//
//  WMRouter.h
//  withMe
//
//  Created by lorabit on 5/4/16.
//  Copyright © 2016 从来网络. All rights reserved.
//
#define _64bit              sizeof(long)==8


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^WMRouterRuleBlock)(NSDictionary* paras);

extern NSString* WMRouterOptionTransitionTypeKey;
extern NSString* WMRouterOptionTransitionTypePresent;
extern NSString* WMRouterOptionTransitionTypePresentWithNavigation;
extern NSString* WMRouterOptionTransitionTypePush;

extern NSString* WMRouterOptionTransitionAnimationKey;
extern NSString* WMRouterOptionTransitionAnimationNo;
extern NSString* WMRouterOptionTransitionAnimationYes;

extern NSString* URLEncode(NSString* str);
extern NSString* URLDecode(NSString* str);


@interface WMRouterRule : NSObject

@property(nonatomic,copy,readonly) NSString * schema;
@property(nonatomic,copy,readonly) WMRouterRuleBlock block;

+(instancetype) ruleWithSchema:(NSString*)schema block:(WMRouterRuleBlock)block;
-(instancetype) initWithSchema:(NSString*)schema block:(WMRouterRuleBlock)block;
-(void)openWithParameters:(NSDictionary*)params;

@end


@interface WMRouterMap : NSObject

@property(nonatomic,copy,readonly) NSString* schema;
@property(nonatomic,copy,readonly) Class viewControllerClass;
@property(nonatomic,copy,readonly) NSDictionary* options;


+(instancetype) mapWithSchema:(NSString*)schema class:(Class)class;
-(instancetype) initWithSchema:(NSString*)schema class:(Class)class;
+(instancetype) mapWithSchema:(NSString*)schema class:(Class)class options:(NSDictionary*)options;
-(instancetype) initWithSchema:(NSString*)schema class:(Class)class options:(NSDictionary*)options;
-(void)openWithParameters:(NSDictionary*)params;

@end


@interface WMRouter : NSObject

@property(nonatomic,weak) UIViewController* topViewController;

+(instancetype)sharedRouter;

-(void)addRuleWithSchema:(NSString*)schema block:(WMRouterRuleBlock)block;
-(void)addRule:(WMRouterRule*)rule;

-(void)addMapWithSchema:(NSString*)schema class:(Class) class;
-(void)addMap:(WMRouterMap*)map;

-(BOOL)openURL:(NSURL*)URL;


@end