//
//  C2BlockAction.h
//  C2CallPhone
//
//  Created by Michael Knecht on 07.05.12.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

/** C2BlockAction allows assigning an Action Block to a C2BlockAction object, which will be actually executed on fireAction.
 
 This is a helper class, which will be used in several C2Call API Classes.
 
 */
@interface C2BlockAction : NSObject 

/** @name Initialization */
/** Initializes C2BlockAction with an Action Block.
 
 @param action - The Action Block
 
 */
-(id) initWithAction:(void (^)(id sender))action;

/** @name Actions */
/** Executes the Action Block.
 
 @param sender - The initiator of the ACtion
 */
-(IBAction)fireAction:(id)sender;

/** @name Static Methods */
/** Creates a C2BlockAction Instance with an Action Block.
 @param action - The Action Block
 */
+(id) actionWithAction:(void (^)(id sender))action;

@end
