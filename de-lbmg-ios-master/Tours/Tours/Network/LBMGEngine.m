//
//  LBMGEngine.m
//  Tours
//
//  Created by Alan Smithee on 4/11/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGEngine.h"

#define kUsername           @"lbmg"
#define kPassword           @"de2013"

#define kVersion             @"1"

#define kContentURLKey      @"LBMGServer"
#define kContentAPIPath     @"api"

#define kTours              @"tours.json?latitude=%f&longitude=%f"
#define kTourDetail         @"tours/%i.json?latitude=%f&longitude=%f"
#define kTourDetails        @"tours/tour_details.json?tour_ids[]=%i"
#define kAroundMe           @"around_me.json?latitude=%f&longitude=%f"
#define kEvent              @"listings/%i.json"
#define kFactualEvent       @"listings/%@.json?factual=true"
#define kListingSuggest     @"listings/search_suggestions.json?search=%@"
//#define kListingSearch      @"listings/search.json?search=\"%@\"&latitude=%f&longitude=%f"
#define kListingSearch      @"listings/search.json?search=%@&latitude=%f&longitude=%f"
#define kFeaturedListings   @"tours/%@/featured_listings.json"

// logging calls
#define kLogTourStart           @"tours/%@/start.json?latitude=%f&longitude=%f&device_id=%@&device_type=iphone"
#define kLogTourEnd             @"tours/%@/end.json?latitude=%f&longitude=%f&device_id=%@&device_type=iphone"
#define kLogTourDownload        @"tours/%@/downloaded.json?latitude=%f&longitude=%f&device_id=%@&device_type=iphone"
#define kLogCategoryView        @"tour_categories/%@/viewed.json?latitude=%f&longitude=%f&device_id=%@&device_type=iphone"


@interface LBMGEngine ()

@property (assign, nonatomic) NSUInteger downloadedDataSize;
@property (nonatomic, strong) NSMutableArray *downloadProgressChangedHandlers;

@property (strong, nonatomic) NSMutableData *mutableData;
@property (nonatomic, assign) NSInteger startPosition;

@property (nonatomic, strong) NSMutableArray *downloadStreams;
@property (strong, nonatomic) NSMutableURLRequest *request;
@property (strong, nonatomic) NSHTTPURLResponse *response;

- (void)startDictionaryOpWithPath:(NSString *)path contentBlock:(LBMGContentGetDictionary)contentBlock errorBlock:(LBMGContentError)contentError;
- (void)startArrayOpWithPath:(NSString *)path contentBlock:(LBMGContentGetArray)contentBlock errorBlock:(LBMGContentError)contentError;

@end

@implementation LBMGEngine

- (id)init {
    
    NSString *serverName = [[NSBundle mainBundle] objectForInfoDictionaryKey:kContentURLKey];
    self.contentEngine = [[MKNetworkEngine alloc] initWithHostName:serverName apiPath:kContentAPIPath customHeaderFields:nil];
    self.downloadProgressChangedHandlers = [NSMutableArray array];
    return self;
}

- (void)startDictionaryOpWithPath:(NSString *)path contentBlock:(LBMGContentGetDictionary)contentBlock errorBlock:(LBMGContentError)contentError {
    
    MKNetworkOperation *op = [self.contentEngine operationWithPath:path params:nil httpMethod:@"GET"];
    
    DLog(@"RequestURL is %@", op.url);
    
    [op setUsername:kUsername password:kPassword];
    
    NSDictionary *headers = [[NSDictionary alloc] initWithObjectsAndKeys:@"application/vnd.lbmg+json", @"Accept", kVersion, @"version", nil];
	[op addHeaders:headers];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSDictionary *dict = [completedOperation responseJSON];
			contentBlock(dict);
		});
	} errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            			contentError(error);
            		});
    }];

	[self.contentEngine enqueueOperation:op];
}

