

//
//  WMRouter.m
//  withMe
//
//  Created by lorabit on 5/4/16.
//  Copyright © 2016 从来网络. All rights reserved.
//

#import "WMRouter.h"
#import "objc/runtime.h"


NSString* WMRouterOptionTransitionTypeKey = @"WMRouterOptionTransitionTypeKey";
NSString* WMRouterOptionTransitionTypePresent = @"WMRouterOptionTransitionTypePresent";
NSString* WMRouterOptionTransitionTypePresentWithNavigation = @"WMRouterOptionTransitionTypePresentWithNavigation";
NSString* WMRouterOptionTransitionTypePush = @"WMRouterOptionTransitionTypePush";

NSString* WMRouterOptionTransitionAnimationKey = @"WMRouterOptionTransitionAnimationKey";
NSString* WMRouterOptionTransitionAnimationNo = @"WMRouterOptionTransitionAnimationNo";
NSString* WMRouterOptionTransitionAnimationYes = @"WMRouterOptionTransitionAnimationYes";

NSString* URLEncode(NSString* str){
  return [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"]];
}

NSString* URLDecode(NSString* str){
  return [str stringByRemovingPercentEncoding];
}

Class property_getClass(objc_property_t property){
  unsigned int count = 0;
  objc_property_attribute_t * attributes = property_copyAttributeList(property,&count);
  Class result;
  for(int i = 0 ;i<count;i++){
    if(strcmp(attributes[i].name, "T")==0){
      char class_name[256];
      strcpy(class_name, attributes[i].value);
      class_name[strlen(class_name)-1] = '\0';
      result = NSClassFromString([NSString stringWithUTF8String:(class_name+2)]);
    }
  }
  free(attributes);
  return result;
}

@implementation WMRouterRule

+(instancetype)ruleWithSchema:(NSString *)schema block:(WMRouterRuleBlock)block{
  return [[WMRouterRule alloc] initWithSchema:schema block:block];
}

-(instancetype)initWithSchema:(NSString *)schema block:(WMRouterRuleBlock)block{
  self = [super init];
  _schema = schema;
  _block = block;
  return self;
}

-(void)openWithParameters:(NSDictionary*)params{
  if(self.block && self.block!=NULL)
    self.block(params);
}

@end

@implementation WMRouterMap

+(instancetype)mapWithSchema:(NSString *)schema class:(Class)class options:(NSDictionary *)options{
  return [[WMRouterMap alloc] initWithSchema:schema class:class options:options];
}

-(instancetype)initWithSchema:(NSString *)schema class:(Class)class options:(NSDictionary *)options{
  self = [super init];
  _schema = schema;
  _viewControllerClass = class;
  _options = options;
  return self;
}

+(instancetype)mapWithSchema:(NSString *)schema class:(Class)class{
  return [[WMRouterMap alloc] initWithSchema:schema class:class options:@{}];
}

-(instancetype)initWithSchema:(NSString *)schema class:(Class)class{
  return [self initWithSchema:schema class:class options:@{}];
}

-(NSString*)optionForKey:(NSString*)key parameters:(NSDictionary*)dic defaultValue:(NSString*) defaultValue{
  NSString* v = [dic objectForKey:key];
  if(!v)
    v = [self.options objectForKey:key];
  if(!v)
    v = defaultValue;
  return v;
}

-(void)openWithParameters:(NSDictionary*)params{
  UIViewController* viewController = (UIViewController*)[[self.viewControllerClass alloc] init];
  for (NSString* key in params) {
    if([key isEqualToString:WMRouterOptionTransitionTypeKey]){
      continue;
    }
    id value = params[key];
    objc_property_t property = class_getProperty(self.viewControllerClass, key.UTF8String);
    Class class = property_getClass(property);
    if(class && [value isKindOfClass:class]){
      [viewController setValue:value forKeyPath:key];
    }else{
      if(!class){
        NSLog(@"WMRouter Warning >> Unable to resolve class for property %@.", key);
      }else
        NSLog(@"WMRouter Warning >> Failed to assign an instance of %@ to a property of Class %@.", NSStringFromClass([value class]), NSStringFromClass(class));
    }
  }
  
  NSString* transition = [self optionForKey:WMRouterOptionTransitionTypeKey parameters:params defaultValue:WMRouterOptionTransitionTypePush];
  BOOL animated = [[self optionForKey:WMRouterOptionTransitionAnimationKey parameters:params defaultValue:WMRouterOptionTransitionAnimationYes] isEqualToString:WMRouterOptionTransitionAnimationYes];
  
  if([transition isEqualToString:WMRouterOptionTransitionTypePush]){
    [[WMRouter sharedRouter].topViewController.navigationController pushViewController:viewController animated:animated];
    return;
  }
  if([transition isEqualToString:WMRouterOptionTransitionTypePresent]){
    [[WMRouter sharedRouter].topViewController presentViewController:viewController animated:animated completion:NULL];
    return;
  }
  if([transition isEqualToString:WMRouterOptionTransitionTypePresentWithNavigation]){
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    [[WMRouter sharedRouter].topViewController presentViewController:nav animated:animated completion:NULL];
    return;
  }
}

@end

@implementation WMRouter{
  NSMutableDictionary* rules;
  NSMutableDictionary* maps;
}

+(instancetype)sharedRouter{
  static WMRouter * sharedRouter;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedRouter = [[WMRouter alloc] init];
  });
  
  return sharedRouter;
}

