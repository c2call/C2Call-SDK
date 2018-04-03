//
//  SCLoyaltyCampaign.h
//  C2CallPhone
//
//  Created by Michael Knecht on 19.03.18.
//

#import <Foundation/Foundation.h>

#import "SCVendor.h"

#define C2CAMPAIGN_ELEM_CampaignDescription @"CampaignDescription"
#define C2CAMPAIGN_ELEM_Address @"Address"
#define C2CAMPAIGN_ELEM_OpeningHours @"OpeningHours"
#define C2CAMPAIGN_ELEM_Reward @"Reward"
#define C2CAMPAIGN_ELEM_ImageRef @"ImageRef"
#define C2CAMPAIGN_ELEM_VideoRef @"VideoRef"
#define C2CAMPAIGN_ELEM_UrlRef @"UrlRef"
#define C2CAMPAIGN_ELEM_Tag @"Tag"
#define C2CAMPAIGN_ELEM_Location @"Location"
#define C2CAMPAIGN_ELEM_InfoElement @"InfoElement"


#define C2CAMPAIGN_ATTR_CampaignType @"CampaignType"
#define C2CAMPAIGN_ATTR_FeaturedContentAction @"FeaturedContentAction"
#define C2CAMPAIGN_ATTR_ExpireDate @"ExpireDate"
#define C2CAMPAIGN_ATTR_TimelineId @"TimelineId"
#define C2CAMPAIGN_ATTR_CampaignId @"CampaignId"
#define C2CAMPAIGN_ATTR_CampaignName @"CampaignName"
#define C2CAMPAIGN_ATTR_VendorId @"VendorId"
#define C2CAMPAIGN_ATTR_OwnerId @"OwnerId"
#define C2CAMPAIGN_ATTR_Active @"Active"
#define C2CAMPAIGN_ATTR_DBTStamp @"DBTStamp"
#define C2CAMPAIGN_ATTR_TargetLocation @"TargetLocation"

#define C2CAMPAIGN_VALUE_CampaignType_CMP_LOCAL_CAMPAIGN @"CMP_LOCAL_CAMPAIGN"
#define C2CAMPAIGN_VALUE_CampaignType_CMP_ONLINE_CAMPAIGN @"CMP_ONLINE_CAMPAIGN"
#define C2CAMPAIGN_VALUE_CampaignType_CMP_IMAGE_CAMPAIN @"CMP_IMAGE_CAMPAIN"

#define C2CAMPAIGN_VALUE_TargetLocation_WorldWide @"WorldWide"
#define C2CAMPAIGN_VALUE_TargetLocation_CountryWide @"CountryWide"
#define C2CAMPAIGN_VALUE_TargetLocation_LocationBased @"LocationBased"

#define C2CAMPAIGN_VALUE_FeaturedContentAction_AC_DEAL_DETAILS @"AC_DEAL_DETAILS"
#define C2CAMPAIGN_VALUE_FeaturedContentAction_AC_PRODUCT_INFO @"AC_PRODUCT_INFO"
#define C2CAMPAIGN_VALUE_FeaturedContentAction_AC_CHAT @"AC_CHAT"
#define C2CAMPAIGN_VALUE_FeaturedContentAction_AC_CONTACT @"AC_CONTACT"

#define C2REWARD_ELEM_RewardRule @"RewardRule"
#define C2REWARD_ELEM_WatchPoints @"WatchPoints"
#define C2REWARD_ELEM_PickupPoints @"PickupPoints"
#define C2REWARD_ELEM_TotalWatchPoints @"TotalWatchPoints"
#define C2REWARD_ELEM_TotalPickupPoints @"TotalPickupPoints"
#define C2REWARD_ELEM_MaxWatchesPerUser @"MaxWatchesPerUser"

#define C2REWARD_ATTR_RewardKey @"RewardKey"
#define C2REWARD_ATTR_RewardType @"RewardType"

#define C2REWARD_VALUE_RewardType_RWD_NONE @"RWD_NONE"
#define C2REWARD_VALUE_RewardType_RWD_WATCH_ONLY @"RWD_WATCH_ONLY"
#define C2REWARD_VALUE_RewardType_RWD_WATCH_AND_PICKUP @"RWD_WATCH_AND_PICKUP"
#define C2REWARD_VALUE_RewardType_RWD_PICKUP_ONLY @"RWD_PICKUP_ONLY"


@interface SCLoyaltyCampaign : SCLoyaltyBase

