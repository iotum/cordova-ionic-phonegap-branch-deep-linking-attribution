#import "AppDelegate.h"
#import "AppDelegate+APPAppEvent.h"
#import "BranchNPM.h"

#ifdef BRANCH_NPM
#import "Branch.h"
#else
#import <BranchSDK/Branch.h>
#endif

// Provides Ionic Capacitor compatibility
#import <Cordova/CDVPlugin.h>

@implementation AppDelegate (BranchSDK)

- (void)pluginInitialize {
  [[NSNotificationCenter defaultCenter] 
    addObserver:self 
    selector:@selector(branchContinueUserActivityHandler:) 
    name:UIApplicationContinueUserActivity object:nil
  ];
}

// Respond to URI scheme links
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
  // pass the url to the handle deep link call
  if (![[Branch getInstance] application:app openURL:url options:options]) {
    // do other deep link routing for the Facebook SDK, Pinterest SDK, etc
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVPluginHandleOpenURLNotification object:url]];
    // send unhandled URL to notification
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"BSDKPostUnhandledURL" object:[url absoluteString]]];
  }
  return YES;
}

// Respond to Universal Links
- (void) branchContinueUserActivityHandler:(NSNotification*)notification {
  NSUserActivity* userActivity = notification.object;
  if (![[Branch getInstance] continueUserActivity:userActivity]) {
    // send unhandled URL to notification
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
      [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"BSDKPostUnhandledURL" object:[userActivity.webpageURL absoluteString]]];
    }
  }

  return YES;
}

// Respond to Push Notifications
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
  @try {
    [[Branch getInstance] handlePushNotification:userInfo];
  }
  @catch (NSException *exception) {
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"BSDKPostUnhandledURL" object:userInfo]];
  }
}

@end
