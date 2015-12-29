//
//  SCUserImageController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 30.11.13.
//
//

#import <UIKit/UIKit.h>

@interface SCUserImageController : UIViewController

/** Userid to display the userimage
 */
 
@property(nonatomic, strong) NSString       *userid;

/** ImageView to display the userimage
 */
@property(nonatomic, weak) IBOutlet UIImageView         *userimageView;

-(IBAction)actionMenu:(id)sender;

@end