- (void)startArrayOpWithPath:(NSString *)path contentBlock:(LBMGContentGetArray)contentBlock errorBlock:(LBMGContentError)contentError {

    MKNetworkOperation *op = [self.contentEngine operationWithPath:path params:nil httpMethod:@"GET"];
    
    [op setUsername:kUsername password:kPassword];
    
    NSDictionary *headers = [[NSDictionary alloc] initWithObjectsAndKeys:@"application/vnd.lbmg+json", @"Accept", kVersion, @"version", nil];
    [op addHeaders:headers];
    
    DLog(@"RequestURL is %@", op.url);
	
	[op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSArray *array = [completedOperation responseJSON];
			contentBlock(array);
		});
	} errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			contentError(error);
		});
	}];
	
	[self.contentEngine enqueueOperation:op];
}

- (void)startPostOpWithPath:(NSString *)path contentBlock:(LBMGContentGetDictionary)contentBlock errorBlock:(LBMGContentError)contentError {
    
    MKNetworkOperation *op = [self.contentEngine operationWithPath:path params:nil httpMethod:@"POST"];
    
    [op setUsername:kUsername password:kPassword];
    
    NSDictionary *headers = [[NSDictionary alloc] initWithObjectsAndKeys:@"application/vnd.lbmg+json", @"Accept", kVersion, @"version", nil];
    [op addHeaders:headers];
    
    DLog(@"RequestURL is %@", op.url);
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSDictionary *dict = [completedOperation responseJSON];
			contentBlock(dict);
		});
	} errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			contentError(error);
		});
	}];
	
	[self.contentEngine enqueueOperation:op];
}

// downloads file at a given path
- (MKNetworkOperation *)downloadFileFromURL:(NSString*)urlString andStoreAtFilePath:(NSString *)filePath {
    MKNetworkOperation *op = [[MKNetworkOperation alloc] initWithURLString:urlString params:nil httpMethod:@"GET"];
    
    op.freezable = YES;
    [op addDownloadStream:[NSOutputStream outputStreamToFileAtPath:filePath append:YES]];
    [self.contentEngine enqueueOperation:op];
    return op;
}

- (void)getNearbyToursWithLatitude:(float)latitude andLongitude:(float)longitude contentBlock:(LBMGContentGetArray)contentBlock errorBlock:(LBMGContentError)contentError {
    NSString *functionString = [NSString stringWithFormat:kTours, latitude, longitude];
    [self startArrayOpWithPath:functionString contentBlock:contentBlock errorBlock:contentError];
}

- (void)getTourWithID:(int)tourId latitude:(float)latitude longitude:(float)longitude contentBlock:(LBMGContentGetDictionary)contentBlock errorBlock:(LBMGContentError)contentError {
    NSString *functionString = [NSString stringWithFormat:kTourDetail, tourId, latitude, longitude];
    [self startDictionaryOpWithPath:functionString contentBlock:contentBlock errorBlock:contentError];
}

- (void)getTourDetailsWithIDs:(NSArray *)tourIds contentBlock:(LBMGContentGetArray)contentBlock errorBlock:(LBMGContentError)contentError {
    NSString *functionString = [NSString stringWithFormat:kTourDetails, [tourIds[0] intValue]];
    if (tourIds.count > 1) {
        for (int i = 1; i < tourIds.count; i++) {
            functionString = [functionString stringByAppendingFormat:@"&tour_ids[]=%i", [tourIds[i] intValue]];
        }
    }
    [self startArrayOpWithPath:functionString contentBlock:contentBlock errorBlock:contentError];
}

- (void)getAroundMeWithLatitude:(float)latitude andLongitude:(float)longitude contentBlock:(LBMGContentGetArray)contentBlock errorBlock:(LBMGContentError)contentError {
    NSString *functionString = [NSString stringWithFormat:kAroundMe, latitude, longitude];
    [self startArrayOpWithPath:functionString contentBlock:contentBlock errorBlock:contentError];
}

- (void)getEventWithId:(int)eventId factual:(NSString *)factualID contentBlock:(LBMGContentGetDictionary)contentBlock errorBlock:(LBMGContentError)contentError {
    NSString *functionString;
    if (eventId == 0) {
        functionString = [NSString stringWithFormat:kFactualEvent, factualID];
    } else {
        functionString = [NSString stringWithFormat:kEvent, eventId];
    }
    [self startDictionaryOpWithPath:functionString contentBlock:contentBlock errorBlock:contentError];
}

