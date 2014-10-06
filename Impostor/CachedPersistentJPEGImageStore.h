//
//  cachedPersistentImageStore.h
//  Impostor
//
//  Created by William Entriken on 10/5/14.
//  Copyright (c) 2014 William Entriken. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CachedPersistentJPEGImageStore : NSObject
- (void)saveImage:(UIImage *)image withName:(NSString *)name;
- (UIImage *)imageWithName:(NSString *)name;
- (void)deleteImageWithName:(NSString *)name;
- (void)deleteAllImages;
- (void)clearCache;

+ (CachedPersistentJPEGImageStore *)sharedStore;
@end
