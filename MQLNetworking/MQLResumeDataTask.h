//
//  MQLResumeDataTask.h
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MQLResumeDataTask : NSObject

/// 断点续传请求
- (void)resumeDataTaskWithURL:(NSString *)URLString
                                    parameters:(id)parameters
                               savePath:(NSString*)savePath
                             downloadProgress:(void(^)(NSProgress *downloadProgress)) downloadProgressBlock
                                  completionHandler:(void(^)(NSURLResponse *response,  NSError *error))completionHandler;

/// 取消断点续传请求
- (void)cancelResumeDataTask;

@end

NS_ASSUME_NONNULL_END
