//
//  SocialShare.h
//  EmergencyPRO
//
//  Created by Optisol on 31/07/18.
//  Copyright © 2018 OBSMACMINI2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SocialShare : NSObject

-(void)executeFacebookShare:(NSString *)fileType image:(UIImage *)image videoUrl:(NSURL *)videoUrl fromViewController:(UIViewController *)viewController locationString:(NSString *)locationString;
-(void)executeTwitterShareFromViewController:(UIViewController *)viewController fileType:(NSString *)fileType image:(UIImage *)image videoUrl:(NSURL *)videoUrl locationString:(NSString *)locationString;
-(void)executeInstagramShare:(NSString *)fileType image:(UIImage *)image videoUrl:(NSURL *)videoUrl fromViewController:(UIViewController *)viewController locationString:(NSString *)locationString;

@end
