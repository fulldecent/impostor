//
//  cachedPersistentImageStore.m
//  Impostor
//
//  Created by William Entriken on 10/5/14.
//  Copyright (c) 2014 William Entriken. All rights reserved.
//

#import "CachedPersistentJPEGImageStore.h"

@interface CachedPersistentJPEGImageStore()
@property (nonatomic) NSMutableDictionary *cachedImages;
- (NSURL *)urlForImageWithName:(NSString *)name;
@end

@implementation CachedPersistentJPEGImageStore

- (NSMutableDictionary *)cachedImages
{
    if (!_cachedImages) {
        _cachedImages = [NSMutableDictionary dictionary];
    }
    return _cachedImages;
}

- (NSURL *)urlForImageWithName:(NSString *)name
{
    NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSString *fileName = [NSString stringWithFormat:@"imagecache-%@.jpg", name];
    return [[urls lastObject] URLByAppendingPathComponent:fileName];
}

- (void)saveImage:(UIImage *)image withName:(NSString *)name
{
    (self.cachedImages)[name] = image;
    [UIImageJPEGRepresentation(image, 0.9) writeToURL:[self urlForImageWithName:name] atomically:YES];
}

- (UIImage *)imageWithName:(NSString *)name
{
#if TARGET_IPHONE_SIMULATOR
    if ([name isEqualToString:@"1"])
        return [UIImage imageWithContentsOfFile:@"/Users/williamentriken/Developer/Impostor media/1.jpg"];
    if ([name isEqualToString:@"2"])
        return [UIImage imageWithContentsOfFile:@"/Users/williamentriken/Developer/Impostor media/4.jpg"];
    if ([name isEqualToString:@"3"])
        return [UIImage imageWithContentsOfFile:@"/Users/williamentriken/Developer/Impostor media/2.jpg"];
    if ([name isEqualToString:@"4"])
        return [UIImage imageWithContentsOfFile:@"/Users/williamentriken/Developer/Impostor media/3.jpg"];
    if ([name isEqualToString:@"0"])
        return [UIImage imageWithContentsOfFile:@"/Users/williamentriken/Developer/Impostor media/5.jpg"];
    return nil;
#endif
    
    if ((self.cachedImages)[name]) {
        return (self.cachedImages)[name];
    }
    
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[self urlForImageWithName:name]]];
}

- (void)deleteImageWithName:(NSString *)name
{
    [self.cachedImages removeObjectForKey:name];
    NSURL *url = [self urlForImageWithName:name];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:url error:nil];
}

- (void)deleteAllImages
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSArray *directoryContents = [fileManager contentsOfDirectoryAtURL:[urls lastObject] includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    for (NSURL *url in directoryContents) {
        if ([[url lastPathComponent] hasPrefix:@"imagecache-"])
            [fileManager removeItemAtURL:url error:nil];
    }
}

- (void)clearCache
{
    self.cachedImages = nil;
}

+ (CachedPersistentJPEGImageStore *)sharedStore
{
    static CachedPersistentJPEGImageStore *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CachedPersistentJPEGImageStore alloc] init];
    });
    return sharedInstance;
}

@end
