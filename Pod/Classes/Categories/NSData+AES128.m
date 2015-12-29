//
//  NSData+AES128.m
//  C2CallPhone
//
//  Created by Michael Knecht on 04.08.12.
//  Copyright (c) 2012 C2Call GmbH. All rights reserved.
//

#import <CommonCrypto/CommonCryptor.h>
#import "NSData+AES128.h"
#import "Crypto.h"

@implementation NSData (AES128)

- (NSData *)AES128EncryptWithKey:(NSString *)key {
    // 'key' should be 32 bytes for AES128, will be null-padded otherwise
    
    NSData *keyData = [Crypto hexDecode:key];
//    char *keyPtr[kCCKeySizeAES128+1]; // room for terminator (unused)
//    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    char *keyPtr = (char *)[keyData bytes];
    
    // fetch key data
    //[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    
    //See the doc: For block ciphers, the output size will always be less than or 
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES128,
                                          NULL /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

- (NSData *)AES128DecryptWithKey:(NSString *)key {
	// 'key' should be 32 bytes for AES128, will be null-padded otherwise
    NSData *keyData = [Crypto hexDecode:key];
    //    char *keyPtr[kCCKeySizeAES128+1]; // room for terminator (unused)
    //    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    char *keyPtr = (char *)[keyData bytes];
	
	// fetch key data
	//[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [self length];
	
	//See the doc: For block ciphers, the output size will always be less than or 
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesDecrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES128,
                                          NULL /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
	
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
	}
	
	free(buffer); //free the buffer;
	return nil;
}

@end
