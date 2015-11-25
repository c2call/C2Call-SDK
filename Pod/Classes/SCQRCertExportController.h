//
//  SCQRCertExportController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 24.02.14.
//
//

#import <UIKit/UIKit.h>

@interface SCQRCertExportController : UIViewController

@property(nonatomic, weak) IBOutlet UIImageView    *qrcodeImageView;

-(IBAction)shareKeysViaEmail:(id) sender;

@end
