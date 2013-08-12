//
//  LBMGEngine.h
//  Tours
//
//  Created by Alan Smithee on 4/11/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "MKNetworkEngine.h"

typedef void (^LBMGContentError)(NSError *error);
typedef void (^LBMGContentGetDictionary)(NSDictionary *dictionary);
typedef void (^LBMGContentGetArray)(NSArray *array);

@interface LBMGEngine : NSObject

@property (strong, nonatomic) MKNetworkEngine *contentEngine;


- (id)init;
- (MKNetworkOperation *)downloadFileFromURL:(NSString*)urlString andStoreAtFilePath:(NSString *)filePath;

- (void)getNearbyToursWithLatitude:(float)latitude andLongitude:(float)longitude contentBlock:(LBMGContentGetArray)contentBlock errorBlock:(LBMGContentError)contentError;
- (void)getTourWithID:(int)tourId latitude:(float)latitude longitude:(float)longitude contentBlock:(LBMGContentGetDictionary)contentBlock errorBlock:(LBMGContentError)contentError;
- (void)getAroundMeWithLatitude:(float)latitude andLongitude:(float)longitude contentBlock:(LBMGContentGetArray)contentBlock errorBlock:(LBMGContentError)contentError;
- (void)getTourDetailsWithIDs:(NSArray *)tourIds contentBlock:(LBMGContentGetArray)contentBlock errorBlock:(LBMGContentError)contentError;
- (void)getEventWithId:(int)eventId factual:(NSString *)factualID contentBlock:(LBMGContentGetDictionary)contentBlock errorBlock:(LBMGContentError)contentError;

- (void)getListingSearchWithString:(NSString *)searchItem withLatitude:(float)latitude andLongitude:(float)longitude contentBlock:(LBMGContentGetArray)contentBlock errorBlock:(LBMGContentError)contentError;

- (void)getListingSuggestionsWithString:(NSString *)searchItem contentBlock:(LBMGContentGetArray)contentBlock errorBlock:(LBMGContentError)contentError;

- (void)getFeaturedLinksForTourID:(NSNumber *)tourID contentBlock:(LBMGContentGetArray)contentBlock errorBlock:(LBMGContentError)contentError;

// LBMG Server logging calls
- (void)logTourStartWithId:(NSNumber *)tourID latitude:(float)latitude andLongitude:(float)longitude contentBlock:(LBMGContentGetDictionary)contentBlock errorBlock:(LBMGContentError)contentError;

- (void)logTourCompleteWithId:(NSNumber *)tourID latitude:(float)latitude andLongitude:(float)longitude contentBlock:(LBMGContentGetDictionary)contentBlock errorBlock:(LBMGContentError)contentError;

- (void)logTourDownloadWithId:(NSNumber *)tourID latitude:(float)latitude andLongitude:(float)longitude contentBlock:(LBMGContentGetDictionary)contentBlock errorBlock:(LBMGContentError)contentError;

- (void)logTourCategoryViewedWithId:(NSNumber *)categoryId latitude:(float)latitude andLongitude:(float)longitude contentBlock:(LBMGContentGetDictionary)contentBlock errorBlock:(LBMGContentError)contentError;

@end
