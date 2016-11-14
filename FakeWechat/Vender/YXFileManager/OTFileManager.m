//
//  OTFileManager.m
//  FileSystemSample
//
//  Created by ruwei on 14-4-2.
//  Copyright (c) 2014年 ruwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFileManager.h"
#import <sys/xattr.h>
#import <CommonCrypto/CommonDigest.h>

#define ReservedDir @"$OT_Reserved_3715$"

@interface OTFile ()

@property (readwrite, nonatomic , strong) NSString *path;

@end

@implementation OTFile

- (void)remove
{
    BOOL ret;
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];
    ret = [fm removeItemAtPath:self.path error:&error];
    if ( !ret )
    {
        @throw [[NSException alloc] initWithName:[error localizedDescription] reason:[error localizedFailureReason] userInfo:nil];
    }
    
}
@end


@implementation OTFileAutoRemoved

- (void) dealloc
{
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:self.path error:nil];
}

@end



//NSFileManager *fm = [NSFileManager defaultManager];
//ret = [fm createFileAtPath:logFilePath contents:nil attributes:nil];

BOOL OTF_AddSkipBackupAttributeToItemAtPath(NSString *aPath)
{
    if(![[NSFileManager defaultManager] fileExistsAtPath:aPath]){
        return NO;
    }
    
    NSError *error = nil;
    BOOL success = NO;
    
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    if ([systemVersion floatValue] >= 5.1f)
    {
        success = [[NSURL fileURLWithPath:aPath] setResourceValue:[NSNumber numberWithBool:YES]
                                                           forKey:@"NSURLIsExcludedFromBackupKey"
                                                            error:&error];
    }
    else if ([systemVersion isEqualToString:@"5.0.1"])
    {
        const char* filePath = [aPath fileSystemRepresentation];
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        success = (result == 0);
    }
    else
    {
        NSLog(@"Can not add 'do no back up' attribute at systems before 5.0.1");
    }
    
    if(!success)
    {
        NSLog(@"Error excluding %@ from backup %@", [aPath lastPathComponent], error);
    }
    
    return success;
}



BOOL OTF_RemoveSkipBackupAttributeToItemAtPath(NSString *aPath)
{
    if(![[NSFileManager defaultManager] fileExistsAtPath:aPath]){
        return NO;
    }
    
    NSError *error = nil;
    BOOL success = NO;
    
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    if ([systemVersion floatValue] >= 5.1f)
    {
        success = [[NSURL fileURLWithPath:aPath] setResourceValue:[NSNumber numberWithBool:NO]
                                                           forKey:@"NSURLIsExcludedFromBackupKey"
                                                            error:&error];
    }
    else if ([systemVersion isEqualToString:@"5.0.1"])
    {
        const char* filePath = [aPath fileSystemRepresentation];
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 0;
        
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        success = (result == 0);
    }
    else
    {
        NSLog(@"Can not add 'do no back up' attribute at systems before 5.0.1");
    }
    
    if(!success)
    {
        NSLog(@"Error excluding %@ from backup %@", [aPath lastPathComponent], error);
    }
    
    return success;
}


//   a/b/ce.text  a.b.ce.text
NSString * OTF_PathForDirDomain0(OTFDirDomain aDirDomain)
{
    NSArray *paths;
    NSString *path;
    
    switch (aDirDomain) {
        case OTF_Cache:
            //<Application_Home>/Library/Caches
            paths= NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            path = (NSString *)paths[0];
            break ;
        case OTF_Temp:
            //<Application_Home>/tmp
            path = NSTemporaryDirectory();
            break ;
        case OTF_Temp_Reserved:
            //<Application_Home>/tmp/<ReservedDir>
            path = NSTemporaryDirectory();
            path = [path stringByAppendingPathComponent:ReservedDir];
            break;
        case OTF_Documents:
            //<Application_Home>/Documents
            paths= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            path = (NSString *)paths[0];
            break;
        case OTF_PrivateDoucuments:
            //<Application_Home>/Library/PrivateDocuments
            paths= NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
            path = (NSString *)paths[0];
            path = [path stringByAppendingPathComponent:@"PrivateDocuments"];
            break;
        case OTF_PrivateDoucuments_Reserved:
            //<Application_Home>/Library/PrivateDocuments/<ReservedDir>
            paths= NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
            path = (NSString *)paths[0];
            path = [path stringByAppendingPathComponent:@"PrivateDocuments"];
            path = [path stringByAppendingPathComponent:ReservedDir];
            break;
            
        case OTF_PrivateICloud:
            //<Application_Home>/Library/PrivateICloud
            paths= NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
            path = (NSString *)paths[0];
            path = [path stringByAppendingPathComponent:@"PrivateICloud"];
            break;
            
        default:
            path = nil;
            break;
    }
    
    return path;
}

