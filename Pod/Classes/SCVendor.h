//
//  SCVendor.h
//  C2CallPhone
//
//  Created by Michael Knecht on 16.03.18.
//

#import <Foundation/Foundation.h>

// XML Attributes and Elements
#define C2VENDOR_ELEM_Owner @"Owner"
#define C2VENDOR_ELEM_Address @"Address"
#define C2VENDOR_ELEM_PhoneNumber @"PhoneNumber"
#define C2VENDOR_ELEM_PaymentDetails @"PaymentDetails"
#define C2VENDOR_ELEM_AutoTopupRule @"AutoTopupRule"
#define C2VENDOR_ELEM_RegisterDate @"RegisterDate"
#define C2VENDOR_ELEM_ConfirmDate @"ConfirmDate"
#define C2VENDOR_ELEM_ImageRef @"ImageRef"
#define C2VENDOR_ELEM_VideoRef @"VideoRef"
#define C2VENDOR_ELEM_UrlRef @"UrlRef"
#define C2VENDOR_ELEM_Tag @"Tag"
#define C2VENDOR_ELEM_VendorDescription @"VendorDescription"
#define C2VENDOR_ELEM_ProductsDescription @"ProductsDescription"
#define C2VENDOR_ELEM_OpeningHours @"OpeningHours"
#define C2VENDOR_ELEM_Location @"Location"
#define C2VENDOR_ELEM_InfoElement @"InfoElement"
#define C2VENDOR_Key_InfoElement_AgreedToShareInfo @"AgreedToShareInfo"

#define C2VENDOR_ATTR_VendorId @"VendorId"
#define C2VENDOR_ATTR_VendorName @"VendorName"
#define C2VENDOR_ATTR_VendorEmail @"VendorEmail"
#define C2VENDOR_ATTR_VendorType @"VendorType"
#define C2VENDOR_ATTR_BusinessSection @"BusinessSection"
#define C2VENDOR_ATTR_ReferralCode @"ReferralCode"
#define C2VENDOR_ATTR_Confirmed @"Confirmed"
#define C2VENDOR_ATTR_DBTStamp @"DBTStamp"

#define C2VENDOR_VALUE_VendorType_VND_SINGLE_STORE @"VND_SINGLE_STORE"
#define C2VENDOR_VALUE_VendorType_VND_CHAIN_STORE @"VND_CHAIN_STORE"
#define C2VENDOR_VALUE_VendorType_VND_ONLINE_STORE @"VND_ONLINE_STORE"
#define C2VENDOR_VALUE_VendorType_VND_MULTI_STORE @"VND_MULTI_STORE"
#define C2VENDOR_VALUE_VendorType_VND_NO_STORE @"VND_NO_STORE"

#define C2INFOELEMENT_ATTR_Key @"Key"

#define C2LOCATION_ATTR_Lat @"Lat"
#define C2LOCATION_ATTR_Long @"Long"
#define C2LOCATION_ATTR_MaxDistanceInKM @"MaxDistanceInKM"
#define C2LOCATION_ATTR_PlacesRef @"PlacesRef"
#define C2LOCATION_ATTR_LocationName @"LocationName"
#define C2LOCATION_ATTR_LocationType @"LocationType"

#define C2LOCATION_VALUE_LocationType_LOC_HOME @"LOC_HOME"
#define C2LOCATION_VALUE_LocationType_LOC_STORE @"LOC_STORE"
#define C2LOCATION_VALUE_LocationType_LOC_EVENT @"LOC_EVENT"
#define C2LOCATION_VALUE_LocationType_LOC_CAMPAIGN @"LOC_CAMPAIGN"


#define C2OWNER_ELEM_Userid @"Userid"
#define C2OWNER_ELEM_Firstname @"Firstname"
#define C2OWNER_ELEM_Name @"Name"
#define C2OWNER_ELEM_EMail @"EMail"
#define C2OWNER_ELEM_PhoneNumber @"PhoneNumber"

#define C2ADDRESS_ELEM_ZipCode @"ZipCode"
#define C2ADDRESS_ELEM_Region @"Region"
#define C2ADDRESS_ELEM_City @"City"
#define C2ADDRESS_ELEM_Street @"Street"
#define C2ADDRESS_ELEM_Country @"Country"
#define C2ADDRESS_ELEM_AddressInfo @"AddressInfo"

