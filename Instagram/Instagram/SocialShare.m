//
//  SocialShare.m
//  EmergencyPRO
//
//  Created by Optisol on 31/07/18.
//  Copyright © 2018 OBSMACMINI2. All rights reserved.
//

#import "SocialShare.h"
#import <Photos/Photos.h>
#import "MBProgressHUD.h"

@interface SocialShare () {
    
}

@end

@implementation SocialShare

typedef void (^CreateAssetCompletionHandler) (NSString *localId);
typedef void (^GetAssetCompletionHandler) (NSURL *assetURL);


-(UIImage *)getThumbnailFromVideo:(NSURL *)videoURL {
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    CMTime time = CMTimeMake(1, 1);
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    return thumbnail;
}


-(UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

-(void)showAlert:(NSString*)title withMessage:(NSString*)msg {
    
    if (!title || [title isEqual: @"" ]) {
        title = @"Error";
    }
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertView addAction:okAction];
    [[self topMostController]presentViewController:alertView animated:YES completion:nil];
}



-(void)openInstagramForURL:(NSURL *)url {
    
    NSString *escapedString = [url.absoluteString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    NSURL *instagramURL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://library?AssetPath=%@", escapedString]];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
            [[UIApplication sharedApplication] openURL:instagramURL];
        } else {
            [self showAlert:nil withMessage:@"Instagram app not found"];
        }
    });
}

-(void)video:(NSURL *)videoUrl completionHandler:(CreateAssetCompletionHandler)completionHandler {
    
    __block NSString* localId;
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest * assetReq = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoUrl];
        localId = [[assetReq placeholderForCreatedAsset] localIdentifier];
    } completionHandler:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"%@",error);
            [self showAlert:nil withMessage:@"Video format not support"];
        } else {
            completionHandler(localId);
        }
    }];
}

-(void)getAssetURLForVideoURL:(NSURL*)videoUrl vc:(UIViewController *)vc assetURL:(GetAssetCompletionHandler)assetURL {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:vc.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = @"Downloading Video..";
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        NSData *yourVideoData=[NSData dataWithContentsOfURL:videoUrl];
        
        if (yourVideoData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:vc.view animated:YES];
            });
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];//m3u8
            NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"video.mov"];
            //@"video.mp4"
            if([yourVideoData writeToFile:filePath atomically:YES]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self video:[NSURL fileURLWithPath:filePath] completionHandler:^(NSString *localId) {
                        assetURL([NSURL URLWithString:localId]);
                    }];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideAllHUDsForView:vc.view animated:YES];
                });
                NSLog(@"write failed");
            }
        }
    });
}

-(void)executeInstagramShare:(NSString *)fileType image:(UIImage *)image videoUrl:(NSURL *)videoUrl fromViewController:(UIViewController *)viewController locationString:(NSString *)locationString {
    if ([fileType isEqualToString:@"video"]) {
        [self getAssetURLForVideoURL:videoUrl vc:viewController assetURL:^(NSURL *assetURL) {
            [self openInstagramForURL:assetURL];
        }];
    }else{
        __block NSString* localId;
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest * assetReq = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            localId = [[assetReq placeholderForCreatedAsset] localIdentifier];
        } completionHandler:^(BOOL success, NSError *error) {
            if (!success){
                NSLog(@"%@",error);
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *escapedString = [localId stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
                    NSURL *instagramURL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://library?AssetPath=%@", escapedString]];
                    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
                        [[UIApplication sharedApplication] openURL:instagramURL];
                    } else {
                        [self showAlert:nil withMessage:@"Instagram app not found"];
                    }
                });
            }
        }];
    }
}


@end
