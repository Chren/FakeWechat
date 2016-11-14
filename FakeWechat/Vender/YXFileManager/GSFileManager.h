//
//  ORFileManager.h
//  ORead
//
//  Created by chhren on 14-7-30.
//  Copyright (c) 2014年 oread. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTFileManager.h"

typedef NS_OPTIONS(NSUInteger, GSFileDirDomain)
{
    GSFileDirDomain_Temp,
    GSFileDirDomain_Pub,                    // Public 公用的文件夹
    GSFileDirDomain_User,                   // User 用户相关的数据
};

@interface GSFileManager : NSObject
+ (instancetype)sharedManager;

- (NSString *)pathForDomain:(GSFileDirDomain)aDirDomain;
- (NSString *)pathForDomain:(GSFileDirDomain)aDirDomain appendPathName:(NSString *)aAppendPathName;
- (BOOL)saveDic:(NSDictionary *)aDic atFilePath:(NSString *)aFilePath;
- (NSDictionary *)loadDicAtFilePath:(NSString *)aFilePath;

- (id)loadObjectAtFilePath:(NSString *)aFilePath;
- (BOOL)saveObject:(NSObject *)anObject atFilePath:(NSString *)aFilePath;

- (void)removeFileAtPath:(NSString *)aPath;

- (NSArray *)fileListAtPath:(NSString *)aPath;

+ (BOOL)isLocalPath:(NSString *)aPath;

+ (float) fileSizeAtPath:(NSString*)aFilePath;

- (void)createUserDirWithUserId:(NSString *)anUserId;
@end
