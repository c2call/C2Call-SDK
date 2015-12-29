/*
 *  SIPConstants.h
 *  C2CallPhone
 *
 *  Created by Michael Knecht on 31.12.08.
 *  Copyright 2008 Actai Networks GmbH. All rights reserved.
 *
 */

#ifndef __SIP_CONSTANTS_H
#define __SIP_CONSTANTS_H

#define SIP_VERSION_STRING @"SIP/2.0"
#define BRANCH_MAGIC_COOKIE @"z9hG4bK"

#define SIP_REQUESTURI			@"REQUESTURI"
#define SIP_REQUESTTYPE			@"REQUESTTYPE"
#define SIP_RESPONSETYPE		@"RESPONSETYPE"
#define SIP_CALLID				@"Call-ID"
#define SIP_CSEQ				@"CSeq"
#define SIP_FROM				@"From"
#define SIP_TO					@"To"
#define SIP_VIA					@"Via"
#define SIP_MAXFORWARDS			@"Max-Forwards"
#define SIP_CONTACT				@"Contact"
#define SIP_EXPIRES				@"Expires"
#define SIP_CONTENTLENGTH		@"Content-Length"
#define SIP_CONTENTTYPE			@"Content-Type"
#define SIP_CONTENT				@"Content"
#define SIP_ROUTE				@"Route"
#define SIP_RROUTE				@"Record-Route"
#define SIP_ONLINESTATUS		@"X-OnlineStatus"
#define SIP_CALLERID			@"X-CallerId"
#define SIP_PUSHTYPE			@"X-PushType"
#define SIP_SESSIONID			@"X-SessionId"
#define SIP_VERIFY              @"X-Verify"
#define SIP_VERSION             @"X-Version"
#define SIP_MSGID               @"X-Messageid"
#define SIP_USERID              @"X-Userid"
#define SIP_STATUS              @"X-Status"
#define SIP_GROUPID             @"X-Groupid"
#define SIP_GROUPVIDEO          @"X-GroupVideo"
#define SIP_RICHMESSAGEKEY      @"X-RMKey"
#define SIP_ACTION              @"X-Action"
#define SIP_AFFILIATE           @"X-Affiliate"
#define SIP_OFFLINESTATUS       @"X-OfflineStatus"
#define SIP_ORIGINALSENDER      @"X-OSender"
#define SIP_EVENT				@"Event"
#define SIP_SUBSCRIPTION_STATE	@"Subscription-State"


#define SIP_INVITE				@"INVITE"
#define SIP_REGISTER			@"REGISTER"
#define SIP_MESSAGE				@"MESSAGE"
#define SIP_ACK					@"ACK"
#define SIP_BYE					@"BYE"
#define SIP_CANCEL				@"CANCEL"
#define SIP_OPTIONS				@"OPTIONS"
#define SIP_SUBSCRIBE			@"SUBSCRIBE"
#define SIP_NOTIFY				@"NOTIFY"

typedef enum {
    OS_OFFLINE,
    OS_ONLINE,
    OS_FORWARDED,
    OS_INVISIBLE,
    OS_AWAY,
    OS_BUSY,
    OS_CALLME,
    OS_ONLINEVIDEO,
    OS_IPUSH,
    OS_IPUSHCALL,
    OS_GROUPCALL
} SipOnlineStatusT;

/*
#define OS_OFFLINE		0
#define OS_ONLINE		1
#define OS_FORWARDED	2
#define OS_INVISIBLE	3
#define OS_AWAY         4
#define OS_BUSY			5
#define OS_CALLME		6
#define OS_ONLINEVIDEO	7
#define OS_IPUSH		8
#define OS_IPUSHCALL	9
#define OS_GROUPCALL	10
*/

