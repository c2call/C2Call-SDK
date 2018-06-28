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
#define C2CAMPAIGN_ELEM_CampaignVoucher @"CampaignVoucher"
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
#define C2CAMPAIGN_ATTR_ReviewRequired @"ReviewRequired"
#define C2CAMPAIGN_ATTR_DBTStamp @"DBTStamp"
#define C2CAMPAIGN_ATTR_TargetLocation @"TargetLocation"
#define C2CAMPAIGN_ATTR_Publication @"Publication"

#define C2CAMPAIGN_VALUE_Publicatio_PUB_Automatic @"PUB_Automatic"
#define C2CAMPAIGN_VALUE_Publicatio_PUB_Manual @"PUB_Manual"

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

#define C2CAMPAIGNVOUCHER_ATTR_Uploaded @"Uploaded"
#define C2CAMPAIGNVOUCHER_ATTR_VoucherType @"VoucherType"
#define C2CAMPAIGNVOUCHER_ATTR_VoucherCode @"VoucherCode"

#define C2REWARD_VALUE_RewardType_RWD_NONE @"RWD_NONE"
#define C2REWARD_VALUE_RewardType_RWD_WATCH_ONLY @"RWD_WATCH_ONLY"
#define C2REWARD_VALUE_RewardType_RWD_WATCH_AND_PICKUP @"RWD_WATCH_AND_PICKUP"
#define C2REWARD_VALUE_RewardType_RWD_PICKUP_ONLY @"RWD_PICKUP_ONLY"


typedef NS_ENUM(NSUInteger, SCCampaignQRCodeError)
{
    CMP_REASON_SUCCESS = 0,
    CMP_REASON_CAMPAIGN_EXPIRED = 1,
    CMP_REASON_NOT_ENOUGH_POINTS = 2,
    CMP_REASON_NOT_WATCHED = 3,
    CMP_REASON_INVALID_LOCATION = 4,
    CMP_REASON_QRCODE_EXPIRED = 5,
    CMP_REASON_QRCODE_INVALID = 6,
    CMP_REASON_POINTS_ALREADY_PICKED_UP = 7,
    CMP_REASON_REDEEM_ERROR = 8,
    CMP_REASON_NO_LOCATION = 9
};

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
@property(nonatomic, readonly) BOOL                                 videoActive;
@property(nonatomic, readonly) BOOL                                 reviewRequired;
@property(nonatomic, readonly) UInt64                               timelineId;
@property(strong, nonatomic, nullable) NSDate                       *expireDate;
@property(strong, nonatomic, nullable) NSString                     *publication;
@property(strong, nonatomic, nullable) NSString                     *featuredContentAction;
@property(strong, nonatomic, nullable) NSString                     *campaignType;
@property(strong, nonatomic, nullable) NSString                     *campaignUrl;
@property(strong, nonatomic, nullable) NSString                     *openingHours;
@property(strong, nonatomic, nullable) NSString                     *rewardRule;
@property(strong, nonatomic, nullable) NSString                     *rewardType;
@property(strong, nonatomic, nullable) NSString                     *voucherType;
@property(strong, nonatomic, nullable) NSString                     *voucherCode;
@property(nonatomic) NSInteger                                      rewardWatchPoints;
@property(nonatomic) NSInteger                                      rewardPickupPoints;
@property(nonatomic) NSInteger                                      rewardTotalWatchPoints;
@property(nonatomic) NSInteger                                      rewardTotalPickupPoints;
@property(nonatomic) NSInteger                                      rewardMaxWatchesPerUser;
@property(nonatomic) NSInteger                                      totalPointsWatched;
@property(nonatomic) NSInteger                                      totalPointsPickedUp;
@property(nonatomic) NSInteger                                      remainingWatchPoints;
@property(nonatomic) NSInteger                                      remainingPickupPoints;

@property(nonatomic) double                                         campaignLocationLatitude;
@property(nonatomic) double                                         campaignLocationLongitude;
@property(nonatomic) NSInteger                                      campaignLocationRadius;
@property(strong, nonatomic, nullable) NSString                     *campaignLocationName;
@property(strong, nonatomic, nullable) NSString                     *campaignLocationTarget;