#define C2IMAGEREF_ATTR_ImageKey @"ImageKey"
#define C2IMAGEREF_ATTR_MediaWidth @"MediaWidth"
#define C2IMAGEREF_ATTR_MediaHeight @"MediaHeight"
#define C2IMAGEREF_ATTR_ImageType @"ImageType"
#define C2IMAGEREF_VALUE_ImageType_IMG_LOGO @"IMG_LOGO"
#define C2IMAGEREF_VALUE_ImageType_IMG_MAIN @"IMG_MAIN"
#define C2IMAGEREF_VALUE_ImageType_IMG_PRODUCT @"IMG_PRODUCT"
#define C2IMAGEREF_VALUE_ImageType_IMG_OTHER @"IMG_OTHER"


#define C2VIDEOREF_ATTR_VideoKey @"VideoKey"
#define C2VIDEOREF_ATTR_MediaWidth @"MediaWidth"
#define C2VIDEOREF_ATTR_MediaHeight @"MediaHeight"
#define C2VIDEOREF_ATTR_VideoType @"VideoType"
#define C2VIDEOREF_VALUE_VideoType_VID_CAMPAIN @"VID_CAMPAIN"
#define C2VIDEOREF_VALUE_VideoType_VID_VENDOR @"VID_VENDOR"
#define C2VIDEOREF_VALUE_VideoType_VID_OTHER @"VID_OTHER"


#define C2URLREF_ELEM_Url @"Url"
#define C2URLREF_ELEM_UrlInfo @"UrlInfo"
#define C2URLREF_ATTR_UrlType @"UrlType"
#define C2URLREF_VALUE_UrlType_URL_HOME @"URL_HOME"
#define C2URLREF_VALUE_UrlType_URL_TERMS @"URL_TERMS"
#define C2URLREF_VALUE_UrlType_URL_PRODUCT @"URL_PRODUCT"
#define C2URLREF_VALUE_UrlType_URL_PRIVACY @"URL_PRIVACY"
#define C2URLREF_VALUE_UrlType_URL_OPENING_HOURS @"URL_OPENING_HOURS"
#define C2URLREF_VALUE_UrlType_URL_LOCATION @"URL_LOCATION"
#define C2URLREF_VALUE_UrlType_URL_IMPRINT @"URL_IMPRINT"
#define C2URLREF_VALUE_UrlType_URL_SHOP @"URL_SHOP"

#define C2LERR_Success              0
#define C2LERR_MissingParameter     -1
#define C2LERR_AuthFailed           -2
#define C2LERR_InternalError        -3
#define C2LERR_InvalidReferralCode  -4
#define C2LERR_NotFound             -5
#define C2LERR_Forbidden            -6
#define C2LERR_ValidationFailed     -7
#define C2LERR_NotEnoughPoints      -8
#define C2LERR_RequestFailed        -9


@class DDXMLElement;

@interface SCLoyaltyBase : NSObject {
    NSString *mutex;
}

@property(strong, nonatomic, nullable) DDXMLElement           *xmlData;

-(NSString *_Nullable) attributeForName:(NSString *_Nonnull) name;
-(NSString *_Nullable) attributeForName:(NSString *_Nonnull) name inElement:(DDXMLElement *_Nonnull) elem;
-(void) setAttributeForName:(NSString *_Nonnull) name value:(NSString *_Nullable) value;
-(void) setAttributeForName:(NSString *_Nonnull) name value:(NSString *_Nullable) value inElement:(DDXMLElement *_Nonnull) elem;
-(NSString *_Nullable) elementForName:(NSString *_Nonnull) name;
-(DDXMLElement *_Nullable) elementNodeForName:(NSString *_Nonnull) name create:(BOOL) create;
-(NSString *_Nullable) elementForName:(NSString *_Nonnull) name inElement:(DDXMLElement *_Nonnull) elem;
-(void) setElementForName:(NSString *_Nonnull) name value:(NSString *_Nullable) value;
-(void) setElementForName:(NSString *_Nonnull) name value:(NSString *_Nullable) value inElement:(DDXMLElement *_Nonnull) elem;

-(DDXMLElement *_Nullable) urlElementForType:(NSString *_Nonnull) urlType create:(BOOL) create;
-(DDXMLElement *_Nullable) locationElementForType:(NSString *_Nonnull) locType create:(BOOL) create;
-(DDXMLElement *_Nullable) infoElementForKey:(NSString *_Nonnull) key  create:(BOOL) create;

