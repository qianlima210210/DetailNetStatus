//
//  MQLResumeDataTask.m
//

#import "MQLResumeDataTask.h"

@interface MQLResumeDataTask ()<NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSFileManager *fileManager;   //用其获取文件大小
@property (nonatomic, strong) NSString *savePath;           //文件存放位置

@property (nonatomic, strong) NSURLSession *session;        //请求会话
@property (nonatomic, strong) NSOutputStream *outStream;    //输出流

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;   //下载任务
@property (nonatomic, strong) NSProgress *downloadProgress;     //记录下载进度
@property (nonatomic, copy) void (^downloadProgressBlock)(NSProgress*); //下载进度回调
@property (nonatomic, copy) void (^completionHandler)(NSURLResponse*, NSError*);//下载完成回调

@end

@implementation MQLResumeDataTask

- (instancetype)init
{
    self = [super init];
    if (self) {
        _fileManager = [NSFileManager defaultManager];
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
        
        _downloadProgress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
        [_downloadProgress addObserver:self
                   forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
    }
    return self;
}

#pragma mark - NSProgress Tracking
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
   if ([object isEqual:self.downloadProgress]) {
        if (self.downloadProgressBlock) {
            self.downloadProgressBlock(object);
        }
    }
}

-(void)dealloc{
    [self.downloadProgress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
}

/// 断点续传请求
- (void)resumeDataTaskWithURL:(NSString *)URLString
                                     parameters:(id)parameters
                                       savePath:(NSString*)savePath
                               downloadProgress:(void(^)(NSProgress *downloadProgress)) downloadProgressBlock
     completionHandler:(void(^)(NSURLResponse *response, NSError * error))completionHandler {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    // 设置请求头for断点续传
    NSString *range = [NSString stringWithFormat:@"bytes=%lld-", [self caculateFileSizeWithPath:savePath]];
    [request setValue:range forHTTPHeaderField:@"Range"];

    //记录保存路径、下载进度回调、完成回调
    self.savePath = savePath;
    self.downloadProgressBlock = downloadProgressBlock;
    self.completionHandler = completionHandler;
    
    //创建任务并启动
    self.dataTask = [self.session dataTaskWithRequest:request];
    [self.dataTask resume];
}

/// 取消断点续传请求
- (void)cancelResumeDataTask{
    if (self.dataTask) {
        [self.dataTask cancel];
        self.dataTask = nil;
    }
}

//获取文件大小
- (int64_t)caculateFileSizeWithPath:(NSString *)filePath {
    if (![_fileManager fileExistsAtPath:filePath]) return 0;
    return [[_fileManager attributesOfItemAtPath:filePath error:nil] fileSize];
}

#pragma mark -- NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    //error.code == -999 || error.code == -1011)  //cancel  || timed out
    self.completionHandler(task.response, error);
    if (self.outStream) {
        [self.outStream close];
        self.outStream = nil;
    }
}

#pragma mark -- NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    //计算起始进度
    self.downloadProgress.totalUnitCount = response.expectedContentLength + [self caculateFileSizeWithPath:self.savePath];
    self.downloadProgress.completedUnitCount = [self caculateFileSizeWithPath:self.savePath];
    
    // 利用NSOutputStream往Path中写入数据（append为YES的话，每次写入都是追加到文件尾部）
    _outStream = [[NSOutputStream alloc] initToFileAtPath:_savePath append:YES];
    //打开流(如果文件不存在，会自动创建)
    [_outStream open];
    
    //允许继续请求
    NSURLSessionResponseDisposition disposition = NSURLSessionResponseAllow;
    completionHandler(disposition);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    //追加数据
    [_outStream write:data.bytes maxLength:data.length];
    //变更已下载数据大小
    self.downloadProgress.completedUnitCount = [self caculateFileSizeWithPath:self.savePath];
}


@end