//curl -G -u 'lbmg:de2013' -H "Accept:application/vnd.lbmg+json;version=1" -d 'search=beer&latitude=39.74653&longitude=-104.994600' https://lbmg-staging.herokuapp.com/api/listings/search.json?search=beer&latitude=39.74653&longitude=-104.994600

//curl -G -u 'lbmg:de2013' -H "Accept:application/vnd.lbmg+json;version=1" -d 'search=b' https://lbmg-staging.herokuapp.com/api/listings/search_suggestions.json?search=b

- (void)getListingSearchWithString:(NSString *)searchItem withLatitude:(float)latitude andLongitude:(float)longitude contentBlock:(LBMGContentGetArray)contentBlock errorBlock:(LBMGContentError)contentError {
    NSString *functionString = [[NSString stringWithFormat:kListingSearch,searchItem, latitude, longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    DLog(@"%@", functionString);
    [self startArrayOpWithPath:functionString contentBlock:contentBlock errorBlock:contentError];
}

- (void)getListingSuggestionsWithString:(NSString *)searchItem contentBlock:(LBMGContentGetArray)contentBlock errorBlock:(LBMGContentError)contentError {
    NSString *functionString = [[NSString stringWithFormat:kListingSuggest,searchItem] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    DLog(@"%@", functionString);
    [self startArrayOpWithPath:functionString contentBlock:contentBlock errorBlock:contentError];
}


// logging calls
- (void)logTourStartWithId:(NSNumber *)tourID latitude:(float)latitude andLongitude:(float)longitude contentBlock:(LBMGContentGetDictionary)contentBlock errorBlock:(LBMGContentError)contentError {
    NSString *deviceId = [LBMGUtilities uniqueDeviceID];
    NSString *functionString = [NSString stringWithFormat:kLogTourStart, tourID, latitude, longitude, deviceId];
    DLog(@"%@", functionString);
    [self startPostOpWithPath:functionString contentBlock:contentBlock errorBlock:contentError];
}

- (void)logTourCompleteWithId:(NSNumber *)tourID latitude:(float)latitude andLongitude:(float)longitude contentBlock:(LBMGContentGetDictionary)contentBlock errorBlock:(LBMGContentError)contentError {
    NSString *deviceId = [LBMGUtilities uniqueDeviceID];
    NSString *functionString = [NSString stringWithFormat:kLogTourEnd, tourID, latitude, longitude, deviceId];
    DLog(@"%@", functionString);
    [self startPostOpWithPath:functionString contentBlock:contentBlock errorBlock:contentError];
}

- (void)logTourDownloadWithId:(NSNumber *)tourID latitude:(float)latitude andLongitude:(float)longitude contentBlock:(LBMGContentGetDictionary)contentBlock errorBlock:(LBMGContentError)contentError {
    NSString *deviceId = [LBMGUtilities uniqueDeviceID];
    NSString *functionString = [NSString stringWithFormat:kLogTourDownload, tourID, latitude, longitude, deviceId];
    DLog(@"%@", functionString);
    [self startPostOpWithPath:functionString contentBlock:contentBlock errorBlock:contentError];
}

- (void)logTourCategoryViewedWithId:(NSNumber *)categoryId latitude:(float)latitude andLongitude:(float)longitude contentBlock:(LBMGContentGetDictionary)contentBlock errorBlock:(LBMGContentError)contentError {
    NSString *deviceId = [LBMGUtilities uniqueDeviceID];
    NSString *functionString = [NSString stringWithFormat:kLogCategoryView, categoryId, latitude, longitude, deviceId];
    DLog(@"%@", functionString);
    [self startPostOpWithPath:functionString contentBlock:contentBlock errorBlock:contentError];
}

- (void)getFeaturedLinksForTourID:(NSNumber *)tourID contentBlock:(LBMGContentGetArray)contentBlock errorBlock:(LBMGContentError)contentError {
    NSString *functionString = [NSString stringWithFormat:kFeaturedListings, tourID];
    DLog(@"%@", functionString);
    [self startArrayOpWithPath:functionString contentBlock:contentBlock errorBlock:contentError];
}

@end
