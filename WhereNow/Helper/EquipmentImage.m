//
//  EquipmentImage.m
//  WhereNow
//
//  Created by Xiaoxue Han on 25/09/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "EquipmentImage.h"

@implementation EquipmentImage

+ (NSString *)getCacheDirectoryPath
{
    //NSString *path = NSTemporaryDirectory();
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSString *dataPath = [path stringByAppendingPathComponent:@"/tmp"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
        if (error) {
            NSLog(@"error occurred in create tmp folder : %@", [error localizedDescription]);
        }
    }
    return dataPath;
}



+ (NSString *)uniqueImageName
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    NSString *uniqueFileName = [NSString stringWithFormat:@"%@.PNG", (__bridge NSString *)uuidString];
    CFRelease(uuidString);
    
    NSString *strPath = [EquipmentImage getCacheDirectoryPath];
    NSString *filePath = [strPath stringByAppendingPathComponent:uniqueFileName];
    return filePath;
}


+ (void)setModelImageOfEquipment:(Equipment *)equipment toImageView:(UIImageView *)iv completed:(void (^)(UIImage *))completionBlock
{
    UIImage *localImage = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:equipment.model_file_location_local])
    {
        NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:equipment.model_file_location_local]];
        localImage = [UIImage imageWithData:data];
    }
    if (localImage != nil)
    {
        [iv setImage:localImage];
        if (completionBlock)
            completionBlock(localImage);
    }
    else
    {
        [[ServerManager sharedManager] setImageContent:iv urlString:equipment.model_file_location success:^(UIImage *image) {
            
            if (image == nil)
                return;
            
            // create local file
            NSString *localPath = [EquipmentImage uniqueImageName];
            NSData *imageData = UIImagePNGRepresentation(image);
            [imageData writeToFile:localPath atomically:YES];
            dispatch_async(dispatch_get_main_queue(), ^() {
                equipment.model_file_location_local = localPath;
                [[ModelManager sharedManager] saveContext];
            });
            
            if (completionBlock)
                completionBlock(image);
        }];
    }

}

+ (void)setManufacturerImageOfEquipment:(Equipment *)equipment toImageView:(UIImageView *)iv completed:(void (^)(UIImage *))completionBlock
{
    UIImage *localImage = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:equipment.manufacturer_file_location_local])
    {
        NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:equipment.manufacturer_file_location_local]];
        localImage = [UIImage imageWithData:data];
    }
    if (localImage != nil)
    {
        [iv setImage:localImage];
        if (completionBlock)
            completionBlock(localImage);
    }
    else
    {
        [[ServerManager sharedManager] setImageContent:iv urlString:equipment.manufacturer_file_location success:^(UIImage *image) {
            
            if (image == nil)
                return;
            
            // create local file
            NSString *localPath = [EquipmentImage uniqueImageName];
            NSData *imageData = UIImagePNGRepresentation(image);
            [imageData writeToFile:localPath atomically:YES];
            dispatch_async(dispatch_get_main_queue(), ^() {
                equipment.manufacturer_file_location_local = localPath;
                [[ModelManager sharedManager] saveContext];
            });
            
            if (completionBlock)
                completionBlock(image);
        }];
    }
    
}

@end
