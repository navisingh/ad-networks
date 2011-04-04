/*

 AdWhirlAdapterInMobi.m

 Copyright 2010 AdMob, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

*/

#import "AdWhirlAdapterInMobi.h"
#import "AdWhirlAdNetworkConfig.h"
#import "AdWhirlView.h"
#import "InMobiAdView.h"
#import "AdWhirlLog.h"
#import "AdWhirlAdNetworkAdapter+Helpers.h"
#import "AdWhirlAdNetworkRegistry.h"

@implementation AdWhirlAdapterInMobi

+ (AdWhirlAdNetworkType)networkType {
  return AdWhirlAdNetworkTypeInMobi;
}

+ (void)load {
  [[AdWhirlAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd {
  InMobiAdView *inMobiView = [InMobiAdView startInmobiAdEngineAttachedDelegate:self];
  self.adNetworkView = inMobiView;
}

- (void)stopBeingDelegate {
  // no way to set inMobiView's delegate to nil
}

- (void)dealloc {
  [super dealloc];
}

#pragma mark InMobiAdDelegate methods

- (NSString *)siteId {
  if ([adWhirlDelegate respondsToSelector:@selector(inMobiAppId)]) {
    return [adWhirlDelegate inMobiAppID];
  }
  return networkConfig.pubId;
}

- (void)adReceivedNotification:(InMobiAdView *)adView {
  [adWhirlView adapter:self didReceiveAdView:adView];
}

- (void)adFailedNotification:(InMobiAdView *)adView {
  [adWhirlView adapter:self didFailAd:nil];
}

- (void)adModalScreenDisplayNotification:(InMobiAdView *)adView {
  [self helperNotifyDelegateOfFullScreenModal];
}

- (void)adModalScreenDismissNotification:(InMobiAdView *)adView {
  [self helperNotifyDelegateOfFullScreenModalDismissal];
}

- (BOOL)isLocationInquiryAllowed {
  return adWhirlConfig.locationOn;
}

- (BOOL)testMode {
  if ([adWhirlDelegate respondsToSelector:@selector(adWhirlTestMode)])
    return [adWhirlDelegate adWhirlTestMode];
  return NO;
}

- (BOOL)respondsToSelector:(SEL)selector {
  if (selector == @selector(currentLocation)
      && ![adWhirlDelegate respondsToSelector:@selector(locationInfo)]) {
    return NO;
  }
  else if (selector == @selector(postalCode)
           && ![adWhirlDelegate respondsToSelector:@selector(postalCode)]) {
    return NO;
  }
  else if (selector == @selector(areaCode)
           && ![adWhirlDelegate respondsToSelector:@selector(areaCode)]) {
    return NO;
  }
  else if (selector == @selector(dateOfBirth)
           && ![adWhirlDelegate respondsToSelector:@selector(dateOfBirth)]) {
    return NO;
  }
  else if (selector == @selector(gender)
           && ![adWhirlDelegate respondsToSelector:@selector(gender)]) {
    return NO;
  }
  else if (selector == @selector(keywords)
           && ![adWhirlDelegate respondsToSelector:@selector(keywords)]) {
    return NO;
  }
  else if (selector == @selector(income)
           && ![adWhirlDelegate respondsToSelector:@selector(incomeLevel)]) {
    return NO;
  }
  else if (selector == @selector(education)
           && ![adWhirlDelegate respondsToSelector:@selector(inMobiEducation)]) {
    return NO;
  }
  else if (selector == @selector(ethnicity)
           && ![adWhirlDelegate respondsToSelector:@selector(inMobiEthnicity)]) {
    return NO;
  }
  else if (selector == @selector(age)
           && ![adWhirlDelegate respondsToSelector:@selector(dateOfBirth)]) {
    return NO;
  }
  else if (selector == @selector(interests)
           && ![adWhirlDelegate respondsToSelector:@selector(inMobiInterests)]) {
    return NO;
  }
  return [super respondsToSelector:selector];
}

- (CLLocation *)currentLocation {
  return [adWhirlDelegate locationInfo];
}

- (NSString *)postalCode {
  return [adWhirlDelegate postalCode];
}

- (NSString *)areaCode {
  return [adWhirlDelegate areaCode];
}

- (NSDate *)dateOfBirth {
  return [adWhirlDelegate dateOfBirth];
}

- (Gender)gender {
  NSString *genderStr = [adWhirlDelegate gender];
  if ([genderStr isEqualToString:@"f"]) {
    return G_F;
  }
  if ([genderStr isEqualToString:@"m"]) {
    return G_M;
  }
  return G_None;
}

- (NSString *)keywords {
  return [adWhirlDelegate keywords];
}

- (NSUInteger)income {
  return [adWhirlDelegate incomeLevel];
}

- (Education)education {
  return [adWhirlDelegate inMobiEducation];
}

- (Ethnicity)ethnicity {
  return [adWhirlDelegate inMobiEthnicity];
}

- (NSUInteger)age {
  return [self helperCalculateAge];
}

- (NSString *)interests {
  return [adWhirlDelegate inMobiInterests];
}

@end