-(DDXMLElement *_Nullable) imageElementForType:(NSString *_Nonnull) imageType  create:(BOOL) create;
-(NSArray<DDXMLElement *> *_Nullable) imageElementsForType:(NSString *_Nonnull) imageType;

-(NSString *_Nullable) imageKeyForType:(NSString *_Nonnull) imageType;
-(void) removeImageForKey:(NSString *_Nonnull) imageKey;
-(void) removeImageForImageType:(NSString *_Nonnull) imageType;

-(DDXMLElement *_Nullable) videoElementForType:(NSString *_Nonnull) videoType  create:(BOOL) create;
-(NSString *_Nullable) videoKeyForType:(NSString *_Nonnull) videoType;
-(void) removeVideoForKey:(NSString *_Nonnull) videoKey;
-(void) removeVideoForVideoType:(NSString *_Nonnull) videoType;

-(NSString *_Nullable) xmlString;

-(UIImage *_Nullable) imageForPath:(NSString *_Nonnull) path;
-(NSArray<NSString *> *) voucherListForPath:(NSString *) path;
-(NSURL *_Nullable) urlForPath:(NSString *_Nonnull) path;

-(void) setValue:(NSObject *_Nullable) value forKey:(NSString*_Nonnull) key inDict:(NSMutableDictionary *_Nonnull) dict;

-(NSString *) documentsDirectory;
@end


@interface SCVendor : SCLoyaltyBase

@property(strong, nonatomic, nullable, readonly) NSString *vendorId;
@property(strong, nonatomic, nullable) NSString *vendorName;
@property(strong, nonatomic, nullable) NSString *vendorDescription;
@property(strong, nonatomic, nullable) NSString *vendorEmail;
@property(strong, nonatomic, nullable) NSString *vendorPhone;
@property(strong, nonatomic, nullable) NSString *vendorType;
@property(strong, nonatomic, nullable) NSString *businessSection;
@property(strong, nonatomic, nullable) NSString *referralCode;
@property(strong, nonatomic, nullable) NSString *country;
@property(strong, nonatomic, nullable) NSString *city;
@property(strong, nonatomic, nullable) NSString *address;
@property(strong, nonatomic, nullable) NSString *zipCode;
@property(strong, nonatomic, nullable) NSString *street;
@property(strong, nonatomic, nullable) NSString *region;
@property(strong, nonatomic, nullable) NSString *openingHours;
@property(strong, nonatomic, nullable) NSString *productsAndServices;

@property(strong, nonatomic, nullable, readonly) NSString *ownerId;
@property(strong, nonatomic, nullable, readonly) NSString *ownerName;
@property(strong, nonatomic, nullable, readonly) NSString *ownerFirstname;
@property(strong, nonatomic, nullable, readonly) NSString *ownerEmail;
@property(strong, nonatomic, nullable, readonly) NSString *ownerPhone;

@property(strong, nonatomic, nullable) NSString *shopUrl;
@property(strong, nonatomic, nullable) NSString *websiteUrl;

@property(nonatomic) double storeLocationLatitude;
@property(nonatomic) double storeLocationLongitude;

@property(nonatomic, readonly) BOOL agreedToShareInfo;

@property(strong, nonatomic, nullable) UIImage *vendorLogo;
@property(strong, nonatomic, nullable, readonly) NSArray<UIImage *> *vendorImages;

@property(strong, nonatomic, nullable) NSString     *errorDescription;
@property(nonatomic) NSInteger    errorCode;

- (instancetype _Nullable )initWithDictionary:(NSDictionary *_Nonnull) properties;

-(void) setVendorDataFromDictionary:(NSDictionary *) properties;

-(void) addVendorImage:(UIImage *_Nonnull) image;
-(void) removeVendorImage:(UIImage *_Nonnull) image;
-(void) removeAllVendorImages;
-(BOOL) shouldUploadImages;
-(BOOL) uploadImagesWithCompletionHandler:(nullable void (^)(BOOL success)) completion;

-(NSDictionary *_Nullable) vendorDictionary;

-(BOOL) saveVendorWithCompletionHandler:(nullable void (^)(BOOL success)) completion;
-(void) reloadVendorDataWithCompletionHandler:(void (^_Nullable)(BOOL success)) completion;
-(BOOL) loadVendorMediaWithCompletionHandler:(void (^_Nullable)(BOOL success)) completion;

+(void) vendorWithVendorId:(NSString *_Nonnull) vendorId completion:(void (^_Nonnull)(SCVendor * _Nullable  vendor)) completion;

@end
