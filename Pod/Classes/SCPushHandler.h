//
//  SCPushHandler.h
//  C2CallPhone
//
//  Created by Michael Knecht on 13.09.14.
//
//

#import <Foundation/Foundation.h>

@interface SCPushHandler : NSObject

- (instancetype)initWithPushTypes:(NSSet *) pushTypes andPushAction:(void (^)(NSString *payloadType, NSDictionary *pushPaylod))action;

-(void) setPushAction:(void (^)(NSString *payloadType, NSDictionary *pushPaylod))action;
-(void) dispose;

@end
