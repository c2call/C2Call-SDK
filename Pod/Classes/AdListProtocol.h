//
//  AdListProtocol.h
//  C2CallPhone
//
//  Created by Michael Knecht on 10/29/11.
//  Copyright (c) 2011 C2Call GmbH. All rights reserved.
//

#ifndef C2CallPhone_AdListProtocol_h
#define C2CallPhone_AdListProtocol_h

@protocol AdListProtocol <NSObject>

-(NSArray *) getAdList;
-(NSString *) valueForAd:(id) ad;
-(NSString *) titleForAd:(id) ad;
-(NSString *) descriptionForAd:(id) ad;
-(UIImage *) imageForAd:(id) ad;
-(NSString *) linkForAd:(id) ad;
-(NSSet *) kindOfAd:(id) ad;
-(void) markAsSeen:(id) ad;
-(BOOL) offerSeen:(id) ad;
-(BOOL) hasOffers;
-(void) refreshAds;

@end

#endif
