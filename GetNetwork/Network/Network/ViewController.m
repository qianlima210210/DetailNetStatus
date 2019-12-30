//
//  ViewController.m
//  Network
//
//  Created by 沈凯 on 2018/1/23.
//  Copyright © 2018年 Ssky. All rights reserved.
//

#import "ViewController.h"
#import "NetworkInformation.h"
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"

@interface ViewController ()
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) Reachability *reachability;
@property (strong, nonatomic) id<NSObject> localeChangeObserver;
@end

@implementation ViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self.localeChangeObserver];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _reachability = [Reachability reachabilityForInternetConnection];
    NSLog(@"%ld", _reachability.currentReachabilityStatus);
    _localeChangeObserver = [[NSNotificationCenter defaultCenter]addObserverForName:kReachabilityChangedNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"%@", note);
    }];
    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onReceivedNo:) name:kReachabilityChangedNotification object:nil];
    [_reachability startNotifier];
    
    
    if (@available(iOS 13.0, *)) {
//        如果是iOS13 未开启地理位置权限 需要提示一下
           if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
               self.locationManager = [[CLLocationManager alloc] init];
               [self.locationManager requestWhenInUseAuthorization];
           }
       }
}

-(void)onReceivedNo:(NSNotification*)no{
    
    Reachability *temp = no.object;
    NSLog(@"%ld", temp.currentReachabilityStatus);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    
}

- (IBAction)action:(UIButton *)sender {
    NSLog(@"1--%@", [NetworkInformation getWifiSSID]);
    NSLog(@"2--%@", [NetworkInformation getWifiBSSID]);
    NSLog(@"3--%@", [NetworkInformation getNetworkTypeByReachability]);
    NSLog(@"4--%@", [NetworkInformation getNetworkType]);
    NSLog(@"5--%d", [NetworkInformation getWifiSignalStrength]);
    NSLog(@"6--%@", [NetworkInformation getIPAddress]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
