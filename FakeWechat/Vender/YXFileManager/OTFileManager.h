//
//  OTFileManager.h
//  FileSystemSample
//
//  Created by ruwei on 14-4-2.
//  Copyright (c) 2014年 ruwei. All rights reserved.
//

#import <Foundation/Foundation.h>
BOOL OTF_AddSkipBackupAttributeToItemAtPath(NSString *aPath);
BOOL OTF_RemoveSkipBackupAttributeToItemAtPath(NSString *aPath);

@interface OTFile : NSObject

@property (readonly , nonatomic , strong) NSString *path;

- (void)remove;
@end


@interface OTFileAutoRemoved : OTFile

@end


typedef NS_OPTIONS(NSUInteger, OTFDirDomain)
{
    OTF_Cache = 1,                      //cache用，空间紧张的时候，会被自动删除。<Application_Home>/Library/Caches
    OTF_Temp ,                          //用于创建临时文件。<Application_Home>/tmp
    OTF_Temp_Reserved ,                 //<Application_Home>/tmp/<ReservedDir> 目录。用于快速建立临时文件
    
    //下面都是不会被删除
    OTF_Documents ,                     //<Application_Home>/Documents  会被ICloud的。
    OTF_PrivateDoucuments ,             //<Application_Home>/Library/PrivateDocuments  不会ICloud
    OTF_PrivateDoucuments_Reserved ,    //<Application_Home>/Library/PrivateDocuments/<ReservedDir> 目录。用于快速创建配置文件等。不会ICloud
    OTF_PrivateICloud ,                 //<Application_Home>/Library/PrivateICloud   会被ICloud
};

@class OTFileAutoRemoved;
@class OTFile;


void OTF_Initialize();

NSString * OTF_PathForDirDomain(OTFDirDomain aDirDomain);



NSString * OTF_UniqueIdentifier(NSString *aIdentifer);

//在OTF_Temp ，OTF_PrivateDoucments 下面的 <ReservedDir> 目录下面快速的建立文件。
OTFileAutoRemoved * OTF_CreateTempFile();
OTFileAutoRemoved * OTF_CreateTempFileForIdentifier(NSString *aIdentifer , BOOL aOverwrite);
OTFile * OTF_CreatePrivatePersistentFileForIdentifier(NSString *aIdentifer , BOOL aOverwrite);

BOOL OTF_FileExistsAtPath(NSString *aPath , BOOL *isDir);

OTFile * OTF_CreateFile(NSString *aFilePath , BOOL aOverwrite);
void OTF_CreateDir( NSString *aPath);
void OTF_MoveItem(NSString *aSrcPath , NSString *aToPath);
void OTF_RemoveItem(NSString *aPath);