/** The Teaser Image is the thumbnail for the video
 */
@property(strong, nonatomic, nullable) UIImage                      *campaignTeaserImage;
@property(nonatomic, nullable, readonly) NSString                   *campaignTeaserImageKey;

/** The Main Image is the front image of the campaign
 */
@property(strong, nonatomic, nullable) UIImage                      *campaignMainImage;
@property(nonatomic, nullable, readonly) NSString                   *campaignMainImageKey;


/** allother cmapaign images
 */
@property(strong, nonatomic, nullable, readonly) NSArray<UIImage *> *campaignImages;
@property(nonatomic, nullable, readonly) NSArray<NSString *>        *campaignImagesKeys;

/** The actual campaign video
 */
@property(strong, nonatomic, nullable) NSURL                        *campaignVideo;
@property(nonatomic, nullable, readonly) NSString                   *campaignVideoKey;

/** On interaction with the server, the last error will be reported here
 */
@property(strong, nonatomic, nullable) NSString                     *errorDescription;
@property(nonatomic) NSInteger                                      errorCode;

@property(strong, nonatomic, nullable, readonly) NSArray<NSString *> *campaignTags;


- (instancetype _Nullable )initWithDictionary:(NSDictionary *_Nonnull) properties;

/**
 * Use this to update an existing campaign from dictionary values
 */
-(void) setCampaignFromDictionary:(NSDictionary *) dict;

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
-(BOOL) updateCampaignStatusWithCompletionHandler:(nonnull void (^)(NSDictionary<NSString *, id> * _Nullable status)) completion;

/** Upload a list of VoucherCodes for an Online Cmapaign */
-(void) uploadCampaignVoucherList:(nonnull NSArray<NSString *> *)voucherList with:(nullable void (^)(NSInteger resultCode, NSString *comment)) completion;


/** Retrieve a voucherCode from an Online Campaign for a user (use an async call) */
-(NSString *) getCampaignVoucherForUser:(NSString *) userid;


// Retrieve Mediafiles from server if not locally available
-(BOOL) loadCampaignMediaWithCompletionHandler:(void (^_Nullable)(BOOL success)) completion;

/** Deleting the Campaign (only for Inactive Campaigns */
-(BOOL) deleteCampaign;

/** activateCampaign will actually release the campaign to the public and will create a featured timeline item
    This method does a server side call, so don't use in main thread
 */
-(BOOL) activateCampaign;

/** deActiveCampaign will stop the campaign and remove the campaign from the featured timeline content
 This method does a server side call, so don't use in main thread
 */
-(BOOL) deActivateCampaign;

/** Reset Review Flag for Campaign
    Resetting the review flag will allow the campaign to be activated
 
 @param activate : Activate the campaign immediately
 
 @result YES : success / NO : Error
 */
-(BOOL) reviewCampaign:(BOOL) activate;

/** Provides the campaign values in dictionary format
 */
-(NSDictionary *_Nullable) campaignDictionary;

/** Provides a campaign location dependent QRCode for the Campaign
 */
-(UIImage *) locationQRCodeForDomain:(nonnull NSString *) domain;

/** Provides a time dependent QRCode for the campaign
 */
-(UIImage *) timebasedQRCodeForDomain:(nonnull NSString *) domain;


/** Provides a current location dependent QRCode for the Campaign
 */
-(void) currentLocationQRCodeForDomain:(NSString *) domain withCompletionHandler:(nonnull void (^)(UIImage *qrcode)) completion;

+(void) campaignWithCampaignId:(NSString *_Nonnull) campaignId completion:(nonnull void (^)(SCLoyaltyCampaign * _Nullable campaign)) completion;
+(BOOL) pickupPointsQRKey:(NSString *_Nonnull) qrkey autoRedeem:(BOOL) redeem completion:(nonnull void (^)(BOOL pickupSuccess, BOOL redeemSuccess, SCLoyaltyCampaign * _Nullable campaign, NSString * _Nullable voucherCode, SCCampaignQRCodeError resonCode, NSString * _Nullable error)) completion;

@end
