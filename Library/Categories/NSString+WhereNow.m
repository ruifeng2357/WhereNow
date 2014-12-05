//
//  NSString+Knotable.m
//  Knotable
//
//  Created by Martin Ceperley on 12/10/13.
//
//

#import "NSString+WhereNow.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSString (WhereNow)

- (NSString *) md5
{
    const char *cStr = [self UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (CC_LONG) strlen(cStr), digest );
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++){
        [output appendFormat:@"%02x", digest[i]];
    }
    return [output copy];
}

- (NSString *)trimmed {
    if (self == (id)[NSNull null] || ![self isKindOfClass:[NSString class]]) {
        return @"";
    }
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL)startsWith:(NSString *)string
{
    NSRange r = [self rangeOfString:string];
    return r.location == 0 && r.length > 0;
}

- (BOOL)isValidEmail {
    NSError *error = nil;
    NSString *pattern = @"^[a-zA-Z0-9\\._\\-\\+]+@[a-zA-Z0-9\\.\\-]+\\.[a-zA-Z]{2,6}$";

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:0
                                                                             error:&error];
    NSUInteger matchCount = [regex numberOfMatchesInString:self options:0 range:NSMakeRange(0, self.length)];
    if(error){
        NSLog(@"REGEX Error: %@", error);
    }
    return matchCount == 1;
}

- (NSString *)noPrefix:(NSString *)prefix
{
    NSString *new_str = nil;
    if ([self hasPrefix:prefix]) {
        new_str = [self substringFromIndex:[prefix length]];
    } else {
        new_str = self;
    }
    return new_str;
}
@end
