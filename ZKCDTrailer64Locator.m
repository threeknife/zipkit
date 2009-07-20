//
//  ZKCDTrailer64Locator.m
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import "ZKCDTrailer64Locator.h"
#import "NSData+ZKAdditions.h"
#import "ZKDefs.h"

@implementation ZKCDTrailer64Locator

- (id) init {
	if (self = [super init]) {
		self.magicNumber = ZKCDTrailer64LocatorMagicNumber;
		self.diskNumberWithStartOfCentralDirectory = 0;
		self.numberOfDisks = 1;
	}
	return self;
}

+ (ZKCDTrailer64Locator *) recordWithData:(NSData *)data atOffset:(NSUInteger) offset {
	NSUInteger mn = [data hostInt32OffsetBy:&offset];
	if (mn != ZKCDTrailer64LocatorMagicNumber) return nil;
	ZKCDTrailer64Locator *record = [ZKCDTrailer64Locator new];
	record.magicNumber = mn;
	record.diskNumberWithStartOfCentralDirectory = [data hostInt32OffsetBy:&offset];
	record.offsetOfStartOfCentralDirectoryTrailer64 = [data hostInt64OffsetBy:&offset];
	record.numberOfDisks = [data hostInt32OffsetBy:&offset];
	return record;
}

+ (ZKCDTrailer64Locator *) recordWithArchivePath:(NSString *)path andCDTrailerLength:(NSUInteger)cdTrailerLength {
	NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
	unsigned long long fileOffset = [file seekToEndOfFile] - cdTrailerLength - ZKCDTrailer64LocatorFixedDataLength;
	[file seekToFileOffset:fileOffset];
	NSData *data = [file readDataOfLength:ZKCDTrailer64LocatorFixedDataLength];
	[file closeFile];
	return [self recordWithData:data atOffset:0];
}

- (NSData *) data {
	NSMutableData *data = [NSMutableData dataWithLittleInt32:self.magicNumber];
	[data appendLittleInt32:self.diskNumberWithStartOfCentralDirectory];
	[data appendLittleInt64:self.offsetOfStartOfCentralDirectoryTrailer64];
	[data appendLittleInt32:self.numberOfDisks];
	return data;
}

- (NSUInteger) length {
	return ZKCDTrailer64LocatorFixedDataLength;
}

- (NSString *) description {
	return [NSString stringWithFormat:@"offset of CD64: %qu", self.offsetOfStartOfCentralDirectoryTrailer64];
}

@synthesize magicNumber, diskNumberWithStartOfCentralDirectory, offsetOfStartOfCentralDirectoryTrailer64, numberOfDisks;

@end