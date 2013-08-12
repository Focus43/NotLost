//
//  LBMGUtilities.h
//  Tours
//
//  Created by Alan Smithee on 4/3/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <Foundation/Foundation.h>
@class  TourData;
@class  TourDetail;
@class  Event;

extern NSString * const LBMGUtilitiesDownloadComplete;
extern NSString * const LBMGUtilitiesDownloadProgress;


@interface LBMGUtilities : NSObject

+ (NSString *)basePathForTourData;
+ (NSString *)plistPathForTourID:(NSNumber *)tourID;
+ (NSString *)imagePathForTourID:(NSNumber *)tourID;
+ (NSString *)videoPathForTourID:(NSNumber *)tourID;
+ (NSString *)audioPathForTourID:(NSNumber *)tourID;
+ (NSString *)userDataPathForTourID:(NSNumber *)tourID;
+ (NSString *)userTouchedPoiPlistPathForTourID:(NSNumber *)tourID;
+ (NSString *)userDataPlistPathForTourID:(NSNumber *)tourID;
+ (NSString *)basePathForTourID:(NSNumber *)tourID;
+ (NSString *)basePathForDownloadingTourID:(NSNumber *)tourID;
+ (BOOL)tourExistsForID:(NSNumber *)tourID;
+ (void)downloadZippedDataForID:(NSNumber *)tourID atPath:(NSString *)path withError:(void (^)(MKNetworkOperation *, NSError *))errorBlock;
+ (void)createAndStoreThumbnailForImage:(UIImage *)contentImage named:(NSString *)photoName atPath:(NSString *)path;
+ (void)updateUserContentForTour:(NSNumber *)tourID withItem:(NSDictionary *)item;
+ (NSArray *)getUserContentForTour:(NSNumber *)tourID;
+ (void)createFolderForTourData;
+ (TourData *)getTourDataForTour:(NSNumber *)tourID;
+ (void)storeTourData:(NSDictionary *)tourData forId:(NSNumber *)tourID;
+ (NSArray *)GetSavedTourIdPaths;
+ (NSArray *)getTouchedPoisForTour:(NSNumber *)tourID;
+ (void)storeTouchedPois:(NSArray *)tourData forId:(NSNumber *)tourID;
+ (BOOL)tourDownloadingForID:(NSNumber *)tourID;
+ (NSString *)uniqueDeviceID;
+ (void)removeHangingDownloadFiles;
+ (void)removeTourRoutePlist:(NSNumber *)tourID;
+ (void)deleteTourWithId:(NSNumber *)tourID;
+ (void)addNewTourDetails:(TourDetail *)tour;
+ (NSArray *)getStoredTourDetails;
+ (void)removeTourDetails:(TourDetail *)tour;
+ (void)addNewCalendarEvent:(Event *)event;
+ (NSDate *)checkForID:(Event *)event;
+ (void)removeCalendarEvent:(Event *)event;
+ (NSDictionary *)savedEventsFrom:(NSDate *)fromDate to:(NSDate *)toDate;
+ (void)saveFavoriteByArea:(NSString *)areaName andCategory:(NSString *)categoryName andSubCategory:(NSString *)subCategoryName;
+ (void)deleteFavoriteByArea:(NSString *)areaName andCategory:(NSString *)categoryName andSubCategory:(NSString *)subCategoryName;
+ (NSDictionary *)fetchFavorites;
+ (void)buildSponseredEvents:(NSArray *)eventData;
+ (NSDictionary *)favoriteEventsForWeek:(NSDate *)fromDate;
+ (void)deleteTouchedPoisForID:(NSNumber *)tourID;

@end