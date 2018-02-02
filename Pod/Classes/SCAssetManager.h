//
//  SCAssetManager.h
//  C2CallPhone
//
//  Created by Michael Knecht on 06/12/15.
//
//

#import <Foundation/Foundation.h>

@interface SCAssetManager : NSObject

@property(nonatomic, strong) NSBundle      *imageBundle;

+(instancetype) instance;

-(UIImage *) imageForName:(NSString *) imageName;

@end