void OTF_Initialize()
{
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL ret ;
        
        
        //NSArray *paths;
        NSString *path;
        NSError *error;
        //cache <Application_Home>/Library/Caches
        path = OTF_PathForDirDomain0(OTF_Cache);
        ret = [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if ( !ret )
        {
            @throw [[NSException alloc] initWithName:[error localizedDescription] reason:[error localizedFailureReason] userInfo:nil];
        }
        OTF_AddSkipBackupAttributeToItemAtPath(path);
        
        
        //Temp <Application_Home>/tmp
        path = OTF_PathForDirDomain0(OTF_Temp);
        ret = [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if ( !ret )
        {
            @throw [[NSException alloc] initWithName:[error localizedDescription] reason:[error localizedFailureReason] userInfo:nil];
        }
        OTF_AddSkipBackupAttributeToItemAtPath(path);
        
        
        //Documents   <Application_Home>/Documents
        path = OTF_PathForDirDomain0(OTF_Documents);
        ret = [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if ( !ret )
        {
            @throw [[NSException alloc] initWithName:[error localizedDescription] reason:[error localizedFailureReason] userInfo:nil];
        }
        OTF_RemoveSkipBackupAttributeToItemAtPath(path);
        
        
        
        //<Application_Home>/Library/
        path = (NSString *)NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
        OTF_RemoveSkipBackupAttributeToItemAtPath(path);
        
        
        //PrivateDocuments   <Application_Home>/Library/PrivateDocuments
        path = OTF_PathForDirDomain0(OTF_PrivateDoucuments);
        ret = [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if ( !ret )
        {
            @throw [[NSException alloc] initWithName:[error localizedDescription] reason:[error localizedFailureReason] userInfo:nil];
        }
        OTF_AddSkipBackupAttributeToItemAtPath(path);
        
        
        
        
        //PrivateICloud   <Application_Home>/Library/PrivateIClound
        path = OTF_PathForDirDomain0(OTF_PrivateICloud);
        ret = [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if ( !ret )
        {
            @throw [[NSException alloc] initWithName:[error localizedDescription] reason:[error localizedFailureReason] userInfo:nil];
        }
        OTF_RemoveSkipBackupAttributeToItemAtPath(path);
        
    });
    
    
    
    
}



NSString * OTF_PathForDirDomain(OTFDirDomain aDirDomain)
{
    OTF_Initialize();
    return OTF_PathForDirDomain0(aDirDomain);
}


NSString * OTF_UniqueIdentifier(NSString *aIdentifer)
{
    OTF_Initialize();
    
    NSString *identifier = [NSString stringWithFormat:@"%@.%@" , aIdentifer  , [[NSUUID UUID] UUIDString] ];
    return identifier;
}

OTFileAutoRemoved * OTF_CreateTempFile()
{
    NSString *name = [NSString stringWithFormat:@"%lf" , [[NSDate date] timeIntervalSince1970] ] ;
    name = OTF_UniqueIdentifier(name);
    const char *cStr = [name UTF8String];
	unsigned char result[16];
	CC_MD5( cStr, (CC_LONG)strlen(cStr), result);
    NSString *md5 = [NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
    
    return OTF_CreateTempFileForIdentifier(md5 , YES);

}

OTFileAutoRemoved * OTF_CreateTempFileForIdentifier(NSString *aIdentifer , BOOL aOverwrite)
{
    OTF_Initialize();
    
    //NSString *tmp = OTF_PathForDirDomain(OTF_Temp);
    //[tmp stringByAppendingPathComponent:ReservedDir];
    
    NSString *dirPath =  OTF_PathForDirDomain(OTF_Temp_Reserved);
    
    BOOL ret ;
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];
    ret = [fm createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
    
    if ( !ret )
    {
        @throw [[NSException alloc] initWithName:[error localizedDescription] reason:[error localizedFailureReason] userInfo:nil];
    }
    
    NSString *filePath = [dirPath stringByAppendingPathComponent:aIdentifer];
    
    
    if ( !aOverwrite && [fm fileExistsAtPath:filePath] )
    {
        //do nothing.
    }else
    {
        [fm createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    OTFileAutoRemoved *file = [[OTFileAutoRemoved alloc] init];
    file.path = filePath;
    return file;
}

OTFile * OTF_CreatePrivatePersistentFileForIdentifier(NSString *aIdentifer , BOOL aOverwrite)
{
    OTF_Initialize();
    
    //NSString *tmp = OTF_PathForDirDomain(OTF_PrivateDoucuments);
    //[tmp stringByAppendingPathComponent:ReservedDir];
    NSString *dirPath = OTF_PathForDirDomain(OTF_PrivateDoucuments_Reserved);
   
    BOOL ret ;
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];
    ret = [fm createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
    
    if ( !ret )
    {
        @throw [[NSException alloc] initWithName:[error localizedDescription] reason:[error localizedFailureReason] userInfo:nil];
    }
    
    
    NSString *filePath = [dirPath stringByAppendingPathComponent:aIdentifer];
    
    if ( !aOverwrite && [fm fileExistsAtPath:filePath] )
    {
        //do nothing.
    }else
    {
         [fm createFileAtPath:filePath contents:nil attributes:nil];
    }   
    
    OTFile *file = [[OTFile alloc] init];
    file.path = filePath;
    return file;
}

BOOL OTF_FileExistsAtPath(NSString *aPath , BOOL *isDir)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm fileExistsAtPath:aPath isDirectory:isDir];
}

OTFile * OTF_CreateFile(NSString *aFilePath , BOOL aOverwrite)
{
    OTF_Initialize();
    
    NSString *dirPath = [aFilePath stringByDeletingLastPathComponent];
    
    BOOL ret ;
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];
    ret = [fm createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
    
    if ( !ret )
    {
        @throw [[NSException alloc] initWithName:[error localizedDescription] reason:[error localizedFailureReason] userInfo:nil];
    }
    
    
    //NSString *filePath = [dirPath stringByAppendingPathComponent:aIdentifer];
    
    if ( !aOverwrite && [fm fileExistsAtPath:aFilePath] )
    {
        //do nothing.
    }else
    {
        [fm createFileAtPath:aFilePath contents:nil attributes:nil];
    }
    
    OTFile *file = [[OTFile alloc] init];
    file.path = aFilePath;
    return file;
}

void OTF_CreateDir( NSString *aPath)
{
    OTF_Initialize();
    
    BOOL ret ;
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];

//    BOOL isDir;
//    ret = [fm fileExistsAtPath:aPath isDirectory:&isDir];
//    if (ret && isDir)
//    {
//        return ;
//    }
    
    ret = [fm createDirectoryAtPath:aPath withIntermediateDirectories:YES attributes:nil error:&error];
    
    if ( !ret )
    {
        @throw [[NSException alloc] initWithName:[error localizedDescription] reason:[error localizedFailureReason] userInfo:nil];
    }
}
void OTF_MoveItem(NSString *aSrcPath , NSString *aToPath)
{
    OTF_Initialize();
    
    BOOL ret ;
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if ([fm fileExistsAtPath:aToPath] )
    {
        ret = [fm removeItemAtPath:aToPath error:&error];
        if ( !ret )
        {
            @throw [[NSException alloc] initWithName:[error localizedDescription] reason:[error localizedFailureReason] userInfo:nil];
        }
    }
    
    
    NSString *dirPath = [aToPath stringByDeletingLastPathComponent];
    
    ret = [fm createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
    if ( !ret )
    {
        @throw [[NSException alloc] initWithName:[error localizedDescription] reason:[error localizedFailureReason] userInfo:nil];
    }

    
    ret = [fm moveItemAtPath:aSrcPath toPath:aToPath error:&error];
    if ( !ret )
    {
        @throw [[NSException alloc] initWithName:[error localizedDescription] reason:[error localizedFailureReason] userInfo:nil];
    }
    
}

void OTF_RemoveItem(NSString *aPath)
{
    OTF_Initialize();
    
    BOOL ret ;
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:aPath] )
    {
        ret = [fm removeItemAtPath:aPath error:&error];
        if ( !ret )
        {
            @throw [[NSException alloc] initWithName:[error localizedDescription] reason:[error localizedFailureReason] userInfo:nil];
        }
    }
    
}