#define RESP_TRYING 100
#define RESP_RINGING 180
#define RESP_CALL_IS_BEING_FORWARDED 181
#define RESP_QUEUED 182    
#define RESP_SESSION_PROGRESS 183      
#define RESP_OK 200
#define RESP_ACCEPTED 202    
#define RESP_MULTIPLE_CHOICES 300
#define RESP_MOVED_PERMANENTLY 301    
#define RESP_MOVED_TEMPORARILY 302    
#define RESP_USE_PROXY 305
#define RESP_ALTERNATIVE_SERVICE 380    
#define RESP_BAD_REQUEST 400   
#define RESP_UNAUTHORIZED 401    
#define RESP_PAYMENT_REQUIRED 402   
#define RESP_FORBIDDEN 403
#define RESP_NOT_FOUND 404    
#define RESP_METHOD_NOT_ALLOWED 405   
#define RESP_NOT_ACCEPTABLE 406
#define RESP_PROXY_AUTHENTICATION_REQUIRED 407
#define RESP_REQUEST_TIMEOUT 408    
#define RESP_GONE 410
#define RESP_CONDITIONAL_REQUEST_FAILED 412
#define RESP_REQUEST_ENTITY_TOO_LARGE 413    
#define RESP_REQUEST_URI_TOO_LONG 414
#define RESP_UNSUPPORTED_MEDIA_TYPE 415    
#define RESP_UNSUPPORTED_URI_SCHEME 416 
#define RESP_BAD_EXTENSION 420   
#define RESP_EXTENSION_REQUIRED 421    
#define RESP_INTERVAL_TOO_BRIEF 423    
#define RESP_TEMPORARILY_UNAVAILABLE 480    
#define RESP_CALL_OR_TRANSACTION_DOES_NOT_EXIST 481
#define RESP_LOOP_DETECTED 482    
#define RESP_TOO_MANY_HOPS 483
#define RESP_ADDRESS_INCOMPLETE 484   
#define RESP_AMBIGUOUS 485
#define RESP_BUSY_HERE 486
#define RESP_REQUEST_TERMINATED 487
#define RESP_NOT_ACCEPTABLE_HERE 488    
#define RESP_BAD_EVENT 489     
#define RESP_REQUEST_PENDING 491   
#define RESP_UNDECIPHERABLE 493           
#define RESP_SERVER_INTERNAL_ERROR 500
#define RESP_NOT_IMPLEMENTED 501    
#define RESP_BAD_GATEWAY 502
#define RESP_SERVICE_UNAVAILABLE 503
#define RESP_SERVER_TIMEOUT 504
#define RESP_VERSION_NOT_SUPPORTED 505    
#define RESP_MESSAGE_TOO_LARGE 513 
#define RESP_BUSY_EVERYWHERE 600    
#define RESP_DECLINE 603
#define RESP_DOES_NOT_EXIST_ANYWHERE 604
#define RESP_SESSION_NOT_ACCEPTABLE 606


// Parameter Names
#define P_NEXT_NONCE @"nextnonce"
#define P_TAG @"tag"
#define P_USERNAME @"username"
#define P_URI @"uri"
#define P_DOMAIN @"domain"
#define P_CNONCE @"cnonce"
#define P_PASSWORD @"password"
#define P_RESPONSE @"response"
#define P_RESPONSE_AUTH @"rspauth"
#define P_OPAQUE @"opaque"
#define P_ALGORITHM @"algorithm"
#define P_DIGEST @"Digest"
#define P_SIGNED_BY @"signed-by"
#define P_SIGNATURE @"signature"
#define P_NONCE @"nonce"
#define P_NONCE_COUNT @"nc"
#define P_PUBKEY @"pubkey"
#define P_COOKIE @"cookie"
#define P_REALM @"realm"
#define P_VERSION @"version"
#define P_STALE @"stale"
#define P_QOP @"qop"
#define P_NC @"nc"
#define P_PURPOSE @"purpose"
#define P_CARD @"card"
#define P_INFO @"info"
#define P_ACTION @"action"
#define P_PROXY @"proxy"
#define P_REDIRECT @"redirect"
#define P_EXPIRES @"expires"
#define P_Q @"q"
#define P_RENDER @"render"
#define P_SESSION @"session"
#define P_ICON @"icon"
#define P_ALERT @"alert"
#define P_HANDLING @"handling"
#define P_REQUIRED @"required"
#define P_OPTIONAL @"optional"
#define P_EMERGENCY @"emergency"
#define P_URGENT @"urgent"
#define P_NORMAL @"normal"
#define P_NON_URGENT @"non-urgent"
#define P_DURATION @"duration"
#define P_BRANCH @"branch"
#define P_HIDDEN @"hidden"
#define P_RECEIVED @"received"
#define P_MADDR @"maddr"
#define P_TTL @"ttl"
#define P_TRANSPORT @"transport"
#define P_TEXT @"text"
#define P_CAUSE @"cause"
#define P_ID @"id"
#define P_RPORT @"rport"
#define P_TO_TAG @"to-tag"
#define P_FROM_TAG @"from-tag"
#define P_SIP_INSTANCE @"+sip.instance"
#define P_PUB_GRUU @"pub-gruu"
#define P_TEMP_GRUU @"temp-gruu"
#define P_GRUU @"gruu"


#endif