-(instancetype)init{
  self = [super init];
  rules = [NSMutableDictionary new];
  maps = [NSMutableDictionary new];
  return self;
}

-(void)addRule:(WMRouterRule *)rule{
  [rules setObject:rule forKey:[self pattenOfSchema:rule.schema]];
}

-(void)addMap:(WMRouterMap *)map{
  [maps setObject:map forKey:[self pattenOfSchema:map.schema]];
}

-(NSString*)pattenOfSchema:(NSString*)schema{
  NSMutableArray* schemaComponents = [NSMutableArray new];
  for(NSString* string in [schema componentsSeparatedByString:@"/"]){
    if([string hasPrefix:@":"])
      [schemaComponents addObject:@":"];
    else
      [schemaComponents addObject:string];
  }
  return [schemaComponents componentsJoinedByString:@"/"];
}

-(void)addRuleWithSchema:(NSString *)schema block:(WMRouterRuleBlock)block{
  [self addRule:[WMRouterRule ruleWithSchema:schema block:block]];
}

-(void)addMapWithSchema:(NSString *)schema class:(Class)class{
  [self addMap:[WMRouterMap mapWithSchema:schema class:class]];
}

-(BOOL)matchURL:(NSURL*)URL withSchema:(NSString*)schema{
  NSMutableArray* urlComponents = [NSMutableArray new];
  for(NSString* string in URL.pathComponents){
    if(![string isEqualToString:@"/"])
      [urlComponents addObject:string];
  }
  NSArray* schemaComponents = [schema componentsSeparatedByString:@"/"];
  if(urlComponents.count!=schemaComponents.count)
    return NO;
  for(int i = 0;i<urlComponents.count;i++){
    if([[schemaComponents objectAtIndex:i] isEqualToString:@":"])
      continue;
    if(![[schemaComponents objectAtIndex:i] isEqualToString:[urlComponents objectAtIndex:i]])
      return NO;
  }
  return YES;
}

-(NSDictionary*)paramsFromQueryString:(NSString*)queryString{
  if(queryString==nil || queryString.length ==0 ) return @{};
  NSMutableDictionary* dic = [NSMutableDictionary new];
  for(NSString * line in [queryString componentsSeparatedByString:@"&"]){
    NSArray* assign =  [line componentsSeparatedByString:@"="];
    if(assign.count!=2) continue;
    [dic setObject:assign[1] forKey:assign[0]];
  }
  return dic;
}

-(NSDictionary*)paramsFromURL:(NSURL*) URL withSchema:(NSString*)schema{
  NSMutableArray* urlComponents = [NSMutableArray new];
  for(NSString* string in URL.pathComponents){
    if(![string isEqualToString:@"/"])
      [urlComponents addObject:string];
  }
  NSArray* schemaComponents = [schema componentsSeparatedByString:@"/"];
  NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithDictionary:[self paramsFromQueryString:URL.query]];
  for(int i = 0;i<urlComponents.count;i++){
    if([[schemaComponents objectAtIndex:i] hasPrefix:@":"]){
      [params setObject:urlComponents[i] forKey:[[schemaComponents objectAtIndex:i] substringFromIndex:1]];
    }
  }
  
  return [self paramsWithHexAddressProcess:params];
}

-(NSDictionary*)paramsWithHexAddressProcess:(NSDictionary*)dic{
  NSMutableDictionary* params = [NSMutableDictionary new];
  for(NSString* key in dic){
    if([[dic objectForKey:key] hasPrefix:@"0x"]){
      NSString *input = [dic objectForKey:key];
      
      id value;
      if(_64bit){
        unsigned long long address = ULONG_LONG_MAX; // or UINT_MAX
        [[NSScanner scannerWithString:input] scanHexLongLong:&address];
        if (address == ULONG_LONG_MAX)
          continue;
        void *asRawPointer = (void *) (intptr_t) address;
        value = (__bridge id) asRawPointer;
      }else{
        unsigned int address = UINT_MAX; // or UINT_MAX
        [[NSScanner scannerWithString:input] scanHexInt:&address];
        if (address == UINT_MAX)
          continue;
        void *asRawPointer = (void *) (intptr_t) address;
        value = (__bridge id) asRawPointer;
      }
      [params setObject:value forKey:key];
    }else{
      [params setObject:URLDecode([dic objectForKey:key]) forKey:key];
    }
  }
  return params;
}


-(void)openURL:(NSURL *)URL{
  for (NSString* key in rules) {
    if([self matchURL:URL withSchema:key]){
      WMRouterRule* rule = [rules valueForKey:key];
      [rule openWithParameters:[self paramsFromURL:URL withSchema:rule.schema]];
      return;
    }
  }
  for (NSString* key in maps) {
    if([self matchURL:URL withSchema:key]){
      WMRouterMap* map = [maps valueForKey:key];
      [map openWithParameters:[self paramsFromURL:URL withSchema:map.schema]];
      return;
    }
  }
}

@end