@property(strong, nonatomic, readonly, nullable) NSString           *campaignId;
@property(strong, nonatomic, nullable) NSString                     *campaignName;
@property(strong, nonatomic, nullable) NSString                     *campaignDescription;
@property(strong, nonatomic, nullable) NSString                     *country;
@property(strong, nonatomic, nullable) NSString                     *city;
@property(strong, nonatomic, nullable) NSString                     *address;
@property(strong, nonatomic, nullable) NSString                     *zipCode;
@property(strong, nonatomic, nullable) NSString                     *street;
@property(strong, nonatomic, nullable) NSString                     *region;
@property(strong, nonatomic, readonly, nullable) NSString           *vendorId;
@property(strong, nonatomic, readonly, nullable) NSString           *ownerId;
@property(nonatomic, readonly) BOOL                                 active;
@property(nonatomic, readonly) UInt64                               timelineId;
@property(strong, nonatomic, nullable) NSDate                       *expireDate;
@property(strong, nonatomic, nullable) NSString                     *featuredContentAction;
@property(strong, nonatomic, nullable) NSString                     *campaignType;
@property(strong, nonatomic, nullable) NSString                     *campaignUrl;
@property(strong, nonatomic, nullable) NSString                     *openingHours;
@property(strong, nonatomic, nullable) NSString                     *rewardRule;
@property(strong, nonatomic, nullable) NSString                     *rewardType;
@property(nonatomic) NSInteger                                      rewardWatchPoints;
@property(nonatomic) NSInteger                                      rewardPickupPoints;
@property(nonatomic) NSInteger                                      rewardTotalWatchPoints;
@property(nonatomic) NSInteger                                      rewardTotalPickupPoints;
@property(nonatomic) NSInteger                                      rewardMaxWatchesPerUser;

@property(nonatomic) double                                         campaignLocationLatitude;
@property(nonatomic) double                                         campaignLocationLongitude;
@property(nonatomic) NSInteger                                      campaignLocationRadius;
@property(strong, nonatomic, nullable) NSString                     *campaignLocationName;
@property(strong, nonatomic, nullable) NSString                     *campaignLocationTarget;

/** The Teaser Image is the main image of the Campaign
    It will also shown in the timeline as thumbnail for the video
 */
@property(strong, nonatomic, nullable) UIImage                      *campaignTeaserImage;

/** allother cmapaign images
 */
@property(strong, nonatomic, nullable, readonly) NSArray<UIImage *> *campaignImages;

/** The actual campaign video
 */
@property(strong, nonatomic, nullable) NSURL                        *campaignVideo;

/** On interaction with the server, the last error will be reported here
 */
@property(strong, nonatomic, nullable) NSString                     *errorDescription;
@property(nonatomic) NSInteger                                      errorCode;

@property(strong, nonatomic, nullable, readonly) NSArray<NSString *> *campaignTags;


- (instancetype _Nullable )initWithDictionary:(NSDictionary *_Nonnull) properties;

-(void) addCampaignImage:(UIImage *_Nonnull) image;
-(void) removeCampaignImage:(UIImage *_Nonnull) image;
-(void) removeAllCampaignImages;

/** return YES if images need to be uploaded
 */
-(BOOL) shouldUploadImages;
/** uploadImagesWithCompletionHandler will be automatically called on save campaign if
    images need to be uploaded. However, this method can be called directly for more control on the upload process.
    saveCampain must be called then after uploading images to keep the meta data in sync
*/
-(BOOL) uploadImagesWithCompletionHandler:(nullable void (^)(BOOL success)) completion;


/** returns YES if the video needs to be uploaded
 */
-(BOOL) shouldUploadVideo;

/** uploadVideoWithCompletionHandler will be automatically called on save campaign if
 the video needs to be uploaded. However, this method can be called directly for more control on the upload process.
 saveCampain must be called then after uploading the video to keep the meta data in sync
 */
-(BOOL) uploadVideoWithCompletionHandler:(nullable void (^)(BOOL success)) completion;

/** saveCampaignWithCompletionHandler automatically uploads image and video content first if necessary and then
    saves the campaign to the server.
    In cases images or video has been changed, the modified images or video will be uploaded accordingly.
 */
-(BOOL) saveCampaignWithCompletionHandler:(nullable void (^)(BOOL success)) completion;
-(void) reloadCampaignDataWithCompletionHandler:(void (^_Nullable)(BOOL success)) completion loadMediafiles:(BOOL) loadMedia;

// Retrieve Mediafiles from server if not locally available
-(BOOL) loadCampaignMediaWithCompletionHandler:(void (^_Nullable)(BOOL success)) completion;

/** activateCampaign will actually release the campaign to the public and will create a featured timeline item
    This method does a server side call, so don't use in main thread
 */
-(BOOL) activateCampaign;

/** deActiveCampaign will stop the campaign and remove the campaign from the featured timeline content
 This method does a server side call, so don't use in main thread
 */
-(BOOL) deActivateCampaign;

/** Provides the campaign values in dictionary format
 */
-(NSDictionary *_Nullable) campaignDictionary;

+(void) campaignWithCampaignId:(NSString *_Nonnull) campaignId completion:(nonnull void (^)(SCLoyaltyCampaign * _Nullable campaign)) completion;

@end
