//
//  GADRequest.h
//  Google AdMob Ads SDK
//
//  Copyright 2011 Google Inc. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

// Genders to help deliver more relevant ads.
typedef enum {
  kGADGenderUnknown,
  kGADGenderMale,
  kGADGenderFemale
} GADGender;

// Specifies optional parameters for ad requests.
@interface GADRequest : NSObject <NSCopying>

// Creates an autoreleased GADRequest.
+ (GADRequest *)request;

// To verify your integration set this to YES, make an ad request on the
// simulator, and click on the test ad.  A browser should slide up covering the
// whole screen.  The integration guide has a screenshot and troubleshooting
// tips.
//
// This property has no effect on devices.  That protects against accidentally
// submitting to the App Store with this set to YES and having your users see
// the test ad.
@property (nonatomic, getter=isTesting) BOOL testing;

// Reserved for future use.
@property (nonatomic, retain) NSDictionary *additionalParameters;

#pragma mark Collecting SDK Information

// Returns the version of the SDK.
+ (NSString *)sdkVersion;

#pragma mark User Information

// The user's gender may be used to deliver more relevant ads.
@property (nonatomic, assign) GADGender gender;

// The user's birthday may be used to deliver more relevant ads.
@property (nonatomic, retain) NSDate *birthday;
- (void)setBirthdayWithMonth:(NSInteger)m day:(NSInteger)d year:(NSInteger)y;

// The user's current location may be used to deliver more relevant ads.
// However do not use Core Location just for advertising, make sure it is used
// for more beneficial reasons as well.  It is both a good idea and part of
// Apple's guidelines.
- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
                       accuracy:(CGFloat)accuracyInMeters;

// When Core Location isn't available but the user's location is known supplying
// it here may deliver more relevant ads.  It can be any free-form text such as
// @"Champs-Elysees Paris" or @"94041 US".
- (void)setLocationWithDescription:(NSString *)locationDescription;

#pragma mark Contextual Information

// A keyword is a word or phrase describing the current activity of the user
// such as @"Sports Scores".  Each keyword is an NSString in the NSArray.  To
// clear the keywords set this to nil.
@property (nonatomic, retain) NSMutableArray *keywords;

// Convenience method for adding keywords one at a time such as @"Sports Scores"
// and then @"Football".
- (void)addKeyword:(NSString *)keyword;

@end
