# WMRouter

WMRouter is the URL router inside WithMe app, designed to reslove inter-modules coupling. 
WMRouter supports block-based rule, as well as view-controller-based map.
As a brand new feature, object may be directly passed through URL calling via memory address.


## Block Rule

The following code registers a schema that binds schema @"alert/:title/:message" and the block. Parameters will be automatically resolved and sent to the block as paras.

```objc
[[WMRouter sharedRouter] addRuleWithSchema:@"alert/:title/:message" block:^(NSDictionary *paras) {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:paras[@"title"] message:paras[@"message"] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    [alertView show];
  }];
  ```



## View Controller Map

The following code registers a schema that binds schema "demo" and DemoViewController. View controller instance will be pushed when open URL that follows the schema "demo".

```objc
@implementation DemoViewController

+(void)load{
  [[WMRouter sharedRouter] addMap:[WMRouterMap mapWithSchema:@"demo" class:self options:@{WMRouterOptionTransitionTypeKey:WMRouterOptionTransitionTypePush}]];
}  

@end                                                                                                                      
```


## Usage

Be sure to include WMRouter.h.

In your AppDelegate.m:
```objc
-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options{
  if([[WMRouter sharedRouter] openURL:url])
    return NO;
  return YES;
}
```

In your View Controller:

```objc
- (void)viewDidLoad {
  [super viewDidLoad];
  [WMRouter sharedRouter].topViewController = self;
}
