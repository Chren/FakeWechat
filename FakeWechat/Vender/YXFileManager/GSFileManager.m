//
//  ORFileManager.m
//  ORead
//
//  Created by chhren on 14-7-30.
//  Copyright (c) 2014年 oread. All rights reserved.
//

#import "GSFileManager.h"

@implementation GSFileManager
+ (instancetype)sharedManager
{
    static GSFileManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[[self class] alloc] init];
        
        [self initialize];
    });
    
    return _sharedManager;
}

- (void)initialize
{
    OTF_Initialize();
}

- (NSString *)pathForDomain:(GSFileDirDomain)aDirDomain;
{
    NSString *path = nil;
    
    switch (aDirDomain)
    {
        case GSFileDirDomain_Temp:
        {
            path = OTF_PathForDirDomain(OTF_Temp);
        }
            break;
        case GSFileDirDomain_Pub:
        {
            path = OTF_PathForDirDomain(OTF_PrivateDoucuments);
            path = [path stringByAppendingPathComponent:@"Public"];
        }
            break;
        case GSFileDirDomain_User:
        {
            path = OTF_PathForDirDomain(OTF_PrivateDoucuments);
            path = [path stringByAppendingPathComponent:@"User"];
        }
            break;
        default:
            break;
    }
    return path;
}

- (NSString *)pathForDomain:(GSFileDirDomain)aDirDomain appendPathName:(NSString *)aAppendPathName
{
    NSString *path = [self pathForDomain:aDirDomain];
    path = [path stringByAppendingPathComponent:aAppendPathName];
    return path;
}

- (void)removeFileAtPath:(NSString *)aPath
{
    OTF_RemoveItem(aPath);
}

- (NSArray *)fileListAtPath:(NSString *)aPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:aPath error:NULL];
    return fileList;
}


+ (BOOL)isLocalPath:(NSString *)aPath
{
    if ([aPath hasPrefix:@"http://"] || [aPath hasPrefix:@"https://"])
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (BOOL)saveDic:(NSDictionary *)aDic atFilePath:(NSString *)aFilePath
{
    @try {
        
        NSMutableData *data = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:[self objectFromObject:aDic]];
        [archiver finishEncoding];
        
        if (data != nil)
        {
            OTF_CreateFile(aFilePath, YES);
            
            BOOL isSuccess = [data writeToFile:aFilePath atomically:YES];
            return isSuccess;
        }
        else
        {
            return NO;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        NSAssert(0, @"保存到文件错误");
    }
    @finally {
        
    }
    
}

- (NSDictionary *)loadDicAtFilePath:(NSString *)aFilePath
{
    @try {
        
        NSData *data = [NSData dataWithContentsOfFile:aFilePath];
        
        if (data != nil)
        {
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
            NSDictionary *dic = [unarchiver decodeObject];
            [unarchiver finishDecoding];
            
            return dic;
        }
        else
        {
            return nil;
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        NSAssert(0, @"从文件中加载错误");
    }
    @finally {
        
    }
}

- (id)loadObjectAtFilePath:(NSString *)aFilePath
{
    @try {
        NSData *data = [NSData dataWithContentsOfFile:aFilePath];
        
        if (data != nil)
        {
            NSObject *obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            return obj;
        }
        else
        {
            return nil;
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        NSAssert(0, @"从文件中加载错误");
    }
    @finally {
        
    }
}

- (BOOL)saveObject:(id)anObject atFilePath:(NSString *)aFilePath
{
    @try {
        NSData* data = [NSKeyedArchiver archivedDataWithRootObject:anObject];
        
        if (data != nil)
        {
            OTF_CreateFile(aFilePath, YES);
            
            BOOL isSuccess = [data writeToFile:aFilePath atomically:YES];
            return isSuccess;
        }
        else
        {
            return NO;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        NSAssert(0, @"保存到文件错误");
    }
    @finally {
        
    }
    
}

- (id)objectFromObject:(id)aObject
{
    if ([aObject isKindOfClass:[NSString class]] || [aObject isKindOfClass:[NSNumber class]])
    {
        return aObject;
    }
    else if ([aObject isKindOfClass:[NSArray class]])
    {
        NSMutableArray *newArray = [NSMutableArray array];
        for (id arrayObj in aObject)
        {
            id object = [self objectFromObject:arrayObj];
            if (object != nil)
            {
                [newArray addObject:object];
            }
        }
        return newArray;
    }
    else if ([aObject isKindOfClass:[NSDictionary class]])
    {
        NSMutableDictionary *newDic = [NSMutableDictionary dictionary];
        for (NSString *key in [aObject allKeys])
        {
            id object = [self objectFromObject:[aObject objectForKey:key]];
            if (object != nil)
            {
                [newDic setObject:object forKey:key];
            }
        }
        return newDic;
    }
    
    return nil;
}

+ (float) fileSizeAtPath:(NSString*)aFilePath
{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:aFilePath]){
        
        return [[manager attributesOfItemAtPath:aFilePath error:nil] fileSize]/(1024.0*1024);
    }
    return 0;
}

- (void)createUserDirWithUserId:(NSString *)anUserId
{
    @try {
        NSString *dir = [self pathForDomain:GSFileDirDomain_User appendPathName:anUserId];
        if (OTF_FileExistsAtPath(dir, NULL) == NO)
        {
            OTF_CreateDir(dir);
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        NSAssert(0, @"创建文件夹失败");
    }
    @finally {
        
    }
}

@end
