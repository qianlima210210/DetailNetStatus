//
//  MQLNetworking.m
//

#import "MQLNetworking.h"
#import "sys/utsname.h"

 /*
 机型                 "MachineModel"
 系统名                "SystemName" iOS手机系统、iOS pad系统、Android手机系统
 系统版本               "SystemVersion"
 包名                 "PackageName"
 APP版本号             "AppVersion"
 */
static NSString *MachineModel   = @"MachineModel";
static NSString *SystemName     = @"SystemName";
static NSString *SystemVersion  = @"SystemVersion";
static NSString *PackageName    = @"PackageName";
static NSString *AppVersion     = @"AppVersion";

@interface MQLNetworking ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSDictionary <NSString *, NSString *> *publicHeaders;

@end

@implementation MQLNetworking

//网络请求单例
+(instancetype)sharedInstance{
    static MQLNetworking *instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [MQLNetworking new];
    });
    
    return instance;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        _manager = [AFHTTPSessionManager manager];
        [self initPublicHeaders];
    }
    return self;
}

//初始化公共请求头
-(void)initPublicHeaders{
    //获取机型
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *machine = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    //系统名
    NSString *systemName = [[UIDevice currentDevice] systemName];
    //系统版本
    NSString *systemVersion =  [[UIDevice currentDevice] systemVersion];
    //包名
    NSString *bundleId = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleIdentifier"];
    //应用版本
    NSString *shortVersion = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleShortVersionString"];
    
    _publicHeaders = @{MachineModel:machine, SystemName:systemName, SystemVersion:systemVersion, PackageName:bundleId, AppVersion:shortVersion};
}

//合并publicHeaders和headers
-(NSDictionary*)mergeHeaders:(NSDictionary <NSString *, NSString *> *)headers{
    NSMutableDictionary *dic = [headers mutableCopy];
    for (NSString *headerField in _publicHeaders.keyEnumerator) {
        [dic setValue:_publicHeaders[headerField] forKey:headerField];
    }
    return dic;
}

//一般GET请求
- (nullable NSURLSessionDataTask *)GET:(NSString *)URLString
                            parameters:(nullable id)parameters
                               headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                              progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                               success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                               failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure{
    
    headers = [self mergeHeaders:headers];
    return [_manager GET:URLString parameters:parameters headers:headers progress:downloadProgress success:success failure:failure];
}

//一般POST请求
- (nullable NSURLSessionDataTask *)POST:(NSString *)URLString
                             parameters:(nullable id)parameters
                                headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                               progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure{
    
    headers = [self mergeHeaders:headers];
    return [_manager POST:URLString parameters:parameters headers:headers progress:uploadProgress success:success failure:failure];
}

//文件POST请求
- (nullable NSURLSessionDataTask *)POST:(NSString *)URLString
                             parameters:(nullable id)parameters
                                headers:(nullable NSDictionary <NSString *, NSString *> *)headers
              constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))block
                               progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure{
    
    headers = [self mergeHeaders:headers];
    return [_manager POST:URLString parameters:parameters headers:headers constructingBodyWithBlock:block progress:uploadProgress success:success failure:failure];
}


@end
